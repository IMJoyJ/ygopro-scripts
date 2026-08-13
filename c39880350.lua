--聖天樹の精霊
-- 效果：
-- 包含「圣天树」连接怪兽的植物族怪兽2只
-- ①：这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
-- ②：自己因战斗·效果受到伤害的场合才能发动。自己基本分回复那个数值，从额外卡组把1只「圣蔓」怪兽特殊召唤。这个效果1回合可以使用最多2次。
function c39880350.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要2只植物族怪兽作为连接素材，且其中必须包含1只「圣天树」连接怪兽。
	aux.AddLinkProcedure(c,c39880350.mfilter,2,2,c39880350.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：自己因战斗·效果受到伤害的场合才能发动。自己基本分回复那个数值，从额外卡组把1只「圣蔓」怪兽特殊召唤。这个效果1回合可以使用最多2次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39880350,0))  --"回复并特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(2)
	e2:SetCondition(c39880350.spcon)
	e2:SetTarget(c39880350.sptg)
	e2:SetOperation(c39880350.spop)
	c:RegisterEffect(e2)
end
-- 连接素材筛选条件：该怪兽作为连接素材时种族为植物族。
function c39880350.mfilter(c)
	return c:IsLinkRace(RACE_PLANT)
end
-- 连接素材组检查：素材中必须存在至少1只满足 lcfilter 的怪兽，即包含「圣天树」连接怪兽。
function c39880350.lcheck(g)
	return g:IsExists(c39880350.lcfilter,1,nil)
end
-- 素材额外条件：该怪兽是连接怪兽且持有「圣天树」字段（0x2158）。
function c39880350.lcfilter(c)
	return c:IsLinkType(TYPE_LINK) and c:IsLinkSetCard(0x2158)
end
-- 特殊召唤候选筛选函数：从额外卡组中选出「圣蔓」字段怪兽，可被当前效果特殊召唤，且己方有额外卡组怪兽可用的空格。
function c39880350.spfilter(c,e,tp)
	-- 过滤条件：该卡是「圣蔓」字段怪兽、可被效果特殊召唤、且从额外卡组特殊召唤时有可用区域。
	return c:IsSetCard(0x1158) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的发动条件：己方受到战斗或效果伤害的场合。
function c39880350.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- ②效果的发动时处理：检查额外卡组存在可特殊召唤的「圣蔓」怪兽，并登记特殊召唤与回复生命值的操作信息。
function c39880350.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：额外卡组存在至少1只符合条件的「圣蔓」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c39880350.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果包含从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：本次效果包含回复生命值，数值为受到的伤害值 ev。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,1,tp,ev)
end
-- ②效果的解决处理：先回复生命值，若回复成功，则从额外卡组选1只「圣蔓」怪兽特殊召唤。
function c39880350.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行回复生命值操作，若实际回复值不为0（未因“回复变伤害”等效果变为0）则继续后续处理。
	if Duel.Recover(tp,ev,REASON_EFFECT)~=0 then
		-- 显示提示信息，要求玩家选择要特殊召唤的卡（“请选择要特殊召唤的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1张满足 spfilter 条件的「圣蔓」怪兽。
		local g=Duel.SelectMatchingCard(tp,c39880350.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选中的「圣蔓」怪兽以表侧表示特殊召唤到己方场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
