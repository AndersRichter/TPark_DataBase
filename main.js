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


router.post('/api/user/:nickname/create', async (ctx) => {
	const existUser = await database.manyOrNone(
		`SELECT * FROM users 
		WHERE email = '${ctx.request.body.email}' 
		OR nickname = '${ctx.params.nickname}'`
	);

	if (existUser.length > 0) {
		ctx.body = existUser;
		ctx.status = 409;
	} else {
		await database.none(
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
	}
});


router.get('/api/user/:nickname/profile', async (ctx) => {
	const existUser = await database.oneOrNone(
		`SELECT * FROM users 
		WHERE nickname = '${ctx.params.nickname}'`
	);

	if (existUser) {
		ctx.body = existUser;
		ctx.status = 200;
	} else {
		ctx.body = {
			message: "Can't find user"
		};
		ctx.status = 404;
	}
});


router.post('/api/user/:nickname/profile', async (ctx) => {
	const existUser = await database.oneOrNone(
		`SELECT * FROM users 
		WHERE nickname = '${ctx.params.nickname}'`
	);

	if (existUser) {
		let existEmail = await await database.oneOrNone(
			`SELECT * FROM users 
			WHERE email = '${ctx.request.body.email}'`
		);

		if (existEmail) {
			ctx.body = {
				message: "This email is already in use"
			};
			ctx.status = 409;
		} else {

			if (ctx.request.body.fullname)
				existUser.fullname = ctx.request.body.fullname;
			if (ctx.request.body.about)
				existUser.about = ctx.request.body.about;
			if (ctx.request.body.email)
				existUser.email = ctx.request.body.email;

			await database.none(
				`UPDATE users SET 
				fullname = '${existUser.fullname}', 
				about = '${existUser.about}', 
				email = '${existUser.email}'
				WHERE nickname = '${ctx.params.nickname}'`
			);

			ctx.body = existUser;

			ctx.status = 200;
		}
	} else {
		ctx.body = {
			message: "Can't find user"
		};
		ctx.status = 404;
	}
});


router.post('/api/forum/create', async (ctx) => {
	const existForum = await database.oneOrNone(
		`SELECT slug, title, author AS user FROM forums 
		WHERE slug = '${ctx.request.body.slug}'`
	);

	if (existForum) {
		ctx.body = existForum;
		ctx.status = 409;
	} else {
		const existUser = await database.oneOrNone(
			`SELECT * FROM users 
			WHERE nickname = '${ctx.request.body.user}'`
		);

		if (existUser) {
			await database.none(
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
			ctx.body = {
				message: "Can't find user"
			};
			ctx.status = 404;
		}
	}
});


router.get('/api/forum/:slug/details', async (ctx) => {
	const existForum = await database.oneOrNone(
		`SELECT slug, title, author AS user FROM forums 
		WHERE slug = '${ctx.params.slug}'`
	);

	if (existForum) {
		ctx.body = existForum;
		ctx.status = 200;
	} else {
		ctx.body = {
			message: "Can't find forum"
		};
		ctx.status = 404;
	}
});


router.post('/api/forum/:slug/create', async (ctx) => {
	let existThread = 0;
	if (ctx.request.body.slug) {
		existThread = await database.oneOrNone(
			`SELECT * FROM threads 
			WHERE slug = '${ctx.request.body.slug}'`
		);
	} else {
		existThread = await database.oneOrNone(
			`SELECT * FROM threads 
			WHERE slug = '${ctx.params.slug}'`
		);
	}

	if (existThread) {
		ctx.body = existThread;
		ctx.status = 409;
	} else {
		const existUser = await database.oneOrNone(
			`SELECT * FROM users 
			WHERE nickname = '${ctx.request.body.author}'`
		);

		const existForum = await database.oneOrNone(
			`SELECT * FROM forums 
			WHERE slug = '${ctx.params.slug}'`
		);

		if (existUser && existForum) {
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

			if(ctx.request.body.slug)
				body.slug = ctx.request.body.slug;
			else
				body.slug = ctx.params.slug;

			let id = await database.one(
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

			body.id = id.id;

			if (!ctx.request.body.slug) delete body.slug;
			if (!ctx.request.body.created) delete body.created;

			ctx.body = body;
			ctx.status = 201;
		} else {
			ctx.body = {
				message: "Can't find user or forum"
			};
			ctx.status = 404;
		}
	}
});


router.get('/api/forum/:slug/threads', async (ctx) => {
	const existForum = await database.oneOrNone(
		`SELECT * FROM forums 
		WHERE slug = '${ctx.params.slug}'`
	);

	if (existForum) {
		let limit = "ALL";
		let desc = "ASC";
		let since = "1990-03-20T23:07:05.956Z";
		let sign = ">=";

		if (ctx.query.limit)
			limit = ctx.query.limit;
		if (ctx.query.desc === 'true')
			desc = "DESC";
		if (ctx.query.since)
			since = ctx.query.since;
		if (ctx.query.desc === 'true' && ctx.query.since)
			sign = "<=";

		ctx.body = await database.any(
			`SELECT * from threads
			WHERE forum = '${ctx.params.slug}' AND
			created ${sign} '${since}'
			ORDER BY created ${desc}
			LIMIT ${limit}`
		);
		ctx.status = 200;
	} else {
		ctx.body = {
			message: "Can't find forum"
		};
		ctx.status = 404;
	}
});


router.post('/api/thread/:slugOrId/create', async (ctx) => {
	if (ctx.request.body.length === 0) {
		ctx.status = 201;
		ctx.body = [];
	} else {
		let body = [];
		const length = ctx.request.body.length;
		let time = new Date();

		for (let i = 0; i < length; i++) {
			body[i] = {
				"author": ctx.request.body[i].author,
				"message": ctx.request.body[i].message,
			};
			if (ctx.request.body[i].parent)
				body[i].parent = ctx.request.body[i].parent;
			else
				body[i].parent = 0;
		}

		if (isNaN(ctx.params.slugOrId)) {
			let forumAndId = await database.one(
				`SELECT forum, id FROM threads WHERE slug = '${ctx.params.slugOrId}'`
			);

			for (let i = 0; i < length; i++) {
				body[i].thread = forumAndId.id;
				body[i].forum = forumAndId.forum;
				body[i].created = time;
			}
		} else {
			let existForum = await database.one(
				`(SELECT forum FROM threads WHERE id = ${ctx.params.slugOrId})`
			);

			for (let i = 0; i < length; i++) {
				body[i].thread = +ctx.params.slugOrId;
				body[i].forum = existForum.forum;
				body[i].created = time;
			}
		}
		const query = pgp.helpers.insert(
			body,
			['author', 'message', 'created', 'parent', 'thread', 'forum'],
			'posts'
		) + ' RETURNING id';

		const id = await database.any(query);

		for (let i = 0; i < length; i++) {
			await database.none(
				`UPDATE posts SET 
					path = (SELECT path FROM posts WHERE id = ${body[i].parent}) || (${id[i].id}) WHERE id = ${id[i].id};`
			);
			body[i].id = id[i].id;
			body[i].created = time;
			if (!ctx.request.body[i].parent) delete body[i].parent;
		}

		ctx.body = body;
		ctx.status = 201;
	}
});


router.post('/api/thread/:slugOrId/vote', async (ctx) => {
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
		const voice = +ctx.request.body.voice;

		const oldVoice = await database.oneOrNone(
			`SELECT voice FROM votes 
			WHERE author = '${ctx.request.body.nickname}' AND
			thread = ${existThread.id}`
		);

		if (oldVoice) {
			if (oldVoice.voice !== voice) {
				await database.task(async t => {
					await t.none(
						`UPDATE votes SET voice = ${voice} 
						WHERE author = '${ctx.request.body.nickname}' AND
						thread = ${existThread.id}`
					);
					await t.none(
						`UPDATE threads SET votes = votes + ${voice}*2 
						WHERE id = ${existThread.id}`
					)
				});
				existThread.votes += voice*2;
			}
		} else {
			await database.task(async t => {
				await t.none(
					`INSERT INTO votes (voice, author, thread) 
					VALUES (${voice}, 
					'${ctx.request.body.nickname}', 
					${existThread.id}
					)`
				);
				await t.none(
					`UPDATE threads SET votes = votes + ${voice} 
					WHERE id = ${existThread.id}`
				)
			});
			existThread.votes += voice;
		}

		ctx.body = existThread;
		ctx.status = 200;
	} else {
		ctx.body = {
			message: "Can't find thread"
		};
		ctx.status = 404;
	}
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
		ctx.body = {
			message: "Can't find thread"
		};
		ctx.status = 404;
	}
});


router.get('/api/thread/:slugOrId/posts', async (ctx) => {
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
		if (!sort) {
			body = await database.any(
				`SELECT author, created, forum, id, message, thread, parent FROM posts
				WHERE thread = ${existThread.id} AND
				id ${sign} ${since}
				ORDER BY created ${desc}, id ${desc}
				LIMIT ${limit}`
			);
		} else if (sort === 'flat') {
			body = await database.any(
				`SELECT author, created, forum, id, message, thread, parent FROM posts
				WHERE thread = ${existThread.id} AND
				id ${sign} ${since}
				ORDER BY created ${desc}, id ${desc}
				LIMIT ${limit}`
			);
		} else if (sort === 'tree') {
			if (since !== 0) {
				body = await database.any(
					`SELECT author, created, forum, id, message, thread, parent FROM posts
					WHERE thread = ${existThread.id} AND path ${sign} (
	                    SELECT path FROM posts WHERE id = ${since} LIMIT 1
					) ORDER BY path ${desc} LIMIT ${limit}`
				);
			} else {
				body = await database.any(
					`SELECT author, created, forum, id, message, thread, parent FROM posts
					WHERE thread = ${existThread.id} 
					ORDER BY path ${desc} LIMIT ${limit}`
				);
			}
		} else if (sort === 'parent_tree') {
			let arrayOfParent = 0;
			if (since !== 0) {
				arrayOfParent = await database.any(
					`SELECT path FROM posts 
					WHERE thread = ${existThread.id} AND 
					parent = 0 AND path ${sign} (
	                    SELECT path FROM posts WHERE id = ${since} LIMIT 1
					)
					ORDER BY path ${desc} LIMIT ${limit}`
				);
			} else {
				arrayOfParent = await database.any(
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

			body = await database.any(
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
		ctx.body = {
			message: "Can't find thread"
		};
		ctx.status = 404;
	}
});


router.post('/api/thread/:slugOrId/details', async (ctx) => {
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
		if (ctx.request.body.message)
			existThread.message = ctx.request.body.message;
		if (ctx.request.body.title)
			existThread.title = ctx.request.body.title;

		await database.none(
			`UPDATE threads SET 
			message = '${existThread.message}', 
			title = '${existThread.title}' 
			WHERE id = ${existThread.id}`
		);

		ctx.body = existThread;
		ctx.status = 200;
	} else {
		ctx.body = {
			message: "Can't find thread"
		};
		ctx.status = 404;
	}
});


app
	.use(bodyparser())
	.use(logger())
	.use(router.routes());

app.listen(5400, () => {
	console.log('Server listen port -> 5400');
});
