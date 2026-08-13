--副話術士クララ＆ルーシカ
-- 效果：
-- 通常召唤的怪兽1只
-- 这张卡的连接召唤不在主要阶段2不能进行。
function c1482001.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加连接召唤手续：限定使用1只“曾通过通常召唤出场的怪兽”作为连接素材（即1只通常召唤的怪兽）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSummonType,SUMMON_TYPE_NORMAL),1,1)
	-- 这张卡的连接召唤不在主要阶段2不能进行。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_COST)
	e1:SetCost(c1482001.spcost)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤代价判定函数：若进行的是连接召唤，则必须满足特定条件；若不是连接召唤则不受限制，以此限制连接召唤的发动时机。
function c1482001.spcost(e,c,tp,st)
	if bit.band(st,SUMMON_TYPE_LINK)~=SUMMON_TYPE_LINK then return true end
	-- 判断当前游戏阶段是否为主要阶段2，若为真则允许该连接召唤进行。
	return Duel.GetCurrentPhase()==PHASE_MAIN2
end
