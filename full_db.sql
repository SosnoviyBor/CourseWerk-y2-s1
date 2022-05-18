-- phpMyAdmin SQL Dump
-- version 4.6.6deb4+deb9u2
-- https://www.phpmyadmin.net/
--
-- Хост: localhost
-- Время создания: Май 18 2022 г., 10:54
-- Версия сервера: 5.7.34
-- Версия PHP: 7.0.33-0+deb9u12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `cw`
--

DELIMITER $$
--
-- Процедуры
--
CREATE DEFINER=`boryaxta`@`localhost` PROCEDURE `crewProductivity` (IN `dateFrom` DATE)  READS SQL DATA
    SQL SECURITY INVOKER
BEGIN
	SELECT p.name, p.surname, j.name AS position, c.team_id, count(p.id) AS orders_taken
    FROM orders o
    LEFT JOIN trips t ON o.trip_id = t.id
    LEFT JOIN crews c ON t.crew_id = c.team_id
    LEFT JOIN jobs j ON c.post_id = j.id
    LEFT JOIN persons p ON c.person_id = p.id
    WHERE DATE(o.time_ordered) >= dateFrom
    GROUP BY p.id
    ORDER BY count(p.id) DESC;
END$$

CREATE DEFINER=`boryaxta`@`localhost` PROCEDURE `employeeProductivity` (IN `dateFrom` DATE)  READS SQL DATA
    SQL SECURITY INVOKER
BEGIN
	SELECT p.name, p.surname, j.name AS position, e.office_id, count(p.id) AS orders_taken
    FROM orders o
    LEFT JOIN trips t ON o.trip_id = t.id
    LEFT JOIN employees e ON t.employee_id = e.id
    LEFT JOIN jobs j ON e.position_id = j.id
    LEFT JOIN persons p ON e.person_id = p.id
    WHERE DATE(o.time_ordered) >= dateFrom
    GROUP BY p.id
    ORDER BY count(p.id) DESC;
END$$

--
-- Функции
--
CREATE DEFINER=`boryaxta`@`localhost` FUNCTION `getFullCargoCost` (`id` INT) RETURNS INT(11) READS SQL DATA
    DETERMINISTIC
    SQL SECURITY INVOKER
    COMMENT 'Input cargo_id'
BEGIN
	SELECT c.tariff_id, c.amount INTO @tid, @amount FROM cargo c WHERE c.id = id;
    SELECT t.cost_per_container INTO @cost FROM tariffs t WHERE t.id = @tid;
    RETURN @amount * @cost;
END$$

CREATE DEFINER=`boryaxta`@`localhost` FUNCTION `getFullName` (`id` INT) RETURNS VARCHAR(50) CHARSET utf8 READS SQL DATA
    DETERMINISTIC
    SQL SECURITY INVOKER
BEGIN
	SELECT p.name, p.surname INTO @name, @surname FROM persons p WHERE p.id = id;
    RETURN CONCAT(@name, " ", @surname);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `cargo`
--

CREATE TABLE `cargo` (
  `id` int(11) NOT NULL,
  `amount` int(11) DEFAULT NULL,
  `tariff_id` int(11) NOT NULL,
  `description` text,
  `src_id` int(11) NOT NULL,
  `dst_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `cargo`
--

INSERT INTO `cargo` (`id`, `amount`, `tariff_id`, `description`, `src_id`, `dst_id`) VALUES
(1, 86, 1, 'Salty water', 11, 1),
(2, 1679, 3, 'Rubic\'s cubes', 5, 3),
(3, 54, 1, 'Pencils', 3, 2),
(4, 87, 1, 'Mobile phones', 2, 9),
(5, 11097, 4, 'Cars', 5, 9),
(6, 14996, 4, 'Bananas', 11, 8),
(7, 978, 2, '[REDACTED]', 11, 1),
(8, 6352, 4, 'Cobblestone', 6, 4),
(9, 630, 2, 'Bolts', 6, 4),
(10, 24, 1, 'Water for my reports', 4, 10);

-- --------------------------------------------------------

--
-- Структура таблицы `contragent`
--

CREATE TABLE `contragent` (
  `id` int(11) NOT NULL,
  `company` varchar(50) NOT NULL,
  `email` varchar(50) DEFAULT NULL,
  `phone_number` varchar(16) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `contragent`
--

INSERT INTO `contragent` (`id`, `company`, `email`, `phone_number`) VALUES
(1, 'SCP Foundation', 'elena2303@eeetivsc.com', '+380-395-558-021'),
(2, 'Umbrella Corp.', 'artyomlarin@nkgursr.com', '+380-505-554-685'),
(3, 'Roshen', 'svikiro@packiu.com', '+380-395-557-216'),
(4, 'Bezdari INC.', 'vskruglov@lohpcn.com', '+380-505-550-491'),
(5, 'Apple', 'bugaevdenis2011@riniiya.com', '+380-395-555-658'),
(6, 'Steve Minecraft', 'chrisso67@yandex.cfd', '+380-249-555-591'),
(7, 'Deez Nuts', 'pauloap12@nalsci.com', '+380-512-955-576');

-- --------------------------------------------------------

--
-- Структура таблицы `countries`
--

CREATE TABLE `countries` (
  `id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `countries`
--

INSERT INTO `countries` (`id`, `name`) VALUES
(1, 'Ukraine'),
(2, 'China'),
(3, 'Singapore'),
(4, 'South Korea'),
(5, 'Hong Kong'),
(6, 'Nederland');

-- --------------------------------------------------------

--
-- Структура таблицы `crews`
--

CREATE TABLE `crews` (
  `team_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `crews`
--

INSERT INTO `crews` (`team_id`, `person_id`, `post_id`) VALUES
(1, 4, 1),
(2, 13, 1),
(3, 23, 1),
(1, 8, 2),
(2, 18, 2),
(1, 6, 3),
(2, 14, 3),
(1, 9, 4),
(1, 11, 4),
(1, 12, 4),
(2, 15, 4),
(2, 17, 4),
(2, 19, 4),
(2, 20, 4),
(2, 21, 4),
(2, 22, 4),
(1, 10, 5),
(2, 16, 5);

-- --------------------------------------------------------

--
-- Структура таблицы `employees`
--

CREATE TABLE `employees` (
  `id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `position_id` int(11) NOT NULL,
  `office_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `employees`
--

INSERT INTO `employees` (`id`, `person_id`, `position_id`, `office_id`) VALUES
(1, 3, 8, 1),
(2, 5, 9, 1),
(3, 7, 7, 1),
(4, 1, 6, 1),
(5, 2, 6, 1);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `free_crewmembers`
-- (See below for the actual view)
--
CREATE TABLE `free_crewmembers` (
`team_id` int(11)
,`person_id` int(11)
,`post_id` int(11)
,`last_trip` int(11)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `free_ships`
-- (See below for the actual view)
--
CREATE TABLE `free_ships` (
`id` int(11)
,`full_name` varchar(50)
,`codename` varchar(25)
,`carryweight` int(11)
,`last_trip` int(11)
);

-- --------------------------------------------------------

--
-- Структура таблицы `jobs`
--

CREATE TABLE `jobs` (
  `id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL,
  `salary` int(11) NOT NULL COMMENT 'In USD'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `jobs`
--

INSERT INTO `jobs` (`id`, `name`, `salary`) VALUES
(1, 'captain', 40000),
(2, 'chief mate', 30000),
(3, 'mechanic', 25000),
(4, 'sailor', 20000),
(5, 'cook', 30000),
(6, 'operator', 15000),
(7, 'janitor', 10000),
(8, 'chief', 40000),
(9, 'deputy chief', 30000);

-- --------------------------------------------------------

--
-- Структура таблицы `offices`
--

CREATE TABLE `offices` (
  `id` int(11) NOT NULL,
  `name` varchar(25) DEFAULT NULL,
  `country_id` int(11) NOT NULL,
  `city` varchar(25) NOT NULL,
  `adress` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `offices`
--

INSERT INTO `offices` (`id`, `name`, `country_id`, `city`, `adress`) VALUES
(1, 'Bird\'s nest', 1, 'Odessa', 'Somewhere near sea idk');

-- --------------------------------------------------------

--
-- Структура таблицы `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `cargo_id` int(11) NOT NULL,
  `trip_id` int(11) NOT NULL,
  `contragent_id` int(11) NOT NULL,
  `time_ordered` datetime DEFAULT NULL,
  `deadline` datetime DEFAULT NULL,
  `time_delivered` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `orders`
--

INSERT INTO `orders` (`id`, `cargo_id`, `trip_id`, `contragent_id`, `time_ordered`, `deadline`, `time_delivered`) VALUES
(1, 1, 2, 4, '2021-09-30 19:32:34', '2022-01-01 00:00:00', '2021-11-11 07:25:11'),
(2, 2, 2, 6, '2021-09-18 13:56:43', '2022-01-01 00:00:00', '2021-12-01 06:57:45'),
(3, 3, 2, 7, '2021-09-20 21:48:52', '2022-01-01 00:00:00', '2021-11-13 04:19:06'),
(4, 4, 2, 5, '2021-10-05 17:31:45', '2022-01-01 00:00:00', '2021-12-04 19:26:17'),
(5, 5, 2, 2, '2021-09-13 05:35:35', '2022-01-01 00:00:00', '2021-11-25 01:03:32'),
(6, 6, 3, 1, '2021-10-04 23:13:39', '2022-02-01 00:00:00', '2021-11-24 02:19:48'),
(7, 7, 4, 1, '2021-11-03 15:40:32', '2022-03-01 00:00:00', '2021-12-25 17:17:35'),
(8, 8, 5, 6, '2021-11-05 18:37:48', '2022-03-01 00:00:00', '2021-12-07 08:16:50'),
(9, 9, 5, 3, '2021-11-03 12:39:01', '2022-03-01 00:00:00', NULL),
(10, 10, 5, 4, '2021-11-28 10:25:04', '2022-03-01 00:00:00', NULL);

--
-- Триггеры `orders`
--
DELIMITER $$
CREATE TRIGGER `time_oredered_setter` BEFORE INSERT ON `orders` FOR EACH ROW BEGIN
	IF NEW.time_ordered IS NULL THEN
    	SET NEW.time_ordered = NOW();
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `persons`
--

CREATE TABLE `persons` (
  `id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL,
  `surname` varchar(25) NOT NULL,
  `date_of_birth` date NOT NULL,
  `country_id` int(11) NOT NULL,
  `city` varchar(25) NOT NULL,
  `adress` varchar(100) DEFAULT NULL,
  `phone_number` varchar(16) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `persons`
--

INSERT INTO `persons` (`id`, `name`, `surname`, `date_of_birth`, `country_id`, `city`, `adress`, `phone_number`, `email`) VALUES
(1, 'Jonatan', 'Joestar', '1991-10-02', 1, 'Kyiv', 'Marksa K. Vul., bld. 29/A', '+380-635-553-463', 'eyezonme33@maileronline.club'),
(2, 'Robert', 'Speedwagon', '2000-02-22', 1, 'Kyiv', 'Postysheva Ul., bld. 9, appt. 146', '+380-505-559-586', 'fanking4@chaatalop.site'),
(3, 'Will', 'Zeppeli', '1990-09-07', 1, 'Odessa', 'Leninskiy Pr., bld. 1', '+380-635-558-134', 'fadex2black@ibelnsep.com'),
(4, 'Joeseph', 'Joestar', '1987-04-05', 1, 'Lviv', 'Khalturina S. Ul., bld. 4, appt. 27', '+380-505-559-700', 'swatton@neaeo.com'),
(5, 'Caesar', 'Zeppeli', '1991-02-26', 1, 'Odessa', 'Rilskogo Vul., bld. 7, appt. 54', '+380-505-557-751', 'mccraycsi@azwv.site'),
(6, 'Rudol', 'Stroheim', '1981-12-19', 1, 'Zhytomyr', 'Dombrovskogo Vul., bld. 4, appt. 34', '+380-645-655-506', 'mattsecrest3590@pfmretire.com'),
(7, 'Lisa', 'Lisa', '1983-05-23', 1, 'Odessa', '1 Konnoy Armii Ul., bld. 82, appt. 11', '+380-395-559-598', 'maninma@emailaing.com'),
(8, 'Jotaro', 'Kujo', '2000-03-18', 1, 'Zhytomyr', 'Zhukova Marshala Pr., bld. 10/D, appt. 44', '+380-395-558-279', 'amidagu@txtv.site'),
(9, 'Kakyoin', 'Noriaki', '1998-09-15', 1, 'Zhytomyr', 'Blazhevicha Ul., bld. 25, appt. 8', '+380-505-554-565', 'laamo28@boranora.com'),
(10, 'Muhammad', 'Avdol', '1989-11-02', 1, 'Donbass', 'Novoselnaya Ul., bld. 9, appt. 3', '+380-376-455-536', 'asto2012@johonkemana.com'),
(11, 'Jean Pierre', 'Polnareff', '1994-10-17', 1, 'Uzhgorod', 'Keletska, bld. 41, appt. 5', '+380-635-554-094', 'dogport@eoooodid.com'),
(12, 'Iggy', 'Pop', '1987-07-15', 1, 'Lviv', 'Vul. Boguna, bld. 57', '+380-395-557-754', 'a9cxndxzg@pfmretire.com'),
(13, 'Josuke', 'Higashikata', '1981-12-14', 1, 'Zhytomyr', 'Glinki, Vul., bld. 7, appt. 10', '+380-385-555-588', 'arthas84@facebook-net.ml'),
(14, 'Okuyasu', 'Nijimura', '1999-12-09', 1, 'Zhytomyr', 'Gayok Mkrn., bld. 268, appt. 46', '+380-505-558-954', 'tomjangladden@riniiya.com'),
(15, 'Koichi', 'Hirose', '1980-09-26', 1, 'Zhytomyr', 'Marshala Rybalko Ul., bld. 49, appt. 144', '+380-635-551-688', 'akilsana@gmailya.com'),
(16, 'Rohan', 'Kishibe', '1999-07-31', 1, 'Uzhgorod', 'Saksaganskogo Ul., bld. 54, appt. 24', '+380-146-155-572', 'patrickrden@antawii.com'),
(17, 'Shigekiyo', 'Yangu', '1980-03-04', 1, 'Yangu', '40 Let Oktyabrya Ul., bld. 183/A, appt. 40', '+380-635-558-279', 'moug87@archnicebook.site'),
(18, 'Giorno', 'Giovanna', '1987-11-10', 1, 'Zaporizhya', 'Melnikova Ul., bld. 22', '+380-509-255-535', 'bugenhag@kimsangun.com'),
(19, 'Bruno', 'Bucciarati', '1983-03-20', 1, 'Zaporizhya', 'Krasnykh Maevshchikov, bld. 11, appt. 89', '+380-395-551-327', 'cherry190584@kimsangun.com'),
(20, 'Guido', 'Mista', '1997-12-12', 1, 'Zaporizhya', 'Starodubska Vul., bld. 22', '+380-635-558-862', 'frankyboybt@icnwte.com'),
(21, 'Leone', 'Abbachio', '1991-05-11', 1, 'Zaporizhya', 'Sverdlova Ul., bld. 68, appt. 108', '+380-451-255-539', 'hanminhtun50@debb.me'),
(22, 'Narancia', 'Ghirga', '1990-08-20', 1, 'Zaporizhya', 'Nakhіmova, Vul., bld. 34, appt. 38', '+380-505-555-925', 'elena2303@eeetivsc.com'),
(23, 'dummy', 'yeah', '2021-12-01', 1, 'dummy city', 'dummy street', '+111-111-111-111', 'dummy@mail.dum');

--
-- Триггеры `persons`
--
DELIMITER $$
CREATE TRIGGER `validate_email_insert` BEFORE INSERT ON `persons` FOR EACH ROW validate_email_update: BEGIN
IF NEW.email IS NULL THEN
	LEAVE validate_email_update;
END IF;
IF NEW.email NOT LIKE "%@%.%" THEN
	SIGNAL SQLSTATE "45000"
    SET MESSAGE_TEXT = "Wrong email";
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `validate_email_update` BEFORE UPDATE ON `persons` FOR EACH ROW validate_email_update: BEGIN
IF NEW.email = OLD.email THEN
	LEAVE validate_email_update;
END IF;
IF NEW.email NOT LIKE "%@%.%" THEN
	SIGNAL SQLSTATE "45000"
    SET MESSAGE_TEXT = "Wrong email";
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `validate_phone_insert` BEFORE INSERT ON `persons` FOR EACH ROW validate_phone_update: BEGIN
IF NEW.phone_number IS NULL THEN
	LEAVE validate_phone_update;
END IF;
IF NEW.phone_number NOT LIKE "+_-___-___-___" AND
   NEW.phone_number NOT LIKE "+__-___-___-___" AND
   NEW.phone_number NOT LIKE "+___-___-___-___" THEN
	SIGNAL SQLSTATE "45000"
    SET MESSAGE_TEXT = "Wrong phone number";
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `validate_phone_update` BEFORE UPDATE ON `persons` FOR EACH ROW validate_phone_update: BEGIN
IF NEW.phone_number = OLD.phone_number THEN
	LEAVE validate_phone_update;
END IF;
IF NEW.phone_number NOT LIKE "+_-___-___-___" AND
   NEW.phone_number NOT LIKE "+__-___-___-___" AND
   NEW.phone_number NOT LIKE "+___-___-___-___" THEN
	SIGNAL SQLSTATE "45000"
    SET MESSAGE_TEXT = "Wrong phone number";
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `ports`
--

CREATE TABLE `ports` (
  `id` int(11) NOT NULL,
  `country_id` int(11) NOT NULL,
  `city` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `ports`
--

INSERT INTO `ports` (`id`, `country_id`, `city`) VALUES
(1, 2, 'Shanghai'),
(2, 3, 'Singapore'),
(3, 2, 'Ninbo-Zhoushan'),
(4, 2, 'Shenzhen'),
(5, 2, 'Guangzou'),
(6, 4, 'Busan'),
(7, 2, 'Qingdao'),
(8, 5, 'Hong Kong'),
(9, 2, 'Tianjin'),
(10, 6, 'Rotterdam'),
(11, 1, 'Odessa');

-- --------------------------------------------------------

--
-- Структура таблицы `route`
--

CREATE TABLE `route` (
  `id` int(11) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `sequence_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `route`
--

INSERT INTO `route` (`id`, `name`, `sequence_id`) VALUES
(1, 'Guangzou - Tianjin', 1),
(2, 'Singapore', 2),
(3, 'Shanghai', 3),
(4, 'Busan - Rotterdam', 4);

-- --------------------------------------------------------

--
-- Структура таблицы `route_sequence`
--

CREATE TABLE `route_sequence` (
  `id` int(11) NOT NULL,
  `arrival_order` int(11) NOT NULL,
  `port_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `route_sequence`
--

INSERT INTO `route_sequence` (`id`, `arrival_order`, `port_id`) VALUES
(1, 3, 1),
(3, 1, 1),
(1, 4, 2),
(1, 2, 3),
(4, 2, 4),
(1, 1, 5),
(4, 1, 6),
(2, 1, 8),
(1, 5, 9),
(4, 3, 10),
(1, 0, 11),
(2, 0, 11),
(3, 0, 11),
(4, 0, 11);

-- --------------------------------------------------------

--
-- Структура таблицы `ships`
--

CREATE TABLE `ships` (
  `id` int(11) NOT NULL,
  `full_name` varchar(50) NOT NULL,
  `codename` varchar(25) DEFAULT NULL,
  `carryweight` int(11) NOT NULL COMMENT 'In TEU'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `ships`
--

INSERT INTO `ships` (`id`, `full_name`, `codename`, `carryweight`) VALUES
(1, 'Maersk Mc-Kinney Moller', 'The Forbidden', 18238),
(2, 'CMA CGM Christophe Colomb', 'Colombus', 16698),
(3, 'MSC Kalina', 'Kalinka', 16380);

-- --------------------------------------------------------

--
-- Структура таблицы `tariffs`
--

CREATE TABLE `tariffs` (
  `id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL,
  `description` text,
  `cost_per_container` double NOT NULL COMMENT 'In USD'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `tariffs`
--

INSERT INTO `tariffs` (`id`, `name`, `description`, `cost_per_container`) VALUES
(1, 'Light', 'For less than 100 containers', 200),
(2, 'Classic', 'For between 100 and 1000 containers', 160),
(3, 'Heavy', 'For between 1000 and 5000 containers', 140),
(4, 'Heavy++', 'For more than 5000 containers', 110),
(5, 'Rent a ship', 'Whole ship is completely dedicated for your cargo. You can rent a ship at least 1 month in advance. Price may vary from ship to ship', 220);

-- --------------------------------------------------------

--
-- Структура таблицы `trips`
--

CREATE TABLE `trips` (
  `id` int(11) NOT NULL,
  `crew_id` int(11) NOT NULL,
  `ship_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `route_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `trips`
--

INSERT INTO `trips` (`id`, `crew_id`, `ship_id`, `employee_id`, `route_id`) VALUES
(2, 1, 1, 2, 1),
(3, 2, 2, 4, 2),
(4, 1, 3, 5, 3),
(5, 2, 2, 4, 4);

-- --------------------------------------------------------

--
-- Структура для представления `free_crewmembers`
--
DROP TABLE IF EXISTS `free_crewmembers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`boryaxta`@`localhost` SQL SECURITY INVOKER VIEW `free_crewmembers`  AS  select `c`.`team_id` AS `team_id`,`c`.`person_id` AS `person_id`,`c`.`post_id` AS `post_id`,`c`.`last_trip` AS `last_trip` from (((select `c`.`team_id` AS `team_id`,`c`.`person_id` AS `person_id`,`c`.`post_id` AS `post_id`,max(`t`.`id`) AS `last_trip` from (`crews` `c` left join `trips` `t` on((`t`.`crew_id` = `c`.`team_id`))) group by `c`.`person_id`)) `c` left join (select `orders`.`id` AS `id`,`orders`.`cargo_id` AS `cargo_id`,`orders`.`trip_id` AS `trip_id`,`orders`.`contragent_id` AS `contragent_id`,`orders`.`time_ordered` AS `time_ordered`,`orders`.`deadline` AS `deadline`,`orders`.`time_delivered` AS `time_delivered` from `orders` where isnull(`orders`.`time_delivered`) group by `orders`.`trip_id`) `o` on((`o`.`trip_id` = `c`.`last_trip`))) where isnull(`o`.`deadline`) ;

-- --------------------------------------------------------

--
-- Структура для представления `free_ships`
--
DROP TABLE IF EXISTS `free_ships`;

CREATE ALGORITHM=UNDEFINED DEFINER=`boryaxta`@`localhost` SQL SECURITY INVOKER VIEW `free_ships`  AS  select `s`.`id` AS `id`,`s`.`full_name` AS `full_name`,`s`.`codename` AS `codename`,`s`.`carryweight` AS `carryweight`,`s`.`last_trip` AS `last_trip` from (((select `s`.`id` AS `id`,`s`.`full_name` AS `full_name`,`s`.`codename` AS `codename`,`s`.`carryweight` AS `carryweight`,max(`t`.`id`) AS `last_trip` from (`ships` `s` left join `trips` `t` on((`t`.`ship_id` = `s`.`id`))) group by `s`.`id`)) `s` left join (select `orders`.`id` AS `id`,`orders`.`cargo_id` AS `cargo_id`,`orders`.`trip_id` AS `trip_id`,`orders`.`contragent_id` AS `contragent_id`,`orders`.`time_ordered` AS `time_ordered`,`orders`.`deadline` AS `deadline`,`orders`.`time_delivered` AS `time_delivered` from `orders` where isnull(`orders`.`time_delivered`) group by `orders`.`trip_id`) `o` on((`o`.`trip_id` = `s`.`last_trip`))) where isnull(`o`.`deadline`) ;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `cargo`
--
ALTER TABLE `cargo`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tariff_id` (`tariff_id`),
  ADD KEY `src_id` (`src_id`),
  ADD KEY `dst_id` (`dst_id`);

--
-- Индексы таблицы `contragent`
--
ALTER TABLE `contragent`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `countries`
--
ALTER TABLE `countries`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `crews`
--
ALTER TABLE `crews`
  ADD PRIMARY KEY (`team_id`,`person_id`),
  ADD KEY `person_id` (`person_id`),
  ADD KEY `post_id` (`post_id`);

--
-- Индексы таблицы `employees`
--
ALTER TABLE `employees`
  ADD PRIMARY KEY (`id`),
  ADD KEY `person_id` (`person_id`),
  ADD KEY `position_id` (`position_id`),
  ADD KEY `office_id` (`office_id`);

--
-- Индексы таблицы `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `offices`
--
ALTER TABLE `offices`
  ADD PRIMARY KEY (`id`),
  ADD KEY `country_id` (`country_id`);

--
-- Индексы таблицы `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`,`cargo_id`,`trip_id`),
  ADD KEY `cargo_id` (`cargo_id`),
  ADD KEY `order_id` (`trip_id`),
  ADD KEY `FK_contragent_id` (`contragent_id`);

--
-- Индексы таблицы `persons`
--
ALTER TABLE `persons`
  ADD PRIMARY KEY (`id`),
  ADD KEY `country_id` (`country_id`),
  ADD KEY `qwerty` (`date_of_birth`);

--
-- Индексы таблицы `ports`
--
ALTER TABLE `ports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `country_id` (`country_id`);

--
-- Индексы таблицы `route`
--
ALTER TABLE `route`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `route_sequence`
--
ALTER TABLE `route_sequence`
  ADD PRIMARY KEY (`id`,`arrival_order`),
  ADD KEY `port_id` (`port_id`);

--
-- Индексы таблицы `ships`
--
ALTER TABLE `ships`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `tariffs`
--
ALTER TABLE `tariffs`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `trips`
--
ALTER TABLE `trips`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ship_id` (`ship_id`),
  ADD KEY `employee_id` (`employee_id`),
  ADD KEY `route_id` (`route_id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `cargo`
--
ALTER TABLE `cargo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `contragent`
--
ALTER TABLE `contragent`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT для таблицы `countries`
--
ALTER TABLE `countries`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT для таблицы `employees`
--
ALTER TABLE `employees`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT для таблицы `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT для таблицы `offices`
--
ALTER TABLE `offices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT для таблицы `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `persons`
--
ALTER TABLE `persons`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;
--
-- AUTO_INCREMENT для таблицы `ports`
--
ALTER TABLE `ports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT для таблицы `route`
--
ALTER TABLE `route`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT для таблицы `ships`
--
ALTER TABLE `ships`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT для таблицы `tariffs`
--
ALTER TABLE `tariffs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT для таблицы `trips`
--
ALTER TABLE `trips`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `cargo`
--
ALTER TABLE `cargo`
  ADD CONSTRAINT `cargo_ibfk_1` FOREIGN KEY (`tariff_id`) REFERENCES `tariffs` (`id`),
  ADD CONSTRAINT `cargo_ibfk_2` FOREIGN KEY (`src_id`) REFERENCES `ports` (`id`),
  ADD CONSTRAINT `cargo_ibfk_3` FOREIGN KEY (`dst_id`) REFERENCES `ports` (`id`);

--
-- Ограничения внешнего ключа таблицы `crews`
--
ALTER TABLE `crews`
  ADD CONSTRAINT `crews_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `persons` (`id`),
  ADD CONSTRAINT `crews_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `jobs` (`id`);

--
-- Ограничения внешнего ключа таблицы `employees`
--
ALTER TABLE `employees`
  ADD CONSTRAINT `employees_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `persons` (`id`),
  ADD CONSTRAINT `employees_ibfk_2` FOREIGN KEY (`position_id`) REFERENCES `jobs` (`id`),
  ADD CONSTRAINT `employees_ibfk_3` FOREIGN KEY (`office_id`) REFERENCES `offices` (`id`);

--
-- Ограничения внешнего ключа таблицы `offices`
--
ALTER TABLE `offices`
  ADD CONSTRAINT `offices_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`);

--
-- Ограничения внешнего ключа таблицы `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `FK_contragent_id` FOREIGN KEY (`contragent_id`) REFERENCES `contragent` (`id`),
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`cargo_id`) REFERENCES `cargo` (`id`),
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`trip_id`) REFERENCES `trips` (`id`);

--
-- Ограничения внешнего ключа таблицы `persons`
--
ALTER TABLE `persons`
  ADD CONSTRAINT `persons_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`);

--
-- Ограничения внешнего ключа таблицы `ports`
--
ALTER TABLE `ports`
  ADD CONSTRAINT `ports_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`);

--
-- Ограничения внешнего ключа таблицы `route_sequence`
--
ALTER TABLE `route_sequence`
  ADD CONSTRAINT `route_sequence_ibfk_1` FOREIGN KEY (`port_id`) REFERENCES `ports` (`id`);

--
-- Ограничения внешнего ключа таблицы `trips`
--
ALTER TABLE `trips`
  ADD CONSTRAINT `trips_ibfk_1` FOREIGN KEY (`ship_id`) REFERENCES `ships` (`id`),
  ADD CONSTRAINT `trips_ibfk_2` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`),
  ADD CONSTRAINT `trips_ibfk_3` FOREIGN KEY (`route_id`) REFERENCES `route` (`id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
