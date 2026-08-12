--副話術士クララ＆ルーシカ
-- 效果：
-- 通常召唤的怪兽1只
-- 这张卡的连接召唤不在主要阶段2不能进行。
function c1482001.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用1只通常召唤的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSummonType,SUMMON_TYPE_NORMAL),1,1)
	-- 这张卡的连接召唤不在主要阶段2不能进行。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_COST)
	e1:SetCost(c1482001.spcost)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤时的费用函数
function c1482001.spcost(e,c,tp,st)
	if bit.band(st,SUMMON_TYPE_LINK)~=SUMMON_TYPE_LINK then return true end
	-- 费用条件为当前阶段必须是主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN2
end
