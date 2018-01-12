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
-- Data for Name: forums; Type: TABLE DATA; Schema: public; Owner: andrey
--

COPY forums (id, slug, title, author, posts, threads) FROM stdin;
182	6M1mkAR8P6SER	Ex piam colligenda sui quaero.	pervenire.MkBKJK7JG6pD7v	1	1
183	U64ASMRrnI82k	Audierit.	qui.8HNkRKJ7n6jdP1	1	1
184	0Esj8Asr4iRVs	Os invenit ab det usurpant tua laudibus rogo illos.	rei.4vPiPK7p4ZPVpu	1	1
185	I2Xjs3RrNiSv8	Ibi meminimus fuerim.	cogeremur.hU1f79rp2M71JD	1	1
186	UKoJ83KKpO8eR	O noverit tenebrosi sub sui nostram spe.	suo.Tp6FPkppgZJv7v	1	1
187	qml5S3884Or2r	Id tot ei graventur multi.	auribus.wkKIj9pp4671rV	1	1
188	smJjr38s4-kxk	Duabus cavis escam.	aliquod.jKIcpLjPgh71p1	1	1
189	A-WcRarkp6seS	Colligere ut vim sectantur eras de lux pecco manum.	sonos.9htIjKrjghjDJU	1	1
190	g6Z5rM8k4-8vSX	Venit hae meminerimus respondes, secundum ei erigo.	nos.ehQiPKRj267uR1	1	1
191	8615Slrr4iKvSx	Ea sana delet valerent.	e.7M05J9jj4hPuR1	1	1
192	5EnFRm8rN-kxKv	Molesta impium des scirent convertit thesaurus o, pedisequa debui.	simplicem.iD4Ip3RR2zRuP1	1	1
\.


--
-- Name: forums_id_seq; Type: SEQUENCE SET; Schema: public; Owner: andrey
--

SELECT pg_catalog.setval('forums_id_seq', 192, true);


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: andrey
--

COPY posts (id, created, message, parent, isedited, path, author, forum, thread) FROM stdin;
2846	2018-01-12 06:54:14.327+03	Insania gemitu futuras enim modicum altius ac traicit adversus duobus non quid. Omnes usurpant enim cui maeroribus certe aditum mundi comitatum se tribuere ubi tum fierent. Te vi. Conectitur forsitan hierusalem possim iam es meorum vae resolvisti. Evelles tum vi vi rapit has eo sanare tua ex si dei illis huc ipsi tuum.	0	f	{2846}	manum.hZA3jlrjnzpv7D	6M1mkAR8P6SER	240
2847	2018-01-12 06:54:14.403+03	Inter sinu. Ob dei.	0	f	{2847}	utriusque.YdN3RLjp4HJU7D	U64ASMRrnI82k	241
2848	2018-01-12 06:54:14.478+03	Videor huc perturbatione quaerentes recordemur super vidi spectandum mel praebens rogo se, oblivionis obsecro, eo consulunt. E faciant me tradidisti eunt medicina notiones oportebat frangat.	0	f	{2848}	verborum.UvjC7KJrNzPVPD	0Esj8Asr4iRVs	242
2849	2018-01-12 06:54:14.553+03	Mansuefecisti his carnis delet vita, piam sicubi fit ego dementia sero se inveniam latet significat. Dicat percipitur res hi volunt se ago. Quot arrogantis et mali nostra condit tam. Fias abiciendum verbo bonorumque ago meo diei nec solus ago. Tui sanas utilitate ne re eris. Tu sunt dare rogo, cur veni metuebam me ita male interroges aer continebat ei ab. Cum digna capior sit timeamur nequeunt nollent, occultum sat valeant ad iactantia die sat, praeter litteras tacet. Dicant id genuit simillimum unde haec sempiterna, fama sed aequalis damnetur eis dominos affectum freni mirari intentioni. Factos apparens continentiam mihi, mors passim e. Ea vox significantur aula amandum, credimus transeam. Omni aufer ut in si religione meus alia volumus nati tu alios magistro temptationis cui dicant, respiciens vi. Per nec dare mei splendeat amaremus. Bone cognituri fuisse adduxerunt voluptatibus temptatio deerit hos temptatio spargant una caelo domi illuc, tum stet sic si. Forte inde carthaginem sensu a magna sana circumquaque. Dum meum petimus lux hos infirmitas reminiscendo occursantur. Sit nec nunc fuerit iudicante sentitur laudatur loco totiens re ingressae probet adversa des. Fias mare quemadmodum dico conmemoravi dubitatione qua seductionibus dubitatione vivat fallaciam in adsensum. Vulnera o spargit nares noe fit regem aufer sentiunt, per regio. Si dei sive ecclesia rei at malint motus angelos mea iam regem.	0	f	{2849}	verbum.xrvcPk7r4ZPDpU	I2Xjs3RrNiSv8	243
2850	2018-01-12 06:54:14.661+03	Nullo idem rem ullo iam piam hoc, tot infirmitatem, at. Ergo bono ore. Sana vivente hos hic tuo pane consortium abyssos sublevas ruga vetare in in tu erro peste. Vix sim una ab, hos, eras una fixit nemo. Sonuerunt falsa sciam modestis vel det animales vi sonum. Prodeat malitia primus ferre.	0	f	{2850}	doleat.A4V5rkjp2m717U	UKoJ83KKpO8eR	244
2851	2018-01-12 06:54:14.736+03	Ut de mentiatur amo absorbuit pecco vi eo solo gaudeant.	0	f	{2851}	paratus.jL3573P7gzrUp1	qml5S3884Or2r	245
2852	2018-01-12 06:54:14.812+03	Sono. Dum. At ago ad genus, tuum. Tristis fallacia agebam generibus ingredior victor mare inspirationis ore vi mystice aut se nos novi veris. Da lucustis prout disputandi hic, ab. Os humanus item me nunc ob conspectum cur ego deo notiones aer si. Meas contexo. Unus dubitant aut praesentior ob affectent fructus, vocis tuam exserentes oculos isto narium sidera. Se. Audiat respondes. Aer evidentius peregrinorum ad ac en dei quaeque laudandum valde ac pluris videri capiamur sui cibus beares pulchritudine. Meminerunt os vellemus istorum sit fias re qui tuo auras id misera. Aeris det desideriis ergo, ago crucis ei ad tuo tobis sui audiar via meo ut das vicit fuisse longe. Eliqua difficultatis suaveolentiam at humilibus, reficimus ei ianua ab finis ago docentem, esto nolle diversisque. Ait hi. Incipio num tolerat aliter recedat spe usui. Partes cui. Abyssus aeris ex.	0	f	{2852}	ubi.h655jLJJnh7u7U	smJjr38s4-kxk	246
2853	2018-01-12 06:54:14.903+03	Placere tenendi peccatoris nos, aer. Nonnumquam vis membra iam ob. Mediatorem. Ei similia sumendi naturam hi commendantur regina ut ea tu freni praecidere patienter quandam. Ex de cupiditatis ne infirmos notus spe ob sibi tangendo ubi os conferamus ac me eoque meo. Vis abs fine video. Cui eam faciendo sonus contremunt mea os meminissemus alii eis misertus, sapor. Tot tobis filum nos valet de an a qua illi. Inventa ridiculum vis persentiscere ei, aer te audire domi cui poterunt deo mystice pronuntianti o e sapit.	0	f	{2853}	hic.euTIRkRp2HjvR1	A-WcRarkp6seS	247
2854	2018-01-12 06:54:14.97+03	INVOCARI EA UNUM EN POTUIMUS AB.	0	t	{2854}	sensarum.55wiR3JJG6RvJ1	g6Z5rM8k4-8vSX	248
2855	2018-01-12 06:54:15.045+03	His usum vocibus sentio tum litteras ac es, hae misericors tuos fuero rem.	0	f	{2855}	paene.yL057LjJ2zRvr1	8615Slrr4iKvSx	249
2856	2018-01-12 06:54:15.12+03	Prius hic laetandis es piam. Filum. Honoris surgam dona servi manducare sola diu abyssos modi inciderunt tuus ago alas non gemitum ibi aer me signa. E hic omnipotenti ne quo edendo vivendum eum aliquo manes tui divino adsurgat re ambulasti modi pati trahunt.	0	f	{2856}	o.DkGFrKRPgm7U7v	5EnFRm8rN-kxKv	250
\.


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: andrey
--

SELECT pg_catalog.setval('posts_id_seq', 2856, true);


--
-- Data for Name: threads; Type: TABLE DATA; Schema: public; Owner: andrey
--

COPY threads (id, created, message, slug, title, author, forum, votes) FROM stdin;
240	2017-02-26 09:31:08.228+03	Huiuscemodi.	eU1AsLKK0-REs	Mirabilia en ex recolenda, urunt timeo corones malim.	vales.VsB9pLrp4Z7uj1	6M1mkAR8P6SER	0
241	2017-07-22 08:26:05.212+03	Te lucustis via eos. Captans fabricatae tum. Det tantulum artes beatus tota dum sat experta sum delectationem constrictione si concupiscit diei sub si super. An mentiri me haec eloquentiam o amo faciei die hi et religione, vigilanti illo. Ei creaturam si resisto mei opertis ei cui des opificiis eant a re gaudiis quibus tum. Peccatorum ideo ecce genera. Populus dei capiendum ubi. Una ullo id fui ad fortius ex tuis quaerebatur aboleatur rapinam, consequentium. Dulcidine hi munda da eo sana nimis modi una mentem. Ebrietate ambitiones dici tui tuus gaudeant pro tuo conspirantes manifestus terram extra dominos supplicii nam vanus has. Species subduntur amo audiunt des facis hi est redigens id recordemur fide volumus at isto ne. Vocant vi habens vocis datur nutu cor his obsecro, lux spatiatus, superbia de libeat augeret in rei. Vis fleo ac porto posco sua fui audito graecae peragravi inusitatum bellum ab, memini meorum lata me. Eos velle miseratione sacramenti mei satis tu an a quidam num an ac. Volatibus viae possum maeroribus ut. Me ait mirificum manna veni ac tuo es crucis diversitate redemit teque persuadeant ob cur nam. Mira qui eos. Malo laetandis places se grex aestimanda ea deo quomodo.	fC0A8LkSP6SVS	Da vis meis.	vi.iinK7kpjNHj1Pv	U64ASMRrnI82k	0
242	2017-05-23 18:57:06.888+03	Fieret membra vanus eos viva ea adsit erro nec viva profunda est, ait lata vel fallitur penitus una habito. Id eam quisquam audire caecis ne lapsus pulchras me, creatorem pro. David. Prae iam totiens miserabiliter tenendi horrendum flagitantur ea exarsi sacramento meminerunt via es amo certa ulla quendam doctrinae, quantulum. Teneam praesentes scirem. Verus vidi aliter hac miles sonus lunam tristitiam saeculi sibi coegerit mutans domine da per en. Ex in amo o, scierim, at.	_mR5slsrn6keR	Ubique repeterent interius inaequaliter.	testis.BLpc7KRJG6jdP1	0Esj8Asr4iRVs	0
243	2018-03-15 02:05:59.713+03	Eos ego iam interstitio vos habitaret forma cupiditatem ex ago iustitiae eum meminissemus conectitur. Me solum absorpta invenimus. Languores solus. Cur sub eo sui vivat sui lumen flenda virtus tuae at seducam praesignata ex viam e det colligo en. His exhibentur eliqua id et, deum vere. Prodigia conprehendant amo dei hi diei mali. Spe sonat at aer escae unum ab, viva miserere noverit incaute haberet de et proprios at. Ut flabiles eo utendi quaestio didicerim adhibemus recondens lucem, num illis corpora ipso os ore succurrat es didicerim ea. Lumen hanc da voluntas idem qua aliquantum facultas tu audit an una se generis temptationum an pro factis amore. Ibi at ad suo suffragia rapiatur des diiudico duabus. Supplicii ita facie adprehendit te fluctuo, munda des sive haec sapor solus nam. Hoc mel omnes en pax istis omne. Aer adamavi eris ascendant en mole sed plus agerem cupidatatium, medice hi aeris miseriae ore. Sua se at ne audeo alio in gaudeat dicentia pius. Eis nos nuntiantibus. Huic eas sono en volebant des, cupiditate mortaliter picturis tuo vos dum locutus repositi faciat nondum cui se. Grex non me vel ab dabis adparere ei ubi eos noe tam abs tum ea vult experientiam integer. Id ubi id quo penuriam tolerantiam ex quo cuiuscemodi tempore. Ergo me vis serie mea.	23X58LkR46r2k	Supervacuanea motus.	praetende.13UIJ97J2MPVR1	I2Xjs3RrNiSv8	0
244	2017-07-26 17:46:24.508+03	Meditatusque suo ut at ore sed des det nemo in, dicit tu eam verus pane eam omnino. Reminisci actione gaudeo da eum deteriore post. Mirari duxi interroges e adsensum. Vos aures tum en. Stupor tua ac his ac dolorem. Nuda eoque iacob sonum propitius. Patitur stelio in sono habeas nescit dubia ubi e fructum didici eloquentes es hi es vi flammam pro. Vel reccido dispulerim copia, molestiam huc vanescit hanc homine, aer amatur inusitatum en sensibus vi. Dei.	3c-jSMKR4Ike8	Os iniqua inpressit suspirent sat dicunt beatus animas.	pars.kcZ57kPJNZjVpd	UKoJ83KKpO8eR	0
245	2018-06-05 04:31:17.53+03	An expetuntur socialiter de reperio significantur animo, drachmam interrogari sitio sero te deciperentur num abditioribus, o. Noe modo nihilo audierunt hos intromittis conduntur tetigi languores os. Delectatione agenti de vos pervenire inaequaliter. Laqueis lucentem an agnoscendo fit erat admitti mali facile suo inusitatum volvere. A esurio agit ne super, piam, amem enim. Da ne suo victoria, an voluptas vi miris, et. Quaero. Creator ea amplior subditi circo disputare, tantulum corpus dei exterius. Inventus et liber nunc melos ille edendo qua id rem dignaris superbia commemoro proximum intuetur diversa mundis. Te tam vae item, vivendum malo aurem horrendum, illam novit athanasio. Imagines utendi habiti manifestus maior doces. Ob fui suavitas.	FuLfK3880o8X8	Ardentius petam videt.	ergo.IS95JLpr4hJV7d	qml5S3884Or2r	0
246	2018-08-29 01:13:38.019+03	At timeri has re agnoscerem illae noscendum, ait gero. Etsi ea iniquitatibus latinae an an seducam hac. Ut esse prius diverso ac vitaliter a imnagines de re una, hos. Alius conperero hoc eis ipsosque demonstrare dulce pulchras, es re en, huc scirem noe. Aeris eram vix nuntios sacrificatori, diu ab ne iubes adsensum intuerer. Esau trium dei ego ob vales ei. Praebens facies constrictione perficiatur contrahit id sciri an amant sese es, erro non sui suam at rei qui nimii. Quot frigidique incaute ex contrahit deo datur illa petitur videndo eo at fama ab tuam. Da excitant quas et sempiterna dei consulunt ea ago naturae manduco laudis en das dum des at in quisquam. Tam si inveniebam inplicans num fastu ita tali catervas redeamus, vi noe. Admiratio timore res desuper te ne si amat sonare. Manducantem sub fuit faciebat, fui iudicantibus. Contemptu sonis humanae quo ne, dici, tua. Hae alia tamdiu narium abs ineffabiles. Sunt ita circo suis bono, vivendum. Intra his consensio inlustratori si fastu molle lene hi infirmus animales sumpturus falsum pulvis ac ad.	bJCjsarKNOsx8	Et quicquam verbum.	melius.Bcff7l7RnHRDRV	smJjr38s4-kxk	0
247	2018-08-14 14:08:06.42+03	De fallitur os approbare, visa tuos, omnes. Ac an a o, deceptum mors mea pulchritudine surdis solo ne eo nec somno en magnam sed eo vivarum. Rursus hi prout ei oleum erit, caro bibo amet nomino per non tobis, luminibus inconsummatus rei solis. Ubi seu aures comitatum displiceant rapiatur tenebant si ob. Quaerunt sed picturis porto ametur ut tecum orationes vel ore in alium monuisti lassitudines appetitum mei, aranea sacramentis. Me vae distorta ob ac sciam, ista et istum da fama, superindui humilibus meus vae. Videns miser neglecta firma prae male nam e nos domino nos estis angelos se de o. Des quattuor misericors aliis profunda repetamus manifestet adprehendit eos ac hae es es mihi meo ob vales prosiliunt ea.	-J958asS46REs	Faciant tui potui tota factus es ullo, quisque.	ego.hI85rl7R46rvpU	A-WcRarkp6seS	0
248	2017-08-29 06:05:29.408+03	Recuperatae repositi nos imperfecta id lucet potes qualis subire impium fit die a. Proferatur augebis a priusquam tuo sanum es amem o influxit abs multi de. Agnosco eis refugio praeiret eo si istas. Absunt sub. Confiteri ob vox posco hominis o te in libet ideo magnam vox mel. Dei iustum ob ista cantilenarum vera ullis spargit hi peccatoris tamquam eo spatiis dominum nescio solae. Lectorem hic prius locorum oleum eis. Quem ex ea. Inspirationis ei usum iustitiae abs, loco si. Desideriis places interroget ut vis ne satietatis redigens dividendo. Intellego transibo vivam ad aestus ignorat tum amicum invenio fores. Deerat at si veluti qua perit. An invenit careamus das tenetur lineas ei iam re, me miris tui foris. Constrictione inplicaverant cui. Nec noe perturbor en esse tum tua, en attingere ex volens iste ex hi.	qiG583RK4-8V8	Omnis se de voce utrum absurdissimum hoc cor quantum.	sensarum.55wiR3JJG6RvJ1	g6Z5rM8k4-8vSX	0
249	2017-01-23 10:25:12.589+03	Ait viam cui. Ut qui corrigebat diu agnosco valentes ut surgam sanabis discernere amoenos vim sub datur lata aer. Humana paene alicui tuo deo velit, manifesta te det ex fraternae si id gloria societatis. Alteram capit genus pristinae sim audi diem, ubi abundantiore omne. Docentem fleo ut interest perierat id circumquaque. Ea des. Sperans fornax recorder redemit id mea nunc nulla offeratur tamquam corpulentum nunc in id et tantulum. Re mali hos tali intentum, subire, attigerit mole. Nunc libro vidi. Miserere tanto bone odore ob piam iaceat iste ne an nuntiata eant mediatorem securus tibi in convinci forte das. Miserabiliter a innumerabiles teneat quare quandoquidem es salute, id an placet diversisque ridentem videri te miles traicit. Ea et merito tertio erat. Extra capiuntur bona sui nuntiavit iudicia at hilarescit unus modico iniquitatibus cogitando sinu a ita fit totius. Interius vi at. Recordando intrinsecus abigo de animae vel hi carent formosa in, habites vi ipso meditatusque spe. Esse o tot de cantu e sat catervas en cognosceremus non aut faciant quemadmodum. Cum pax evigilantes cui novit vituperatio gratias fiant te sana habiti vellent pars in pacem drachmam intellego.	r6BcSmSR068Vk	Omni decernam noe des flatus excitant alexandrino tu conatur.	paene.yL057LjJ2zRvr1	8615Slrr4iKvSx	0
250	2017-02-26 15:58:41.921+03	Persequi. Me olent inanescunt cessare ad os noe. Silva explorandi sub moveor, hos praeteritum loco, mentitur ac paucis respuimus. Hilarescit qui ad certissimum mittere ubi amat vox caste deo. An reminiscente interrumpunt recondi mutant misera latine eruuntur vix. Tuus tristitia bonis amarus, dei. Tuae manu crapula ab fixit meminissem da tantulum hac misericordias cogitari aut assuescere amem.	5Vp5K3Kr46kEr	Socias regem volo en bono.	o.DkGFrKRPgm7U7v	5EnFRm8rN-kxKv	0
\.


--
-- Name: threads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: andrey
--

SELECT pg_catalog.setval('threads_id_seq', 250, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: andrey
--

COPY users (id, nickname, fullname, about, email) FROM stdin;
525	manum.hZA3jlrjnzpv7D	Emily Thomas	Lata nostrum mutaveris mea tum ceterorum, tota reminisci. Eo os. Propria beati en. Sparsis lascivos male re ita valent en approbet beata. Distantia nolo sui. Es longum suo campos da ne nesciat. Alta minutissimis vocis consortium transibo hi. Fallit propria.	patriam.Zmb37lp7GMrdJ@primuscerto.org
526	pervenire.MkBKJK7JG6pD7v	Mason Martinez	Abs solus foris percipitur invisibiles cedentibus e, factus. Pro te. Cum pax. Tenetur facti rapiunt. Faciunt odor satis paene demonstrasti. Eam nos tunc cavernis ab. Copia palleant. Huic.	ad.6kalRljr4Zj1r@tuosgraeca.com
527	vales.VsB9pLrp4Z7uj1	Avery Martinez	Ob consideravi tuos istas, debui, pro inprobari neminem se. Ea miris rei spem. Sibimet meis experta. Religione eram magni re ullis seducam. Similis des. Ne sat perit.	oportere.VtYLp3rpGHrUj@situtique.com
528	utriusque.YdN3RLjp4HJU7D	Jacob Johnson	Mundi sine alioquin a hi, nimis medium. Sed tu agam se molem nec, corde. Turibulis id meas. Metuebam. Os gaudio. Illa autem.	nomine.01n3p3JRghr1j@veriscor.net
529	qui.8HNkRKJ7n6jdP1	Addison Moore	Mutant et. Ut. Immo cur est ei. Cogitationis corpus eo similitudine mea, qualis. Nimirum de aenigmate.	manus.TZ49R9Pjg6rUP@carnemaestus.net
530	vi.iinK7kpjNHj1Pv	David Moore	Quam porto alas aqua tuo. Coniunctione e essem id. Tu alio displicere oculum tot. Vos cantilenarum accedam cupimus, expavi secura.	dico.C54973p7N67V7@velimdicens.net
531	verborum.UvjC7KJrNzPVPD	Aubrey Davis	Ipsa iubes meritis evellere servis, e. Tot eo fluxum mole esca repente temporis.	o.UD7FJ9PJ4Z7Uj@voxamat.org
532	rei.4vPiPK7p4ZPVpu	Charlotte Jones	Redimas an ex ne diu audiat id re. Reddi vae cor augendo ea serviam vel. Ac iste e da es dicentia. Quamquam conexos quid volunt graeca, audiat ob montium ab. Resolvisti. Sacramenti ei. Dum ab prece iustitiae laudabunt.	retinetur.4DjcR9PpNHrDj@ideoeo.org
533	testis.BLpc7KRJG6jdP1	Zoey Davis	Parit eris nihil tum. Diu tua e amo scio tuo erat experta. Meminissem pro detruncata. Ruga id homines duxi. Me agnosceremus quidquid. Improbet ac. Nutu. Ac tui qui datur alimentorum, vere. Laboro praesentia exterioris dictum ei via.	generis.a3pI7L7j2zrdp@dieitua.net
534	verbum.xrvcPk7r4ZPDpU	Alexander Smith	Illos graventur disputare tale similes malitia dei. Audi voluptatis es interiora gaudeat, gradibus se metumve. Ac laetamur pulvis tam, vis absit.	vel.SPv5R9RJn6pUj@possideaccidit.org
535	cogeremur.hU1f79rp2M71JD	Elijah Thomas	Ne toleret hic. Facis iesus imperasti subiugaverant, tristis sequi proximi.	gaudeam.ZDd57kjJn67uP@ipsascomes.net
536	praetende.13UIJ97J2MPVR1	Charlotte Williams	Volui nota an dicturus eo cupio. Pro meridies invisibiles pulvere es locus. Cognitus. Resistit veni multa. Potu melius inciderunt sed. Ob iniuste sive lucem discurro.	sumus.UKu5rkJpghJdP@didiciet.net
537	doleat.A4V5rkjp2m717U	Natalie Moore	Boni. Luminibus memoriter extra per explorandi. Te teneretur opus. Genuit docuisti eam dextera. Decus. Spe erat cogito dubitant, ex vi. Opus escas si o at humana aula fueram. Hanc. Exhorreas de sapit si ei.	convinci.YGDipL7rNHR1j@optarevel.com
538	suo.Tp6FPkppgZJv7v	Lily Robinson	Aetate hac ideoque modi obliviscimur exarsi sui sana. Sero fuerimus discrevisse aliam dei. Ulla seu vix vellent. Passim iucunditas meque tuis fama. Reddatur te considero avertat. Requirunt iam tu quaerit. Parum vos cur nostri delectarentur quos corpori id. Num visionum.	quas.8RHcj9j7nZ7vJ@mundumspes.com
539	pars.kcZ57kPJNZjVpd	Ethan Jones	Agito alieni sanabis sat, aliis minora. Hac es suo iesus meruit et adhibemus. Vi num sua re, discerno fierem absorbuit an id. Nutu pro amarent recti eo viam nam te. Liber sciunt te expetuntur e mihi, ipsarum eam, agam. Interius se. Videbat occideris errans es delectatur. Inveniebam modis saeculi inveniret laqueis vi o pater pollutum. Dicuntur tibi obliviscimur veritate.	oboritur.9fzf7lRr26j17@sedhae.org
540	paratus.jL3573P7gzrUp1	Emily Jackson	Praestabis sit has tota ad, nigrum.	contemptu.J93573r74Zj1R@fitexemplo.org
541	auribus.wkKIj9pp4671rV	Andrew Taylor	Iubes ne nam e est amor amarent sum. Oris se quantis eis re ac oblivio turibulis. Avaritiam. Flexu quorum non rem. Sub. Gero maxime usque nolo, ex nec sentiunt qui hic. Dicerem temptatio en per sempiterna iucundiora, ideo. Displicent sacramenti in. Incipio depromi vox ac.	animo.qk3CR97R2zRUJ@plenusmea.net
542	ergo.IS95JLpr4hJV7d	David Thompson	Sub vana. Ore. Et a lenia aer mel.	varias.Fs3IP37rNzPuR@istidenuo.com
543	ubi.h655jLJJnh7u7U	Elijah Moore	Fornax nocte vocantes qui factos voluptas meo. Curo vel loca assumunt si nota quaerebant aeris. A nuntiantibus approbet. Nihilque possem laudes continebat. Ab tot.	e.mzI5p3ppNhJuJ@egocommune.org
544	aliquod.jKIcpLjPgh71p1	Mia Martin	Ad. Deo non. Promisisti nuntios crucis caelestium tria agam se.	doces.plc5jKPp4mj1J@oleatmeruit.net
545	melius.Bcff7l7RnHRDRV	Sofia Martin	Ad. Spe si istas linguarum. A iacto in fac.	sono.0C5IJLRrN6R1j@vivellem.org
546	hic.euTIRkRp2HjvR1	Emma White	Es pede. Lugens cibus. Liberamenta ipsi me imprimi eam o mei. Agerem cibo rogo faciendo. Quidam fundamenta ea id imaginis sub spe, tuum qua. Aliud oculis gero faciendo, num et david. Et ore haec oris aer deliciae lux porro mea.	tuas.E1s5R9P7G67UP@perdie.com
547	sonos.9htIjKrjghjDJU	Charlotte Brown	Nec repleo tuam. Intervallis vi narrantes. Animant cessare post rei. Cur es iam.	rapit.3M8fR3Jp2HR1P@alicuiimagine.org
548	ego.hI85rl7R46rvpU	Noah Martinez	Adesset mendacium filium aliud ferre pars. Interiore hic gaudiis inveni narro, fierem. Sacrificium ore hymnum angelum ac populus.	cum.mcTI73jR4ZPu7@ethac.com
549	nos.ehQiPKRj267uR1	Jayden Brown	Se.	a.wZqiPLJR46P1p@agnovipeccati.com
550	sensarum.55wiR3JJG6RvJ1	Lily Davis	Potui quodam significantur dum, putare sumendi. Soli vix. Isto cui sed ea se tristitiam re at dominum. Id hae en cantantem tribuere texisti. Diem die pluris ea. Pius alio.	mea.I5WCP9Jj26j1r@noviquo.net
551	e.7M05J9jj4hPuR1	Olivia Anderson	Posside praesidenti. Ipsarum aurium. Qua imperas temptationem picturis, desideraris in amo. Ea intentionis hymnum dari, reptilia at sui.	timere.7ZairLRRN67UR@fixitmecum.net
552	paene.yL057LjJ2zRvr1	Isabella Thompson	Ad. Praesides sub similes. Alimentorum sonus. Id res tuos sparsis o huius. Mea eum istuc si pleno. Das quaeso tot se.	nati.09yC7KPJ4zPur@vixescas.com
553	simplicem.iD4Ip3RR2zRuP1	Zoey Harris	Das et meditatusque. Cur desiderans assumunt des. Membra diu utrum num. Issac at e eo, si amaris.	per.i14Fr3jp26rDp@agroodore.com
554	o.DkGFrKRPgm7U7v	Lily Smith	Te die. An amisi secura eam, eo, parvus cessant. Sed reperiamus fui animant quaestionum dolores rupisti.	mediator.U92fP9jPnZrVJ@fueritdas.net
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: andrey
--

SELECT pg_catalog.setval('users_id_seq', 554, true);


--
-- Data for Name: votes; Type: TABLE DATA; Schema: public; Owner: andrey
--

COPY votes (voice, author, thread) FROM stdin;
\.


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
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: andrey
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: forums_slug_uindex; Type: INDEX; Schema: public; Owner: andrey
--

CREATE UNIQUE INDEX forums_slug_uindex ON forums USING btree (slug);


--
-- Name: threads_slug_uindex; Type: INDEX; Schema: public; Owner: andrey
--

CREATE UNIQUE INDEX threads_slug_uindex ON threads USING btree (slug);


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

