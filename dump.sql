--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.10
-- Dumped by pg_dump version 9.5.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: forums; Type: TABLE; Schema: public; Owner: andrey
--

CREATE TABLE forums (
    id integer NOT NULL,
    slug citext NOT NULL,
    title character varying NOT NULL,
    author citext NOT NULL,
    posts integer DEFAULT 0,
    threads integer DEFAULT 0
);


ALTER TABLE forums OWNER TO andrey;

--
-- Name: forums_id_seq; Type: SEQUENCE; Schema: public; Owner: andrey
--

CREATE SEQUENCE forums_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE forums_id_seq OWNER TO andrey;

--
-- Name: forums_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: andrey
--

ALTER SEQUENCE forums_id_seq OWNED BY forums.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: andrey
--

CREATE TABLE posts (
    id integer NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    message text NOT NULL,
    parent integer DEFAULT 0,
    isedited boolean DEFAULT false NOT NULL,
    path integer[],
    author citext NOT NULL,
    forum citext NOT NULL,
    thread integer NOT NULL
);


ALTER TABLE posts OWNER TO andrey;

--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: andrey
--

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE posts_id_seq OWNER TO andrey;

--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: andrey
--

ALTER SEQUENCE posts_id_seq OWNED BY posts.id;


--
-- Name: threads; Type: TABLE; Schema: public; Owner: andrey
--

CREATE TABLE threads (
    id integer NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    message text NOT NULL,
    slug citext,
    title character varying NOT NULL,
    author citext NOT NULL,
    forum citext NOT NULL,
    votes integer DEFAULT 0
);


ALTER TABLE threads OWNER TO andrey;

--
-- Name: threads_id_seq; Type: SEQUENCE; Schema: public; Owner: andrey
--

CREATE SEQUENCE threads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE threads_id_seq OWNER TO andrey;

--
-- Name: threads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: andrey
--

ALTER SEQUENCE threads_id_seq OWNED BY threads.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: andrey
--

CREATE TABLE users (
    id integer NOT NULL,
    nickname citext NOT NULL,
    fullname character varying,
    about text,
    email citext NOT NULL
);


ALTER TABLE users OWNER TO andrey;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: andrey
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_id_seq OWNER TO andrey;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: andrey
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: users_in_forum; Type: TABLE; Schema: public; Owner: andrey
--

CREATE TABLE users_in_forum (
    forum citext NOT NULL,
    author citext NOT NULL
);


ALTER TABLE users_in_forum OWNER TO andrey;

--
-- Name: votes; Type: TABLE; Schema: public; Owner: andrey
--

CREATE TABLE votes (
    voice integer NOT NULL,
    author citext NOT NULL,
    thread integer NOT NULL
);


ALTER TABLE votes OWNER TO andrey;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY forums ALTER COLUMN id SET DEFAULT nextval('forums_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY threads ALTER COLUMN id SET DEFAULT nextval('threads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: forums_pkey; Type: CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY forums
    ADD CONSTRAINT forums_pkey PRIMARY KEY (id);


--
-- Name: posts_pkey; Type: CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: threads_pkey; Type: CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY threads
    ADD CONSTRAINT threads_pkey PRIMARY KEY (id);


--
-- Name: users_in_forum_forum_author_pk; Type: CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY users_in_forum
    ADD CONSTRAINT users_in_forum_forum_author_pk PRIMARY KEY (forum, author);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: author_thread; Type: INDEX; Schema: public; Owner: andrey
--

CREATE INDEX author_thread ON votes USING btree (author, thread);


--
-- Name: forums_slug_uindex; Type: INDEX; Schema: public; Owner: andrey
--

CREATE UNIQUE INDEX forums_slug_uindex ON forums USING btree (slug);


--
-- Name: post_thread; Type: INDEX; Schema: public; Owner: andrey
--

CREATE INDEX post_thread ON posts USING btree (thread);


--
-- Name: thread_forum_created; Type: INDEX; Schema: public; Owner: andrey
--

CREATE INDEX thread_forum_created ON threads USING btree (forum, created);


--
-- Name: thread_slug; Type: INDEX; Schema: public; Owner: andrey
--

CREATE INDEX thread_slug ON threads USING btree (slug);


--
-- Name: users_email_uindex; Type: INDEX; Schema: public; Owner: andrey
--

CREATE UNIQUE INDEX users_email_uindex ON users USING btree (email);


--
-- Name: users_nickname_uindex; Type: INDEX; Schema: public; Owner: andrey
--

CREATE UNIQUE INDEX users_nickname_uindex ON users USING btree (nickname);


--
-- Name: forums_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY forums
    ADD CONSTRAINT forums_user_fkey FOREIGN KEY (author) REFERENCES users(nickname);


--
-- Name: posts_forum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_forum_fkey FOREIGN KEY (forum) REFERENCES forums(slug);


--
-- Name: posts_thread_fkey; Type: FK CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_thread_fkey FOREIGN KEY (thread) REFERENCES threads(id);


--
-- Name: posts_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_user_fkey FOREIGN KEY (author) REFERENCES users(nickname);


--
-- Name: threads_forum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY threads
    ADD CONSTRAINT threads_forum_fkey FOREIGN KEY (forum) REFERENCES forums(slug);


--
-- Name: threads_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY threads
    ADD CONSTRAINT threads_user_fkey FOREIGN KEY (author) REFERENCES users(nickname);


--
-- Name: users_in_forum_forum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY users_in_forum
    ADD CONSTRAINT users_in_forum_forum_fkey FOREIGN KEY (forum) REFERENCES forums(slug);


--
-- Name: users_in_forum_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY users_in_forum
    ADD CONSTRAINT users_in_forum_user_fkey FOREIGN KEY (author) REFERENCES users(nickname);


--
-- Name: votes_thread_fkey; Type: FK CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_thread_fkey FOREIGN KEY (thread) REFERENCES threads(id);


--
-- Name: votes_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_user_fkey FOREIGN KEY (author) REFERENCES users(nickname);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

