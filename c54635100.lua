--リンクルベル
-- 效果：
-- 怪兽2只
-- 这张卡的连接召唤不在自己的额外卡组的数量比对方多3张以上的场合不能进行。
function c54635100.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，需要2只怪兽作为素材
	aux.AddLinkProcedure(c,nil,2,2)
	-- 这张卡的连接召唤不在自己的额外卡组的数量比对方多3张以上的场合不能进行。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_COST)
	e1:SetCost(c54635100.spcost)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤的条件函数，若不是连接召唤则直接允许，若是连接召唤则需满足额外卡组数量差的条件
function c54635100.spcost(e,c,tp,st)
	if bit.band(st,SUMMON_TYPE_LINK)~=SUMMON_TYPE_LINK then return true end
	-- 判断自己额外卡组的卡片数量减去对方额外卡组的卡片数量是否大于等于3
	return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)-Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>=3
end
