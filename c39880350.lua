--聖天樹の精霊
-- 效果：
-- 包含「圣天树」连接怪兽的植物族怪兽2只
-- ①：这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
-- ②：自己因战斗·效果受到伤害的场合才能发动。自己基本分回复那个数值，从额外卡组把1只「圣蔓」怪兽特殊召唤。这个效果1回合可以使用最多2次。
function c39880350.initial_effect(c)
	-- 添加连接召唤手续，要求使用2只满足条件的植物族连接怪兽作为素材
	aux.AddLinkProcedure(c,c39880350.mfilter,2,2,c39880350.lcheck)
	c:EnableReviveLimit()
	-- 这张卡不会被作为攻击对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 自己因战斗·效果受到伤害的场合才能发动
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
-- 过滤条件：连接怪兽必须是植物族
function c39880350.mfilter(c)
	return c:IsLinkRace(RACE_PLANT)
end
-- 检查连接怪兽组中是否存在包含「圣天树」系列的连接怪兽
function c39880350.lcheck(g)
	return g:IsExists(c39880350.lcfilter,1,nil)
end
-- 连接怪兽必须是连接类型且包含「圣天树」系列
function c39880350.lcfilter(c)
	return c:IsLinkType(TYPE_LINK) and c:IsLinkSetCard(0x2158)
end
-- 过滤条件：「圣蔓」怪兽且可以特殊召唤且场上存在召唤空间
function c39880350.spfilter(c,e,tp)
	-- 「圣蔓」怪兽且可以特殊召唤且场上存在召唤空间
	return c:IsSetCard(0x1158) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 伤害来源为自己的场合且伤害由战斗或效果造成
function c39880350.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 设置连锁操作信息，确定特殊召唤和回复的处理对象
function c39880350.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在满足条件的「圣蔓」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c39880350.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的处理对象为额外卡组的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置回复LP的处理对象为自身并指定回复数值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,1,tp,ev)
end
-- 执行效果处理，回复LP并选择特殊召唤「圣蔓」怪兽
function c39880350.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行回复LP操作，若成功则继续处理特殊召唤
	if Duel.Recover(tp,ev,REASON_EFFECT)~=0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足条件的「圣蔓」怪兽
		local g=Duel.SelectMatchingCard(tp,c39880350.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
