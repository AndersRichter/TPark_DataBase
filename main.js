const koa = require('koa');

const bodyparser = require('koa-bodyparser');
const logger = require('koa-logger');
const router = require('koa-router')();

const bluebird = require('bluebird');
const pgp = require('pg-promise')({ promiseLib: bluebird, capSQL: true });

const info = {
	host: 'localhost',
	port: 5432,
	database: 'tp_db',
	user: 'andrey',
	password: 'andrey96'
};
const database = pgp(info);
const app = new koa();

let postsCount = 0;


router.post('/api/user/:nickname/create', async (ctx) => {
	await database.task(async t => {
		const existUser = await t.manyOrNone(
			`SELECT nickname, email, fullname, about FROM users 
			WHERE email = '${ctx.request.body.email}' 
			OR nickname = '${ctx.params.nickname}'`
		);

		if (existUser.length > 0) {
			ctx.body = existUser;
			ctx.status = 409;
			return;
		}

		await t.none(
			`INSERT INTO users (nickname, fullname, about, email)
			VALUES (
			'${ctx.params.nickname}', 
			'${ctx.request.body.fullname}', 
			'${ctx.request.body.about}', 
			'${ctx.request.body.email}'
			)`
		);

		ctx.body = {
			"nickname": ctx.params.nickname,
			"fullname": ctx.request.body.fullname,
			"about": ctx.request.body.about,
			"email": ctx.request.body.email
		};

		ctx.status = 201;
	});
});


router.get('/api/user/:nickname/profile', async (ctx) => {
	const existUser = await database.oneOrNone(
		`SELECT nickname, fullname, about, email FROM users 
		WHERE nickname = '${ctx.params.nickname}'`
	);

	if (existUser) {
		ctx.body = existUser;
		ctx.status = 200;
	} else {
		ctx.body = { message: "Can't find user" };
		ctx.status = 404;
	}
});


router.post('/api/user/:nickname/profile', async (ctx) => {
	await database.task(async t => {
		const existUser = await t.manyOrNone(
			`SELECT nickname, fullname, about, email FROM users 
			WHERE nickname = '${ctx.params.nickname}' 
			OR email = '${ctx.request.body.email}'`
		);

		let countChanging = 0;

		if (existUser.length === 2) {
			ctx.body = { message: "This email is already in use" };
			ctx.status = 409;
		} else if (existUser.length === 1) {
			if (ctx.request.body.fullname) {
				existUser[0].fullname = ctx.request.body.fullname;
				countChanging++;
			}
			if (ctx.request.body.about) {
				existUser[0].about = ctx.request.body.about;
				countChanging++;
			}
			if (ctx.request.body.email) {
				existUser[0].email = ctx.request.body.email;
				countChanging++;
			}

			if (countChanging !== 0) {
				await t.none(
					`UPDATE users SET 
						fullname = '${existUser[0].fullname}', 
						about = '${existUser[0].about}', 
						email = '${existUser[0].email}'
					WHERE nickname = '${ctx.params.nickname}'`
				);
			}

			ctx.body = existUser[0];
			ctx.status = 200;
		} else {
			ctx.body = { message: "Can't find user" };
			ctx.status = 404;
		}
	});
});


router.post('/api/forum/create', async (ctx) => {
	await database.task(async t => {
		const existForum = await t.oneOrNone(
			`SELECT slug, title, author AS user FROM forums 
			WHERE slug = '${ctx.request.body.slug}'`
		);

		if (existForum) {
			ctx.body = existForum;
			ctx.status = 409;
			return;
		}

		const existUser = await t.oneOrNone(
			`SELECT nickname FROM users 
			WHERE nickname = '${ctx.request.body.user}'`
		);

		if (existUser) {
			await t.none(
				`INSERT INTO forums (author, slug, title)
				VALUES (
				'${existUser.nickname}',
				'${ctx.request.body.slug}',
				'${ctx.request.body.title}'
				)`
			);

			ctx.body = {
				"slug": ctx.request.body.slug,
				"title": ctx.request.body.title,
				"user": existUser.nickname
			};
			ctx.status = 201;
		} else {
			ctx.body = { message: "Can't find user" };
			ctx.status = 404;
		}
	});
});


router.get('/api/forum/:slug/details', async (ctx) => {
	const existForum = await database.oneOrNone(
		`SELECT slug, title, author AS user, posts, threads FROM forums 
		WHERE slug = '${ctx.params.slug}'`
	);

	if (existForum) {
		if (existForum.posts === 0) delete existForum.posts;
		if (existForum.threads === 0) delete existForum.threads;
		ctx.body = existForum;
		ctx.status = 200;
	} else {
		ctx.body = { message: "Can't find forum" };
		ctx.status = 404;
	}
});


router.post('/api/forum/:slug/create', async (ctx) => {
	await database.task(async t => {
		let existThread = null;
		if (ctx.request.body.slug)
			existThread = await t.oneOrNone(
				`SELECT * FROM threads 
				WHERE slug = '${ctx.request.body.slug}'`
			);
		if (existThread !== null) {
			ctx.body = existThread;
			ctx.status = 409;
			return;
		}

		const existUser = await t.oneOrNone(
			`SELECT nickname, email, fullname, about FROM users 
			WHERE nickname = '${ctx.request.body.author}'`
		);
		if (!existUser) {
			ctx.body = { message: "Can't find user" };
			ctx.status = 404;
			return;
		}

		const existForum = await t.oneOrNone(
			`SELECT slug FROM forums 
			WHERE slug = '${ctx.params.slug}'`
		);
		if (!existForum) {
			ctx.body = { message: "Can't find forum" };
			ctx.status = 404;
			return;
		}

		const body = {
			"author": existUser.nickname,
			"title": ctx.request.body.title,
			"forum": existForum.slug,
			"message": ctx.request.body.message,
		};

		if(ctx.request.body.created)
			body.created = ctx.request.body.created;
		else
			body.created = new Date().toUTCString();

		let id = 0;
		if(ctx.request.body.slug) {
			body.slug = ctx.request.body.slug;
			id = await t.one(
				`INSERT INTO threads (author, slug, title, forum, message, created)
				VALUES (
				'${existUser.nickname}',
				'${body.slug}',
				'${ctx.request.body.title}',
				'${existForum.slug}',
				'${ctx.request.body.message}',
				'${body.created}'
				) RETURNING id`
			);
		} else {
			id = await t.one(
				`INSERT INTO threads (author, title, forum, message, created)
				VALUES (
				'${existUser.nickname}', 
				'${ctx.request.body.title}',
				'${existForum.slug}',
				'${ctx.request.body.message}',
				'${body.created}'
				) RETURNING id`
			);
		}

		body.id = id.id;

		if (!ctx.request.body.created) delete body.created;

		await t.none(
			`UPDATE forums SET
			threads = threads + 1 WHERE slug = '${existForum.slug}'`
		);

		await t.none(
			`INSERT INTO users_in_forum
			VALUES(
			'${existForum.slug}', 
			'${existUser.nickname}') 
			ON CONFLICT ON CONSTRAINT users_in_forum_forum_author_pk DO NOTHING`
		);

		ctx.body = body;
		ctx.status = 201;
	});
});


router.get('/api/forum/:slug/threads', async (ctx) => {
	await database.task(async t => {
		const existForum = await t.oneOrNone(
			`SELECT slug FROM forums 
			WHERE slug = '${ctx.params.slug}'`
		);

		if (existForum) {
			let limit = "ALL";
			let desc = "ASC";
			let since = 0;
			let sign = ">=";

			if (ctx.query.limit)
				limit = ctx.query.limit;
			if (ctx.query.desc === 'true')
				desc = "DESC";
			if (ctx.query.since)
				since = ctx.query.since;
			if (ctx.query.desc === 'true' && ctx.query.since)
				sign = "<=";

			if (since === 0) {
				ctx.body = await t.any(
					`SELECT * from threads
					WHERE forum = '${ctx.params.slug}' 
					ORDER BY created ${desc}
					LIMIT ${limit}`
				);
			} else {
				ctx.body = await t.any(
					`SELECT * from threads
					WHERE forum = '${ctx.params.slug}' AND
					created ${sign} '${since}'
					ORDER BY created ${desc}
					LIMIT ${limit}`
				);
			}
			ctx.status = 200;
		} else {
			ctx.body = { message: "Can't find forum" };
			ctx.status = 404;
		}
	});
});


router.post('/api/thread/:slugOrId/create', async (ctx) => {
	await database.task(async t => {
		let authors = [];
		let existThread = 0;
		if (isNaN(ctx.params.slugOrId)) {
			existThread = await t.oneOrNone(
				`SELECT id, forum FROM threads 
				WHERE slug = '${ctx.params.slugOrId}'`
			);
		} else {
			existThread = await t.oneOrNone(
				`SELECT id, forum FROM threads 
				WHERE id = '${ctx.params.slugOrId}'`
			);
		}

		if (!existThread) {
			ctx.body = { message: "Can't find post thread" };
			ctx.status = 404;
			return;
		}

		if (ctx.request.body.length === 0) {
			ctx.status = 201;
			ctx.body = [];
			return;
		}

		let body = [];
		const length = ctx.request.body.length;
		let time = new Date();

		for (let i = 0; i < length; i++) {
			body[i] = {
				"author": ctx.request.body[i].author,
				"message": ctx.request.body[i].message,
				"thread": existThread.id,
				"forum": existThread.forum,
				"created": time
			};
			if (ctx.request.body[i].parent) {
				let parent = await t.oneOrNone(
					`SELECT id FROM posts 
					WHERE thread = ${existThread.id} AND 
					id = ${ctx.request.body[i].parent}`
				);
				if (!parent) {
					ctx.body = { message: "Parent post was created in another thread" };
					ctx.status = 409;
					return;
				}

				body[i].parent = ctx.request.body[i].parent;
			}
			else
				body[i].parent = 0;

			let author = await t.oneOrNone(
				`SELECT email, fullname, about FROM users 
				WHERE nickname = '${body[i].author}'`
			);
			if (!author) {
				ctx.body = { message: "Can't find post author" };
				ctx.status = 404;
				return;
			}

			if (authors.indexOf(body[i].author) === -1) {
				authors.push(body[i].author);
				await t.none(
					`INSERT INTO users_in_forum
					VALUES(
					'${existThread.forum}', 
					'${body[i].author}') 
					ON CONFLICT ON CONSTRAINT users_in_forum_forum_author_pk DO NOTHING`
				);
			}
		}

		const query = pgp.helpers.insert(
			body,
			['author', 'message', 'created', 'parent', 'thread', 'forum'],
			'posts'
		) + ' RETURNING id';

		const id = await t.any(query);

		for (let i = 0; i < length; i++) {
			await t.none(
				`UPDATE posts SET 
				path = (SELECT path FROM posts WHERE id = ${body[i].parent}) || (${id[i].id}) WHERE id = ${id[i].id}`
			);
			body[i].id = id[i].id;
			body[i].created = time;
			if (!ctx.request.body[i].parent) delete body[i].parent;
		}

		await t.none(
			`UPDATE forums SET 
			posts = posts + ${length} 
			WHERE slug = '${existThread.forum}'`
		);

		// postsCount += length;
		// if (postsCount >= 1500000) {
		// 	await database.none(`CLUSTER posts USING post_path`);
		// }
		// console.log(postsCount);

		ctx.body = body;
		ctx.status = 201;
	});
});


router.post('/api/thread/:slugOrId/vote', async (ctx) => {
	await database.task(async t => {
		let author = await t.oneOrNone(
			`SELECT nickname FROM users 
			WHERE nickname = '${ctx.request.body.nickname}'`
		);
		if (!author) {
			ctx.body = { message: "Can't find voice author" };
			ctx.status = 404;
			return;
		}

		let existThread = 0;
		if (isNaN(ctx.params.slugOrId)) {
			existThread = await t.oneOrNone(
				`SELECT * FROM threads 
				WHERE slug = '${ctx.params.slugOrId}'`
			);
		} else {
			existThread = await t.oneOrNone(
				`SELECT * FROM threads 
				WHERE id = '${ctx.params.slugOrId}'`
			);
		}

		if (existThread) {
			const voice = +ctx.request.body.voice;

			const oldVoice = await t.oneOrNone(
				`SELECT voice FROM votes 
				WHERE author = '${ctx.request.body.nickname}' AND
				thread = ${existThread.id}`
			);

			if (oldVoice) {
				if (oldVoice.voice !== voice) {
					await t.none(
						`UPDATE votes SET voice = ${voice} 
						WHERE author = '${ctx.request.body.nickname}' AND
						thread = ${existThread.id}`
					);
					await t.none(
						`UPDATE threads SET votes = votes + ${voice}*2 
						WHERE id = ${existThread.id}`
					);
					existThread.votes += voice*2;
				}
			} else {
				await t.none(
					`INSERT INTO votes (voice, author, thread) 
					VALUES (${voice}, 
					'${ctx.request.body.nickname}', 
					${existThread.id})`
				);
				await t.none(
					`UPDATE threads SET votes = votes + ${voice} 
					WHERE id = ${existThread.id}`
				);
				existThread.votes += voice;
			}

			ctx.body = existThread;
			ctx.status = 200;
		} else {
			ctx.body = { message: "Can't find thread" };
			ctx.status = 404;
		}
	});
});


router.get('/api/thread/:slugOrId/details', async (ctx) => {
	let existThread = 0;
	if (isNaN(ctx.params.slugOrId)) {
		existThread = await database.oneOrNone(
			`SELECT * FROM threads 
			WHERE slug = '${ctx.params.slugOrId}'`
		);
	} else {
		existThread = await database.oneOrNone(
			`SELECT * FROM threads 
			WHERE id = '${ctx.params.slugOrId}'`
		);
	}

	if (existThread) {
		ctx.body = existThread;
		ctx.status = 200;
	} else {
		ctx.body = { message: "Can't find thread" };
		ctx.status = 404;
	}
});


router.get('/api/thread/:slugOrId/posts', async (ctx) => {
	await database.task(async t => {
		let existThread = 0;
		if (isNaN(ctx.params.slugOrId)) {
			existThread = await t.oneOrNone(
				`SELECT id FROM threads 
				WHERE slug = '${ctx.params.slugOrId}'`
			);
		} else {
			existThread = await t.oneOrNone(
				`SELECT id FROM threads 
				WHERE id = '${ctx.params.slugOrId}'`
			);
		}

		if (existThread) {
			let limit = "ALL";
			let desc = "ASC";
			let since = 0;
			let sort = false;
			let sign = ">";

			if (ctx.query.limit)
				limit = ctx.query.limit;
			if (ctx.query.desc === 'true')
				desc = "DESC";
			if (ctx.query.since)
				since = ctx.query.since;
			if (ctx.query.desc === 'true' && ctx.query.since)
				sign = "<";
			if (ctx.query.sort)
				sort = ctx.query.sort;

			let body = [];
			if (!sort || sort === 'flat') {
				if (since !== 0) {
					body = await t.any(
						`SELECT author, created, forum, id, message, thread, parent FROM posts
						WHERE thread = ${existThread.id} AND
						id ${sign} ${since}
						ORDER BY created ${desc}, id ${desc}
						LIMIT ${limit}`
					);
				} else {
					body = await t.any(
						`SELECT author, created, forum, id, message, thread, parent FROM posts
						WHERE thread = ${existThread.id} 
						ORDER BY created ${desc}, id ${desc}
						LIMIT ${limit}`
					);
				}
			} else if (sort === 'tree') {
				if (since !== 0) {
					body = await t.any(
						`SELECT author, created, forum, id, message, thread, parent FROM posts
						WHERE thread = ${existThread.id} AND path ${sign} (
		                    SELECT path FROM posts WHERE id = ${since}
						) ORDER BY path ${desc} LIMIT ${limit}`
					);
				} else {
					body = await t.any(
						`SELECT author, created, forum, id, message, thread, parent FROM posts
						WHERE thread = ${existThread.id} 
						ORDER BY path ${desc} LIMIT ${limit}`
					);
				}
			} else if (sort === 'parent_tree') {
				let arrayOfParent = 0;
				if (since !== 0) {
					arrayOfParent = await t.any(
						`SELECT path FROM posts 
						WHERE thread = ${existThread.id} AND 
						parent = 0 AND path ${sign} (
		                    SELECT path FROM posts WHERE id = ${since} LIMIT 1
						)
						ORDER BY path ${desc} LIMIT ${limit}`
					);
				} else {
					arrayOfParent = await t.any(
						`SELECT path FROM posts 
						WHERE thread = ${existThread.id} AND parent = 0 
						ORDER BY path ${desc} LIMIT ${limit}`
					);
				}

				if (arrayOfParent.length === 0) {
					ctx.body = [];
					ctx.status = 200;
					return;
				}

				let stringOfArray = `{`;
				arrayOfParent.forEach(el => {
					stringOfArray += `${el.path[0]}, `
				});
				stringOfArray = stringOfArray.slice(0, -2);
				stringOfArray += `}`;

				body = await t.any(
					`SELECT author, created, forum, id, message, thread, parent FROM posts
					WHERE thread = ${existThread.id} AND 
					path[1] = ANY ('${stringOfArray}')
					ORDER BY path ${desc}`
				);
			}

			body.forEach(el => {
				if (el.parent === 0)
					delete el.parent;
			});

			ctx.body = body;
			ctx.status = 200;
		} else {
			ctx.body = { message: "Can't find thread" };
			ctx.status = 404;
		}
	});
});


router.post('/api/thread/:slugOrId/details', async (ctx) => {
	await database.task(async t => {
		let existThread = 0;
		if (isNaN(ctx.params.slugOrId)) {
			existThread = await t.oneOrNone(
				`SELECT * FROM threads 
				WHERE slug = '${ctx.params.slugOrId}'`
			);
		} else {
			existThread = await t.oneOrNone(
				`SELECT * FROM threads 
				WHERE id = '${ctx.params.slugOrId}'`
			);
		}

		let countChanging = 0;

		if (existThread) {
			if (ctx.request.body.message) {
				existThread.message = ctx.request.body.message;
				countChanging++;
			}
			if (ctx.request.body.title) {
				existThread.title = ctx.request.body.title;
				countChanging++;
			}

			if (countChanging !== 0) {
				await t.none(
					`UPDATE threads SET 
					message = '${existThread.message}', 
					title = '${existThread.title}' 
					WHERE id = ${existThread.id}`
				);
			}

			ctx.body = existThread;
			ctx.status = 200;
		} else {
			ctx.body = { message: "Can't find thread" };
			ctx.status = 404;
		}
	});
});


router.get('/api/forum/:slug/users', async (ctx) => {
	await database.task(async t => {
		const existForum = await t.oneOrNone(
			`SELECT slug FROM forums 
			WHERE slug = '${ctx.params.slug}'`
		);

		if (existForum) {
			let limit = "ALL";
			let desc = "ASC";
			let since = 0;
			let sign = ">";
			let users = [];

			if (ctx.query.limit)
				limit = ctx.query.limit;
			if (ctx.query.desc === 'true')
				desc = "DESC";
			if (ctx.query.since)
				since = ctx.query.since;
			if (ctx.query.desc === 'true' && ctx.query.since)
				sign = "<";

			if (since !== 0) {
				users = await t.any(
					`SELECT u.nickname, u.fullname, u.about, u.email
					FROM users_in_forum uf JOIN users u
                        ON uf.author = u.nickname
					WHERE forum = '${ctx.params.slug}' 
					AND author ${sign} '${since}' 
					ORDER BY u.nickname ${desc} LIMIT ${limit}`
				);
			} else {
				users = await t.any(
					`SELECT u.nickname, u.fullname, u.about, u.email
					FROM users_in_forum uf JOIN users u
                        ON uf.author = u.nickname
					WHERE forum = '${ctx.params.slug}' 
					ORDER BY u.nickname ${desc} LIMIT ${limit}`
				);
			}

			if (users.length === 0) {
				ctx.body = [];
				ctx.status = 200;
				return;
			}

			ctx.body = users;
			ctx.status = 200;
		} else {
			ctx.body = { message: "Can't find forum" };
			ctx.status = 404;
		}
	});
});


router.get('/api/post/:id/details', async (ctx) => {
	await database.task(async t => {
		let existPost = await t.oneOrNone(
			`SELECT * FROM posts 
			WHERE id = ${ctx.params.id}`
		);

		if (existPost) {
			ctx.body = {};

			delete existPost.path;
			if (existPost.parent === 0) delete existPost.parent;
			if (existPost.isedited !== false)
				existPost.isEdited = existPost.isedited;
			delete existPost.isedited;

			if (ctx.query.related) {
				let relArray = ctx.query.related.split(',');

				if (relArray.indexOf('user') !== -1) {
					ctx.body.author = await t.one(
						`SELECT about, email, fullname, nickname FROM users 
						WHERE nickname = '${existPost.author}'`
					);
				}
				if (relArray.indexOf('thread') !== -1) {
					ctx.body.thread = await t.one(
						`SELECT author, created, forum, id, message, slug, title, votes FROM threads 
						WHERE id = '${existPost.thread}'`
					);
				}
				if (relArray.indexOf('forum') !== -1) {
					ctx.body.forum = await t.one(
						`SELECT posts, slug, threads, title, author AS user FROM forums 
						WHERE slug = '${existPost.forum}'`
					);
				}
			}

			ctx.body.post = existPost;
			ctx.status = 200;
		} else {
			ctx.body = { message: "Can't find post" };
			ctx.status = 404;
		}
	});
});


router.post('/api/post/:id/details', async (ctx) => {
	await database.task(async t => {
		let existPost = await t.oneOrNone(
			`SELECT * FROM posts 
			WHERE id = ${ctx.params.id}`
		);

		if (existPost) {
			if (ctx.request.body.message &&
				ctx.request.body.message !== existPost.message) {

				existPost.message = ctx.request.body.message;
				existPost.isedited = true;

				await t.none(
					`UPDATE posts SET 
					message = '${existPost.message}', 
					isedited = ${existPost.isedited} 
					WHERE id = ${existPost.id}`
				);
			}

			delete existPost.path;
			if (existPost.isedited !== false)
				existPost.isEdited = existPost.isedited;
			delete existPost.isedited;
			if (existPost.parent === 0) delete existPost.parent;

			ctx.body = existPost;
			ctx.status = 200;
		} else {
			ctx.body = { message: "Can't find post" };
			ctx.status = 404;
		}
	});
});


router.get('/api/service/status', async (ctx) => {
	await database.task(async t => {
		const forumsCount = await t.one(`SELECT COUNT(slug) FROM forums`);
		const postsCount = await t.one(`SELECT COUNT(id) FROM posts`);
		const threadsCount = await t.one(`SELECT COUNT(id) FROM threads`);
		const usersCount = await t.one(`SELECT COUNT(nickname) FROM users`);

		ctx.body = {
			"forum": +forumsCount.count,
			"post": +postsCount.count,
			"thread": +threadsCount.count,
			"user": +usersCount.count
		};
		ctx.status = 200;
	});
});


router.post('/api/service/clear', async (ctx) => {
	await database.none(
		`TRUNCATE TABLE users CASCADE`
	);
	ctx.status = 200;
});


app
	.use(bodyparser())
	.use(logger())
	.use(router.routes());

app.listen(5000, () => {
	console.log('Server listen port -> 5000');
});
