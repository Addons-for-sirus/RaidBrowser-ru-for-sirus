raid_browser = LibStub('AceAddon-3.0'):NewAddon('RaidBrowser', 'AceConsole-3.0')
-- Separator characters
local sep_chars = '%s-_,.<>%*)(/#+&x'

-- Whitespace separator
local sep = '[' .. sep_chars .. ']';

-- Kleene closure of sep.
local csep = sep..'*';

-- Positive closure of sep.
local psep = sep..'+';

-- Raid patterns template for a raid with 2 difficulties and 2 sizes
local raid_patterns_template = {
	hc = {
		'<raid>' .. csep .. '<size>' .. csep .. '%(?хм?%)?',
		psep..'%(?хм?%)?' .. csep .. '<raid>' .. csep .. '<size>',
		'<raid>' .. csep .. '%(?хм?%)?' .. csep .. '<size>',

		'<raid>' .. csep .. '<size>' .. csep .. '%(?гер?%)?',
		psep..'%(?гер?%)?' .. csep .. '<raid>' .. csep .. '<size>',
		'<raid>' .. csep .. '%(?гер?%)?' .. csep .. '<size>',

		'<fullraid>' .. csep .. '<size>' .. csep .. '%(?хм?%)?',
		psep..'%(?хм?%)?' .. csep .. '<fullraid>' .. csep .. '<size>',
		'<fullraid>' .. csep .. '%(?хм?%)?' .. csep .. '<size>',

		'<fullraid>' .. csep .. '<size>' .. csep .. '%(?гер?%)?',
		psep..'%(?гер?%)?' .. csep .. '<fullraid>' .. csep .. '<size>',
		'<fullraid>' .. csep .. '%(?гер?%)?' .. csep .. '<size>',
	},

	nm = {
		'<raid>' .. csep .. '<size>' .. csep .. '%(?об?%)?',
		psep..'%(?об?%)?' .. csep .. '<raid>' .. csep .. '<size>',
		'<raid>' .. csep .. '%(?об?%)?' .. csep .. '<size>',
		'<raid>' .. csep .. '<size>',

		'<fullraid>' .. csep .. '<size>' .. csep .. '%(?об?%)?',
		psep..'%(?об?%)?' .. csep .. '<fullraid>' .. csep .. '<size>',
		'<fullraid>' .. csep .. '%(?об?%)?' .. csep .. '<size>',
		'<fullraid>' .. csep .. '<size>',
	},

	simple = {
		'<raid>' .. csep .. '<size>',
		'<size>' .. csep .. '<raid>',
	},
};

local function create_pattern_from_template(raid_name_pattern, size, difficulty, full_raid_name)
	if not raid_name_pattern or not size or not difficulty or not full_raid_name then
		return;
	end

	full_raid_name = string.lower(full_raid_name);

	if size == 10 then
		size = '1[0o]';
	elseif size == 40 then
		size = '4[0p]';
	end

	-- Replace placeholders with the specified raid info
	return std.algorithm.transform(raid_patterns_template[difficulty], function(pattern)
		pattern = string.gsub(pattern, '<fullraid>', full_raid_name);
        pattern = string.gsub(pattern, '<raid>', raid_name_pattern);
        pattern = string.gsub(pattern, '<size>', size);
        return pattern;
	end);
end

local raid_list = {
	-- Note: The order of each raid is deliberate.
	-- Heroic raids are checked first, since NM raids will have the default 'icc10' pattern.
	-- Be careful about changing the order of the raids below
	{ -- рлк
		name = 'РЛК',
		instance_name = 'Испытание чемпиона',
		size = 5,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('рлк', 5, 'nm', 'Испытание чемпиона'),
			{
				'рлк'..csep..'гер',
				'в'..csep..'залы',
				'в '..csep..'кузню',
				'в'..csep..'яму',
				'3рлк',

			}
		),
	},

	{ -- снeговик
		name = 'Снеговик',
		instance_name = 'Логово замёрзшего снеговика',
		size = 5,
		difficulty = 1,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('Снеговик', 5, 'nm', 'Логово замёрзшего снеговика'),
			{
				'на'..csep..'снеговика',
				'снеговик',
				'%[?логово замёрзшего снеговика%]?',
				'%[?снежный доспех%]?',

			}
		),
	},

	{ -- контр + эттин
		name = 'Контр',
		instance_name = 'Черные топи',
		size = 5,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('контр', 5, 'nm', 'Черные топи'),
			{
				'контракты',
				'эттины',
				'элит'..csep..'тг'..csep..'место',
				'элит'..csep..'тг'..csep..'места',
				'на'..csep..'элиток',
				'на'..csep..'эллиток',
				'тг'..csep..'элитки',	
				'контракты'..csep..'%+'..csep..'эттины',
				'эттины'..csep..'%+'..csep..'контракты',

			}
		),
	},

	{ -- норигорн
		name = 'Норигорн',
		instance_name = 'Черные топи',
		size = 5,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('Норигорн', 5, 'nm', 'Черные топи'),
			{
				'норигорна',
				'норигорн',
				'на'..csep..'норигорна',
			}
		),
	},
	{ -- рбк
		name = 'РБК',
		instance_name = 'Черные топи',
		size = 5,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('рбк', 5, 'nm', 'Черные топи'),
			{
				'нрбк',
				'рбк',
				'н'..csep..'рбк',
				'Н'..csep..'РБК',
				'Н'..csep..'рбк',
				'в'..csep..'рбк',
				'три'..csep..'рбк',
				'три'..csep..'нрбк',
				'онли'..csep..'нрбк',
				'темный'..csep..'лабиринт',
				'собираю'..csep..'рбк',
				'собераю'..csep..'рбк',
				'собераю'..csep..'в'..csep..'рбк',
				'собераю'..csep..'на'..csep..'3'..csep..'рбк',
				'собераю'..csep..'на'..csep..'три'..csep..'рбк',
				'собераю'..csep..'на'..csep..'3'..csep..'нрбк',
				'собераю'..csep..'на'..csep..'три'..csep..'нрбк',
				'собираю'..csep..'на'..csep..'три'..csep..'рбк',
				'собираю'..csep..'на'..csep..'3'..csep..'рбк',
				'собираю'..csep..'на'..csep..'три'..csep..'нрбк',
				'собираю'..csep..'на'..csep..'3'..csep..'нрбк',
				'н'..csep..'р'..csep..'б'..csep..'к',
				'собираю'..csep..'в'..csep..'рбк',
				'в'..csep..'нрбк',
				'на'..csep..'3'..csep..'рбк',
				'на'..csep..'3'..csep..'нрбк',

			}
		),
	},

	{ -- 5 ката
		name = '5 ката',
		instance_name = 'Черные топи',
		size = 5,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('5 ката', 5, 'nm', 'Черные топи'),	{
			'5'..csep..'ката',
			'на'..csep..'5'..csep..'кату',
			'5'..csep..'категория',
			'на'..csep..'5'..csep..'категорию',
			'%[?5 категория%]',
			'на'..csep..'%[?5 категория%]',
			}
		),
	},

	{ -- 4 ката
		name = '4 ката',
		instance_name = 'Черные топи',
		size = 5,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('4 ката', 5, 'nm', 'Черные топи'),
			{
			'4'..csep..'ката',
			'на'..csep..'4'..csep..'кату',
			'4'..csep..'категория',
			'на'..csep..'4'..csep..'категорию',
			'%[?4 категория%]?',
			'на'..csep..'%[?4 категория%]?',
			}
		),
	},
	{ -- 3 ката
		name = '3 ката',
		instance_name = 'Черные топи',
		size = 5,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('3 ката', 5, 'nm', 'Черные топи'),
			{
			'3'..csep..'ката',
			'на'..csep..'3'..csep..'кату',
			'3'..csep..'категория',
			'на'..csep..'3'..csep..'категорию',
			'%[?3 категория%]?',
			'на'..csep..'%[?3 категория%]?',
			}
		),
	},
	{ -- 2 ката
		name = '2 ката',
		instance_name = 'Черные топи',
		size = 5,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('2 ката', 5, 'nm', 'Черные топи'),
			{
			'2'..csep..'ката',
			'на'..csep..'2'..csep..'кату',
			'2'..csep..'категория',
			'на'..csep..'2'..csep..'категорию',
			'%[?2 категория%]?',
			'на'..csep..'%[?2 категория%]?',

			}
		),
	},

	{ -- 1 ката
		name = '1 ката',
		instance_name = 'Черные топи',
		size = 5,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('1 ката', 5, 'nm', 'Черные топи'),
			{
			'1'..csep..'ката',
			'на'..csep..'1'..csep..'кату',
			'1'..csep..'категория',
			'на'..csep..'1'..csep..'категорию',
			'%[?1 категория%]?',
			'на'..csep..'%[?1 категория%]?',
			}
		),
	},

	{ -- цлк10хм
		name = 'Цлк 10 хм',
		instance_name = 'Цитадель Ледяной Короны',
		size = 10,
		difficulty = 3,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('цлк', 10, 'hc', 'Цитадель Ледяной Короны'),
			{
				'лич'..csep..'цлк'..csep..'10'..csep..'хм',
				'цлк'..csep..'10'..csep..'хм',
				'на'..csep..'лича'..csep..'10'..csep..'хм',
				'на'..csep..'лича'..csep..'цлк'..csep..'10'..csep..'хм',
				'%[?цитадель ледяной короны%]?'..csep..'10'..csep..'хм',
				'%[?цитадель ледяной короны%]?'..csep..'10'..csep..'гер',
			}
		),
	},

	{ -- цлк25хм
		name = 'Цлк 25 хм',
		instance_name = 'Цитадель Ледяной Короны',
		size = 25,
		difficulty = 4,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('цлк', 25, 'hc', 'Цитадель Ледяной Короны'),
			{
				'лич'..csep..'цлк'..csep..'25'..csep..'хм',
				'лич'..csep..'цлк'..csep..'25'..csep..'гер',
				'цлк'..csep..'25'..csep..'хм',
				'цлк'..csep..'25'..csep..'гер',
				'в'..csep..'цлк'..csep..'25'..csep..'хм',
				'в'..csep..'цлк'..csep..'25'..csep..'гер',
				'лич'..csep..'25'..csep..'хм',
				'лич'..csep..'25'..csep..'гер',
				'на'..csep..'лича'..csep..'25'..csep..'хм',
				'на'..csep..'лича'..csep..'25'..csep..'гер',
				'на'..csep..'лича'..csep..'цлк'..csep..'25'..csep..'хм',
				'на'..csep..'лича'..csep..'цлк'..csep..'25'..csep..'гер',
				'%[?цитадель ледяной короны%]?'..csep..'25'..csep..'хм',
				'%[?цитадель ледяной короны%]?'..csep..'25'..csep..'гер',
			}
		),
	},

	{ -- цлк10об
		name = 'Цлк 10 об',
		instance_name = 'Цитадель Ледяной Короны',
		size = 10,
		difficulty = 1,
		patterns = {
				'лич'..csep..'цлк'..csep..'10',
				'цлк'..csep..'10'..csep..'об',
				'цлк'..csep..'10'..csep..'репа',
				'цлк'..csep..'репа',
				'цлк'..csep..'репофарм',
				'репофарм'..csep..'цлк',
				'лич'..csep..'10'..csep..'об',
				'%[?слава рейдеру ледяной короны %(10 игроков%)%]?',
				'%[?Чума нежизни%]?'..csep..'10'..csep..'об',
				'%[?Чума нежизни%]?'..csep..'10',
				'%[?чума нежизни%]?',
				'%[?цитадель ледяной короны%]?' ..csep.. '10',
				'%[?падение короля%-лича %(10 игроков%)%]?',
		}
	},

	{ -- цлк25об
		name = 'Цлк 25 об',
		instance_name = 'Цитадель Ледяной Короны',
		size = 25,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('цлк', 25, 'nm', 'Цитадель Ледяной Короны'),
			{
				'лич'..csep..'цлк'..csep..'25',
				'лич'..csep..'25'..csep..'об',
				'цлк'..csep..'25'..csep..'об',
				'цлк'..csep..'%('..csep..'25'..csep..'об'..csep..'%)',
				'цлк'..csep..'25об',
				'%[?цитадель ледяной короны%]?'..csep..'25',
			}
		),
	},

	{ -- магик хм
		name = 'Магик хм',
		instance_name = 'Логово Магтеридона',
		size = 25,
		difficulty = 4,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('магик', 25, 'hc', 'Логово Магтеридона'),
			{
				'магик'..csep..'хм',
				'гм'..csep..'хм',
				'грул%/магик'..csep..'хм',
				'грул'..csep..'магик'..csep..'хм',
				'магик'..csep..'гер',
				'магик%/грул'..csep..'хм',
				'магик%/грул'..csep..'%(хм%)',
				'магик%/грул'..csep..'%(гер%)',
				'гм'..csep..'гер',
				'магик%/грул'..csep..'гер',
				'мг'..csep..'гер',
				'мг'..csep..'хм',
				'м%/г'..csep..'хм',
				'г%/м'..csep..'хм',
				'г%/м'..csep..'гер',
				'м%/г'..csep..'гер',
				'м'..csep..'г'..csep..'хм',
				'м'..csep..'г'..csep..'гер',
				'мг'..csep..'хм',
				'%[?логово магтеридона%]?'..csep..'хм',
				'%[?логово магтеридона%]?'..csep..'гер',
				'м'..csep..'и'..csep..'г'..csep..'хм',
				'м'..csep..'и'..csep..'г'..csep..'гер',
				'%[?охота на великих чудовищ%]?'..csep..'хм',
				'%[?охота на Великих чудовищ%]?'..csep..'гер',
				'магик'..csep..'грул'..csep..'25хм',
				'магик'..csep..'грул'..csep..'25'..csep..'хм',
				'магик'..csep..'грул'..csep..'25гер',
				'магик'..csep..'грул'..csep..'25'..csep..'гер',
			}
		),

	},

	{ -- магик об
		name = 'Магик об',
		instance_name = 'Логово Магтеридона',
		size = 25,
		difficulty = 1,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('магик', 25, 'nm', 'Логово Магтеридона'),
			{
				'магик'..csep..'об',
				'магик',
				'магик'..csep..'грул',
				'в'..csep..'мг',
				'фаст'..csep..'охота',
				'на'..csep..'охоту',
				'охота'..csep..'на'..csep..'фул',
				'м'..csep..'и'..csep..'г'..csep..'об',
				-- 'м'..csep..'и'..csep..'г',
				'только'..csep..'магик',
				'гм'..csep..'об',
				'груул%/магик'..csep..'об',
				'мг'..csep..'об',
				'магик%/грул',
				'м%/г'..csep..'об',
				'г%/м'..csep..'об',
				'мг'..csep..'%(об%)',
				'мг%(об%)',
				'%[?логово магтеридона%]?',
				'фул'..csep..'%[?охота на великих чудовищ%]?',
				'на'..csep..'фул'..csep..'%[?охота на великих чудовищ%]?',
				'%[?охота на великих чудовищ%]?',
			}
		),
	},
	{ -- грул хм
		name = 'Грул хм',
		instance_name = 'Логово Груула',
		size = 25,
		difficulty = 4,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('груул', 25, 'hc', 'Логово Груула'),
			{
				'грул'..csep..'хм',
				'груул'..csep..'хм',
				'грулл'..csep..'хм',
				'грул'..csep..'гер',
				'груул'..csep..'гер',
				'грулл'..csep..'гер',
				'%[?логово груула%]?'..csep..'хм',
				'%[?логово груула%]?'..csep..'гер',
				'г'..csep..'хм',
			}
		),
	},
	{ -- грул об
		name = 'Грул об',
		instance_name = 'Логово Груула',
		size = 25,
		difficulty = 1,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('груул', 25, 'nm', 'Логово Груула'),
			{
				'грул'..csep..'об',
				'груул'..csep..'об',
				'грулл'..csep..'об',
				'грул',
				'груул',
				'грулл',
				'на'..csep..'грула',
				'на'..csep..'грулла',
				'на'..csep..'груула',
				'закрыть'..csep..'охоту',
				'%[?логово груула%]?'..csep..'об',
				'%[?логово груула%]?',
				'%[?логово груула%]?'..csep..'кто'..csep..'не',
			}
		),
	},
		{ -- ос10
		name = 'Ос 10',
		instance_name = 'Обсидиановое святилище',
		size = 10,
		difficulty = 1,
		patterns = create_pattern_from_template('ос', 10, 'simple', 'Обсидиановое святилище'),{
				'в'..csep..'ос'..csep..'10',
				'ос'..csep..'10',
				'ос'..csep..'10'..csep..'на'..csep..'%+'..csep..'3',
				'в'..csep..'ос'..csep..'на'..csep..'%+'..csep..'3',
				'%[?сартарион должен умереть%!?%]?',
				'%[?обсидиановое святилище%]?'..csep..'10',
			}
	},

	{ -- ос25
		name = 'Ос 25',
		instance_name = 'Обсидиановое святилище',
		size = 25,
		difficulty = 2,
		patterns = create_pattern_from_template('ос', 25, 'simple', 'Обсидиановое святилище'),{
				'в'..csep..'ос'..csep..'25',
				'ос'..csep..'25'..csep..'на'..csep..'%+'..csep..'3',
				'ос'..csep..'25',
				'%[?Обсидиановое святилище%]?'..csep..'25',
				'%[?меньше – не значит хуже %(25 игроков%)%]?',
			}
	},


	{ -- ульда 10 хм
		name = 'Ульда 10 хм',
		instance_name = 'Ульдуар',
		size = 10,
		difficulty = 3,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('ульда', 10, 'hc', 'Ульдуар'),
			{
				'ульда'..csep..'10'..csep..'хм',
				'ульд'..csep..'10'..csep..'хм',
				'ульд'..csep..'10'..csep..'гер',
				'ульда'..csep..'10'..csep..'гер',
				'в'..csep..'ульду'..csep..'10'..csep..'гер',
				'в'..csep..'ульду'..csep..'10'..csep..'хм',
				'ульда10хм',
				'утюг'..csep..'10'..csep..'хм',
				'утюг'..csep..'10',
				'на'..csep..'утюга'..csep..'в'..csep..'ульду'..csep..'10',
				'%[?ульдуар%]?'..csep..'10'..csep..'хм',
				'%[?генерал везакс%]?'..csep..'10',
				'%[?йогг%-сарон%]?'..csep..'10',
				'%[?ульдуар%]?'..csep..'10'..csep..'гер',
			}
		),
	},

	{ -- ульда10
		name = 'Ульда 10',
		instance_name = 'Ульдуар',
		size = 10,
		difficulty = 1,
		patterns = {
			'ульда'..csep..'10',
			'ульд'..csep..'10',
			'ульдар'..csep..'10',
			'ульдуар'..csep..'10',
			'в'..csep..'ульду'..csep..'10',
			'в'..csep..'ульду'..csep..'10',
			'%[?слава рейдеру ульдуара %(10 игроков%)%]?',
			'%[?защитник ульдуара%]?',
			'%[?посланник титанов%]?',
			'%[?ульдуар%]?'..csep..'10'..csep..'об',
			'%[?ульдуар%]?'..csep..'10',
		},
	},


	{ -- ульда25 хм
		name = 'Ульда 25 хм',
		instance_name = 'Ульдуар',
		size = 25,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('ульда', 25, 'hc', 'Ульдуар'),
			{
				'ульда'..csep..'25'..csep..'на',
				'ульд'..csep..'25'..csep..'хм',
				'ульд'..csep..'25'..csep..'гер',
				'ульда'..csep..'10%-25'..csep..'хм',
				'ульда'..csep..'10%-25'..csep..'гер',
				'в'..csep..'ульду'..csep..'на'..csep..'утюга',
				'в'..csep..'ульду'..csep..'25'..csep..'на'..csep..'утюга',
				'утюг'..csep..'ульда'..csep..'хм',
				'утюг'..csep..'ульда'..csep..'гер',
				'на'..csep..'утюга'..csep..'25',
				'на'..csep..'утюга'..csep..'в'..csep..'ульду'..csep..'25'..csep..'хм',
				'в'..csep..'ульду'..csep..'25',
				'%[?ульдуар%]?'..csep..'25'..csep..'хм',
				'%[?ульдуар%]?'..csep..'25'..csep..'гер',
			}
		),
	},


	{ -- ульда25
		name = 'Ульда 25',
		instance_name = 'Ульдуар',
		size = 25,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('ульда', 25, 'nm', 'Ульдуар'),{
			'ульда'..csep..'25'..csep..'на',
			'ульда'..csep..'10-25',
			'утюг'..csep..'ульда',
			'на'..csep..'утюга'..csep..'в'..csep..'ульду',
			'в'..csep..'ульду'..csep..'25',
			'%[?слава рейдеру ульдуара %(25 игроков%)%]?',
			'%[?завоеватель ульдуара%]?',
			'%[?ульдуар%]?'..csep..'25',
			}
		),
	},

	{ -- накс10
		name = 'Накс 10',
		instance_name = 'Наксрамас',
		size = 10,
		difficulty = 1,
		patterns = {
			'накс'..csep..'10',
			'на'..csep..'неуяз',
			'%наксрамас%]?'..csep..'10',
			'%[?ануб\'рекан должен умереть%!?%]?',
			'%[?нот чумной должен умереть%!?%]?',
			'%[?инструктор разувий должен умереть%!?%]?',
			'%[?лоскутик должен умереть%!?%]?',

		},
	},

	{ -- накс25
		name = 'Накс 25',
		instance_name = 'Наксрамас',
		size = 25,
		difficulty = 2,
		patterns = {
			'накс'..csep..'25',
			'бессмертный',
			'на'..csep..'бессмертного',
			'%[?наксрамас%]?'..csep..'25',
			'%[?ануб\'рекан должен умереть%!?%]?'..csep..'25',
			'%[?нот чумной должен умереть%!?%]?'..csep..'25',
			'%[?инструктор разувий должен умереть%!?%]?'..csep..'25',
			'%[?лоскутик должен умереть%!?%]?'..csep..'25',
		},
	},


	{ -- око хм
		name = 'Око хм',
		instance_name = 'Крепость Бурь',
		size = 25,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('око хм', 25, 'nm', 'Крепость Бурь'),
			{
				'%[?око%]?'..csep..'хм',
				'%[?око%]?'..csep..'гер',
			}
		),
	},

	{ -- око
		name = 'Око',
		instance_name = 'Крепость Бурь',
		size = 25,
		difficulty = 1,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('око', 25, 'nm', 'Крепость Бурь'),
			{
				'%[?око%]?',
				'окооб',
				'окооб'..csep..'с0',
				'окооб'..csep..'с'..csep..'0',
				'окооб'..csep..'с'..csep..'нуля',
				'в'..csep..'окооб'..csep..'с'..csep..'нуля',
				'в'..csep..'окооб'..csep..'с'..csep..'нуля',
				'в'..csep..'око'..csep..'об',
				'%[?око%]?'..csep..'об',

			}
		),
	},

	{ -- зс хм
		name = 'Зс хм',
		instance_name = 'Кривой Клык: Змеиное святилище',
		size = 25,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('зс хм', 25, 'nm', 'Кривой Клык: Змеиное святилище'),
			{
				'зс'..csep..'хм',
				'в'..csep..'зс'..csep..'хм',
				'%[?змеиное святилище%]?'..csep..'хм',
				'%[?змеиное святилище%]?'..csep..'гер',
				}
		),
	},

	{ -- зс
		name = 'Зс об',
		instance_name = 'Кривой Клык: Змеиное святилище',
		size = 25,
		difficulty = 1,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('зс', 25, 'nm', 'Кривой Клык: Змеиное святилище'),
			{
			'зс'..csep..'об',
			'зс'..csep..'%(об%)',
			'зс',
			'зс'..csep..'от',
			'в'..csep..'зс'..csep..'от',
			'в'..csep..'зс'..csep..'об',
			'зс'..csep..'об'..csep..'время на сбор',
			'%[?змеиное святилище%]?'..csep..'об',
			'%[?змеиное святилище%]?',
			}
		),
	},

	{ -- за
		name = 'ЗА',
		instance_name = 'Зул\'Аман',
		size = 10,
		difficulty = 1,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('ЗА', 10, 'nm', 'Зул\'Аман'),
			{
				'за'..csep..'об',
				'в'..csep..'за',
				'за%+3',
				'за'..csep..'%+'..csep..'3',
				'за'..csep..'нид',
			    'на'..csep..'3'..csep..'сундука',
				'на'..csep..'4%+'..csep..'сундука',
				'сундук',
				'сундука',
				'%[?зул\'аман%]?',
				'%[?мщение амани%]?',

			}
		),
	},

	{ -- ивк10
		name = 'Ивк 10',
		instance_name = 'Испытание крестоносца',
		size = 10,
		difficulty = 3,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('ик', 10, 'hc', 'Испытание крестоносца'),
			{
				'ивк'..csep..'10',
				'%[?дань фанатичному безумию%]?',
				'%[?призыв великого крестоносца %(10 игроков%)%]?',
				'%[?испытание крестоносца%]?'..csep..'10'..csep..'гер',
				'%[?испытание крестоносца%]?'..csep..'10'..csep..'хм',
			}
		),
	},

	{ -- ивк25
		name = 'Ивк 25',
		instance_name = 'Испытание крестоносца',
		size = 25,
		difficulty = 4,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('ик', 25, 'hc', 'Испытание крестоносца'),
			{
				'ивк'..csep..'25',
				'%[?призыв великого крестоносца %(25 игроков%)%]?',
				'%[?испытание крестоносца%]?'..csep..'25'..csep..'гер',
				'%[?испытание крестоносца%]?'..csep..'25'..csep..'хм',
			}
		),
	},

	{ -- ик10
		name = 'Ик 10',
		instance_name = 'Испытание крестоносца',
		size = 10,
		difficulty = 1,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('ик', 10, 'nm', 'Испытание крестоносца'),{
			'%[?призыв авангарда %(10 игроков%)%]?',
			'ик'..csep..'оня'..csep..'10',
			'ик'..csep..'оню'..csep..'10',
			'ик'..csep..'оня'..csep..'10',
			'ик%/оня'..csep..'10',
			'иконя'..csep..'10',
			'ик'..csep..'и'..csep..'оня',
			'ик'..csep..'после'..csep..'они',
			'ик%+оня'..csep..'10',
			'ик%/оня'..csep..'10',
			'ик%/оня'..csep..'(10)',
			'ик'..csep..'(10)',
			'ик%+оня'..csep..'(10)',
			'ик%/оня'..csep..'10',
			'ик'..csep..'10',
			'ик'..csep..'10'..csep..'об',
			'%[?испытание крестоносца%]?'..csep..'10'..csep..'об',
			'%[?испытание крестоносца%]?'..csep..'10',
			'%[?испытание крестоносца%]?',
			}
		),
	},

	{ -- ик25
		name = 'Ик 25',
		instance_name = 'Испытание крестоносца',
		size = 25,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('ик', 25, 'nm', 'Испытание крестоносца'),
			{
			'%[?призыв авангарда %(25 игроков%)%]?',
			'%[?испытание крестоносца%]?'..csep..'25',
			'ик'..csep..'оня'..csep..'25',
			'фул'..csep..'охота'..csep..'25',
			'фул'..csep..'охота'..csep..'25об',
			'фул'..csep..'охота'..csep..'25'..csep..'об',
			}
		),
	},

	{ -- рс10хм
		name = 'Рс 10 хм',
		instance_name = 'Рубиновое святилище',
		size = 10,
		difficulty = 3,
		patterns = create_pattern_from_template('рс', 10, 'hc', 'Рубиновое святилище'),
			{
			'рс'..csep..'10'..csep..'хм',
			'рс'..csep..'10'..csep..'гер',
			'%[?рубиновое святилище%]?'..csep..'10'..csep..'хм',
			'%[?рубиновое святилище%]?'..csep..'10'..csep..'гер',
			}
	},

	{ -- рс25хм
		name = 'Рс 25 хм',
		instance_name = 'Рубиновое святилище',
		size = 25,
		difficulty = 4,
		patterns = create_pattern_from_template('рс', 25, 'hc', 'Рубиновое святилище'),{
			'рс'..csep..'25'..csep..'хм',
			'рс'..csep..'25'..csep..'гер',
			'%[?рубиновое святилище%]?'..csep..'25'..csep..'хм',
			'%[?рубиновое святилище%]?'..csep..'25'..csep..'гер',
			}
	},

	{ -- рс10об
		name = 'Рс 10 об',
		instance_name = 'Рубиновое святилище',
		size = 10,
		difficulty = 1,
		patterns = create_pattern_from_template('рс', 10, 'nm', 'Рубиновое святилище'),{
			'рс'..csep..'10'..csep..'об',
			'рс'..csep..'10',
			'%[?рубиновое святилище%]?'..csep..'10',
			}
	},

	{ -- рс25об
		name = 'Рс 25 об',
		instance_name = 'Рубиновое святилище',
		size = 25,
		difficulty = 2,
		patterns = create_pattern_from_template('рс', 25, 'nm', 'Рубиновое святилище'),{
			'рс'..csep..'25',
			'рс'..csep..'25'..csep..'об',
			'%[?рубиновое святилище%]?'..csep..'25',
			}
	},

	{ -- са10
		name = 'Са 10',
		instance_name = 'Склеп Аркавона',
		size = 10,
		difficulty = 1,
		patterns = {
			'са'..csep..'10',
			'склеп'..csep..'10',
			'с'..csep..'а'..csep..'10',
			'%[?склеп аркавона%]?'..csep..'10',
		},
	},

	{ -- са25
		name = 'Са 25',
		instance_name = 'Склеп Аркавона',
		size = 25,
		difficulty = 2,
		patterns = {
			'са'..csep..'25',
			'склеп'..csep..'25',
			'с'..csep..'а'..csep..'25',
			'%[?склеп аркавона%]?'..csep..'25',
		},
	},

	{ -- оня25
		name = 'Оня 25',
		instance_name = 'Логово Ониксии',
		size = 25,
		difficulty = 2,
		patterns = {
			'оня'..csep..'25',
			'только'..csep..'оня'..csep..'25',
			'в'..csep..'оню'..csep..'25',
			'%[?логово ониксии%]?'..csep..'25',
		},
	},

	{ -- оня10
		name = 'Оня 10',
		instance_name = 'Логово Ониксии',
		size = 10,
		difficulty = 1,
		patterns = {
			'оня'..csep..'10',
			'только'..csep..'оня'..csep..'10',
			'только'..csep..'оня',
			'в'..csep..'оню'..csep..'10',
			'%[?логово ониксии%]?'..csep..'10',
		},
	},

	{ -- каражан хм
		name = 'Кара хм',
		instance_name = 'Каражан',
		size = 10,
		difficulty = 2,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('кара', 10, 'hc', 'Каражан'),
			{
				'кара'..csep..'хм',
				'кара'..csep..'гер',
				'кара'..csep..'хм'..csep..'на'..csep..'гнева',
				'кару'..csep..'хм',
				'кара'..csep..'гер'..csep..'на'..csep..'гнева',
				'кару'..csep..'гер',
				'в'..csep..'кару'..csep..'хм',
				'в'..csep..'кару'..csep..'гер',
				'%[?каражан%]?'..csep..'гер',
				'%[?каражан%]?'..csep..'хм',
			}
		),
	},

	{ -- каражан
		name = 'Кара',
		instance_name = 'Каражан',
		size = 10,
		difficulty = 1,
		patterns = std.algorithm.copy_back(
			create_pattern_from_template('кара', 10, 'nm', 'Каражан'),
			{
				'кара'..csep..'об',
				'кара',
				'кару',
				'кара'..csep..'по'..csep..'токенам',
				'кару'..csep..'по'..csep..'токенам',
				'по'..csep..'токенам',
				'каражан'..csep..'по'..csep..'токенам',
				'%[?каражан%]?',
				'%[?каражан%]?'..csep..'об',
			}
		),
	},

	{ -- огненные недра
		name = 'Недра',
		instance_name = 'Огненные Недра',
		size = 40,
		difficulty = 1,
		patterns = {
			'огненные'..csep..'недра',
			'он'..csep..'за'..csep..'транс',
			'%[?огненные недра%]?'
		},
	},

	{ -- черный храм
		name = 'ЧХ',
		instance_name = 'Черный храм',
		size = 25,
		difficulty = 2,
		patterns = {
			'черный'..csep..'храм',
			'Ч'..csep..'Х',
			'black'..csep..'temple',
			'[%s-_,.]+bt'..csep..'25[%s-_,.]+',
		},
	},


	{ -- ов 10
		name = 'ов 10',
		instance_name = 'Око Вечности',
		size = 10,
		difficulty = 1,
		patterns = create_pattern_from_template('ов', 25, 'simple', 'Око Вечности'),{
				'в'..csep..'ов'..csep..'10',
				'ов'..csep..'10',
				'%[?малигос должен умереть%!?%]?',
				'%[?око вечности%]?'..csep..'10',
			}
	},


	{ -- ов 25
		name = 'ов 25',
		instance_name = 'Око Вечности',
		size = 25,
		difficulty = 2,
		patterns = create_pattern_from_template('ос', 25, 'simple', 'Око Вечности'),{
				'в'..csep..'ов'..csep..'25',
				'ов'..csep..'25',
				'%[?око вечности%]?'..csep..'25',
			}
	},
	{ -- бс 25 хм
		name = 'бс 25 хм',
		instance_name = 'Бронзовое святилище',
		size = 25,
		difficulty = 2,
		patterns = create_pattern_from_template('бс', 25, 'hc', 'Бронзовое святилище'),{
				'бс'..csep..'25'..csep..'хм',
				'бс'..csep..'25'..csep..'гер',
				'в'..csep..'бс'..csep..'хм',
				'в'..csep..'бс'..csep..'гер',
				'%[?бронзовое святилище%]?'..csep..'хм',
				'%[?бронзовое святилище%]?'..csep..'гер',

			}
	},

	{ -- бс 25 об
		name = 'бс 10 об',
		instance_name = 'Бронзовое святилище',
		size = 25,
		difficulty = 1,
		patterns = create_pattern_from_template('бс', 25, 'nm', 'Бронзовое святилище'),{
				'в'..csep..'бс'..csep..'об',
				'бс'..csep..'об',
				'в'..csep..'бс',
				'%[?бронзовое святилище%]?',
				'%[?бронзовое святилище%]?'..csep..'об',
			}
	},


}

local role_patterns = {
	dps = {
		'[0-9]*'..csep..'dps',
		'[0-9]*'..csep..'дд/рдд',
		'[0-9]*'..csep..'д/рдд',
		'[0-9]*'..csep..'р/дд',
		'[0-9]*'..csep..'Р/дд',
		'Р/дд',
		'спек',

		'тащера',
		'животных',
		'мутанты',
		'сильнейших'..csep..'дд',
		'топовых'..csep..'дд',


		-- melee dps
		'[0-9]*'..csep..'дд',
		'[0-9]'..csep..'дд',
		'[0-9]*'..csep..'адк',
		'[0-9]*'..csep..'фвар', 'фурик',
		'[0-9]*'..csep..'кот',
		'[0-9]*'..csep..'рога', 'крога', 'комбат',
		'[0-9]*'..csep..'ретрик',

		-- ranged dps
		'[0-9]*'..csep..'рдд',
		'[0-9]'..csep..'рдд',
		'[0-9]*'..csep..'спд',
		'[0-9]*'..csep..'шп',
		'кастеры',
		'кастер',
		'[0-9]*'..csep..'сова',
		'[0-9]*'..csep..'демон',
		'[0-9]*'..csep..'элем',
		'[0-9]*'..csep..'маг',
		'[0-9]*'..csep..'тело',
		'[0-9]*'..csep..'тела',
		'дд','пару',
		'р%(дд%)',

		'кольчужники',
		'ткань',

		'латники',
		'дпс',
		'дпс+',
		'дпс++',
	'пару'..csep..'дд',
	'дд'..csep..'рдд',
	'дд%.рдд',
	'дд%/рдд',
	'пару'..csep..'рдд',
	'пара'..csep..'рдд',
	'пара'..csep..'дд',
	'помогите',

	},

	healer = {
		'[0-9]*'..csep..'хил',
		'[0-9]*'..csep..'хилов',
		'[0-9]*'..csep..'hll',
		'[0-9]*'..csep..'рдру',
		'[0-9]*'..csep..'ршам',
		'[0-9]*'..csep..'хпал',
		'[0-9]*'..csep..'дц',	'дц','ДЦ','Дц',
		'[0-9]*'..csep..'хприст',
		'[0-9]*'..csep..'прист',
		'хил','пару',
		'солохил',
	},

	tank = {
		'[0-9]*'..csep..'танк', '[0-9]'..csep..'танка',
		'[0-9]*'..csep..'танка', 'танки','танк',
		'пару'..csep..'танков',
		'[0-9]*'..csep..'ппал', 'протопал',
		'[0-9]*'..csep..'пвар', 'протовар',
		'[0-9]*'..csep..'мт/от', '[0-9]*'..csep..'от',
		'дк'..csep..'танк', '[0-9]*'..csep..'танк'..csep..'дк',
	},
}

local gearscore_patterns = {
	'[1-3][0-9][0-9]%++',
	'[1-3][0-9][0-9]%+',
	'[1-3][0-9][0-9]',

}

local lfm_patterns = {
	'нид', 'нужны', 'нужен', 'надо', 'на'..csep..'фулл', 'на'..csep..'фул','помогите','рег','все'..csep..'%+','все',
	'*','дпс++','дд','хил', 'танк', 'м/г'..csep..'хм',
	'цлк'..csep..'10', 'цлк'..csep..'25', 'рс'..csep..'10', 'лич'..csep..'25'..csep..'хм',
	'рс'..csep..'25','са'..csep..'10','са'..csep..'25',
	'с'..csep..'а'..csep..'10', 'с'..csep..'а'..csep..'25', 'ивк'..csep..'10', 'ивк'..csep..'25',
	'ик'..csep..'25', 'ик'..csep..'10', 'склеп'..csep..'10', 'склеп'..csep..'25',
	'в'..csep..'ульду'..csep..'25', 'в'..csep..'ульду'..csep..'10', 'ульда'..csep..'10', 'ульда'..csep..'25',
}

lfm_channel_listeners = {
	['CHAT_MSG_CHANNEL'] = {},
	['CHAT_MSG_YELL'] = {},
	['CHAT_MSG_SAY'] = {},
};

local channel_listeners = {};

local guild_recruitment_patterns = {
	'гильдию',
	'гильдия',

	'набор',
	'рассмотрим',
	'pve',
	'guild',
	'рассмотрим',
	'rt',
	'kick',


	'проходок',
	'epgp',
	'ep',
	'приглашает',
	'закрываем',
	'приглашаются',
	'доступом',
	'набирает',
	'приглашаем',
	'хорошим',
	'онлайн',
	'закрытое',
	'приглашает',
	'требуется',
	'активность',
	'активных',
	'от нас',
	'от вас',
	'требуются',

	'осваиваем',
	'освоено',

	'прогресс',
	'рт',
	'ходим',
	'донабор',
	'открывает',
	'знаменитая',
	'статик',
	'pvp',
	'ведет'..csep..'набор',
	'ведет'..csep..'добор',
	'идет'..csep..'добор',
	'производит'..csep..'набор',
	'открыт'..csep..'набор',
	'в'..csep..'пве'..csep..'ги',
	'в'..csep..'ги',
	'в'..csep..'пве'..csep..'гильдию',
	'прогресс'..csep..'ги',

};

local wts_message_patterns = {
	'скупаю'..sep,
	'продам'..sep,
	'прода'..sep,
	'продает'..sep,
	'продажа'..sep,
	'продае'..sep,
	'продаёт'..sep,
	'голдран'..sep,
	'продаю'..sep,
	'куплю'..sep,
	'wts'..sep,
	'selling'..sep,
	'покупатель'..sep,
	'по всем вопросам'..sep,
	'покупателя'..sep,
	'покупатели'..sep,
};




local function refresh_lfm_messages()
	for name, info in pairs(raid_browser.lfm_messages) do
		-- If the last message from the sender was too long ago, then
		-- remove his raid from lfm_messages.
		if time() - info.time > raid_browser.expiry_time then
			raid_browser.lfm_messages[name] = nil;
		end
	end
end

local function lex_achievements(message)
	local achievement_pattern = '\124cffffff00\124.*\124h(%[.*%])\124h\124r';
	return message:gsub(achievement_pattern, '%1');
end

local function unlink_instlink(message)
	local instlink_pattern = '\124cff66bbff\124.*\124h(%[.*%])\124h\124r';
	return message:gsub(instlink_pattern, '%1');
end


local function format_gs_string(gs)

	local formatted = string.sub(gs, "+", " ")

	--formatted  = string.sub(formatted ,"1","% ")

	-- formatted = string.gsub(formatted,'', '')
	-- formatted = string.gsub(formatted,sep,'.');
	-- formatted = tonumber(formatted);

	-- if gs  > 1000 then
		-- gs  = gs / 1000 ;


	-- elseif gs > 100 then
		-- gs = gs / 100 ;


	-- elseif gs > 1 then
		-- gs = gs / 10;
	-- end


	return gs
	-- return string.format('%.1f', gs)
end



local function is_guild_recruitment(message)
	return std.algorithm.find_if(guild_recruitment_patterns, function(pattern)
		return string.find(message, pattern);
	end);
end

local function is_wts_message(message)
	return std.algorithm.find_if(wts_message_patterns, function(pattern)
		return string.find(message, pattern);
	end);
end

-- Basic http pattern matching for streaming sites and etc.
local function remove_http_links(message)
	local http_pattern = 'https?://*[%a]*.[%a]*.[%a]*/?[%a%-%%0-9_]*/?';
	return string.gsub(message, http_pattern, '');
end

local function find_roles(roles, message, pattern_table, role)
	local found = false;
	for _, pattern in ipairs(pattern_table[role]) do
		local result = string.find(message, pattern)

		-- If a raid was found then save it to our list of roles and continue.
		if result then
			found = true;

			-- Remove the substring from the message
			message = string.gsub(message, pattern, '')
		end
	end

	if not found then
		return roles, message;
	end

	table.insert(roles, role);
	return roles, message;
end

function raid_browser.raid_info(message)
	if not message then return end;
	message = string.lower(message)
	message = remove_http_links(message);

	-- Stop if it's a guild recruit message
	if is_guild_recruitment(message) or is_wts_message(message) then
		return;
	end

	-- Search for LFM announcement in the message
	local lfm_found = std.algorithm.find_if(lfm_patterns, function(pattern) return string.find(message, pattern) end)

	if not lfm_found then
		return;
	end

	-- Get the raid_info from the message
	local raid_info = nil;
	for _, r in ipairs(raid_list) do
		for _, pattern in ipairs(r.patterns) do
			local result = string.find(message, pattern);

			-- If a raid was found then save it and continue.
			if result then
				raid_info = r;

				-- Remove the substring from the message
				message = string.gsub(message, pattern, '')
				break
			end
		end

		if raid_info then
			break;
		end
	end

	message = lex_achievements(message);
	message = unlink_instlink(message);

	-- Get any roles that are needed
	local roles = {};

	--if string.find(message, '
	if not string.find(message, 'lfm? all ') and not string.find(message, 'need all ') then
		roles, message  = find_roles(roles, message, role_patterns, 'dps');
		roles, message  = find_roles(roles, message, role_patterns, 'tank');
		roles, message = find_roles(roles, message, role_patterns, 'healer');
	end

	-- If there is only an LFM message, then it is assumed that all roles are needed
	if #roles == 0 then
		roles = {'dps', 'tank', 'healer'}
	end

	local gs = gs;


	-- Search for a gearscore requirement.
	for _, pattern in pairs(gearscore_patterns) do
		local gs_start, gs_end = string.find(message, pattern)
		 local gs_final = string.match(message, pattern)
		-- If a gs requirement was found, then save it and continue.
		if gs_start and gs_end then
		-- return
			 -- return gs_start

			  gs = gs_final;
			--gs = format_gs_string(string.sub(message, gs_start))
			else gs = 'нет'

		end
	end
-- local language = language;
		-- local language = languageName()
		-- if language  then
		-- language = "орочий"

-- end

	return raid_info, roles, gs
	-- , 	 language
end

local function is_lfm_channel(channel)
	return channel == 'CHAT_MSG_CHANNEL' or channel == 'CHAT_MSG_YELL' or channel == 'CHAT_MSG_SAY';
end
-- local arg1, arg2, arg3 = ...;

local function event_handler(self, event, message, sender,channel,  ...)



  if is_lfm_channel(event) then
		local raid_info, roles, gs   = raid_browser.raid_info(message)
		arg2 = arg2
		arg3 = arg3
		if raid_info and roles and gs and (arg2 == "Пьяная") and (arg3 == "всеобщий") then
			-- Put the sender in the table of active raids
			raid_browser.lfm_messages[sender] = {
				sender = "|cff00ff00"..sender,
				raid_info = raid_info,
				roles = roles,
				gs = "|cff00ff00"..gs,
				time = time(),
				message = message.."\n|cff00ff00Хозяин собирает Альянс|r",
			};

		elseif raid_info and roles and gs and (arg2 == "Пьяная") and (arg3 == "орочий") then

			raid_browser.lfm_messages[sender] = {
				sender = "|cff00ff00"..sender,
				raid_info = raid_info,
				roles = roles,
				gs = "|cff00ff00"..gs,
				time = time(),
				message = message.."\n|cff00ff00Хозяин собирает Орду|r",
			};

		elseif raid_info and roles and gs and (arg2 == "Пьяная") and (arg3 == "арго скорпидов") then

			raid_browser.lfm_messages[sender] = {
				sender = "|cff00ff00"..sender,
				raid_info = raid_info,
				roles = roles,
				gs = "|cff00ff00"..gs,
				time = time(),
				message = message.."\n|cff00ff00Хозяин собирает Ренегатов|r",
			};

		elseif raid_info and roles and gs and (arg3 == "орочий")  then


			raid_browser.lfm_messages[sender] = {
				sender = "|cffff0000"..sender,
				raid_info = raid_info,
				roles = roles,
				gs = gs,
				time = time(),
				message = message.."\n|cffff0000Орда|r",
			};

		elseif raid_info and roles and gs and (arg3 == "всеобщий")  then

			raid_browser.lfm_messages[sender] = {
				sender = "|cff00E5EE"..sender,
				raid_info = raid_info,
				roles = roles,
				gs = gs,
				time = time(),
				message = message.."\n|cff0000ffАльянс|r",
			};
		elseif raid_info and roles and gs and (arg3 == "арго скорпидов")  then

			raid_browser.lfm_messages[sender] = {
				sender = "|cffffcc00"..sender,
				raid_info = raid_info,
				roles = roles,
				gs = gs,
				time = time(),
				message = message.."\n|cffffcc00Ренегаты|r",
			};

		end


	raid_browser.gui.update_list();

		end
	end


function raid_browser:OnEnable()
	raid_browser:Print('Загружен. Пиши /rb чтобы открыть RaidBrowser.')

	-- LFM messages expire after 60 seconds
	raid_browser.expiry_time = 60;

	raid_browser.lfm_messages = {}
	raid_browser.timer = raid_browser.set_timer(10, refresh_lfm_messages, true)
	local i=1
	for channel, listener in pairs(lfm_channel_listeners) do
		channel_listeners[i] = raid_browser.add_event_listener(channel, event_handler)
		i=i+1
	end


end

function raid_browser:OnDisable()
	for channel, listener in pairs(lfm_channel_listeners) do
		raid_browser.remove_event_listener(channel, listener)
	end

	raid_browser.kill_timer(raid_browser.timer)
end