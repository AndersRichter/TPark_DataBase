const koa = require('koa');

const bodyparser = require('koa-bodyparser');
const logger = require('koa-logger');
const router = require('koa-router')();

const pgp = require('pg-promise');
const bluebird = require('bluebird');

let myPGP = pgp({ promiseLib: bluebird });
const info = {
	host: 'localhost',
	port: 5432,
	database: 'tp_db',
	user: 'andrey',
	password: 'andrey96'
};
const database = myPGP(info);
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
		`SELECT slug, title, username AS user FROM forums 
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
				`INSERT INTO forums (username, slug, title)
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
		`SELECT slug, title, username AS user FROM forums 
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
		body[0] = {
			"author": ctx.request.body[0].author,
			"message": ctx.request.body[0].message,
		};
		body[0].created = new Date();

		if (isNaN(ctx.params.slugOrId)) {
			const idAndForumAndThread = await database.one(
				`INSERT INTO posts (forum, thread, author, message, created)
				SELECT forum, id, 
				'${ctx.request.body[0].author}', 
				'${ctx.request.body[0].message}',  
				'${body[0].created.toUTCString()}'
				FROM threads WHERE slug = '${ctx.params.slugOrId}' 
				RETURNING id, forum, thread`
			);

			body[0].id = idAndForumAndThread.id;
			body[0].forum = idAndForumAndThread.forum;
			body[0].thread = idAndForumAndThread.thread;
		} else {
			body[0].thread = +ctx.params.slugOrId;

			const idAndForum = await database.one(
				`INSERT INTO posts (forum, author, message, thread, created)
				SELECT forum, 
				'${ctx.request.body[0].author}', 
				'${ctx.request.body[0].message}', 
				${body[0].thread}, 
				'${body[0].created.toUTCString()}'
				FROM threads WHERE id = ${ctx.params.slugOrId} 
				RETURNING id, forum`
			);

			body[0].id = idAndForum.id;
			body[0].forum = idAndForum.forum;
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
			WHERE nickname = '${ctx.request.body.nickname}' AND
			thread = ${existThread.id}`
		);

		if (oldVoice) {
			if (oldVoice.voice !== voice) {
				await database.task(async t => {
					await t.none(
						`UPDATE votes SET voice = ${voice} 
						WHERE nickname = '${ctx.request.body.nickname}' AND
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
					`INSERT INTO votes (voice, nickname, thread) 
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

app
	.use(bodyparser())
	.use(logger())
	.use(router.routes());

app.listen(5400, () => {
	console.log('Server listen port -> 5400');
});
