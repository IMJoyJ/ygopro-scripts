--暴君の自暴自棄
-- 效果：
-- 把自己场上存在的衍生物以外的2只通常怪兽解放发动。只要这张卡在场上存在，双方不能把效果怪兽召唤·特殊召唤。
function c55271628.initial_effect(c)
	-- 把自己场上存在的衍生物以外的2只通常怪兽解放发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c55271628.cost)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，双方不能把效果怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c55271628.sumlimit)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e3)
end
-- 过滤自己场上存在的衍生物以外的通常怪兽
function c55271628.cfilter(c)
	local tpe=c:GetType()
	return bit.band(tpe,TYPE_NORMAL)~=0 and bit.band(tpe,TYPE_TOKEN)==0
end
-- 发动代价：解放自己场上2只衍生物以外的通常怪兽
function c55271628.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少2只满足条件的、可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c55271628.cfilter,2,nil) end
	-- 让玩家选择2只满足条件的、可解放的怪兽
	local rg=Duel.SelectReleaseGroup(tp,c55271628.cfilter,2,2,nil)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(rg,REASON_COST)
end
-- 限制召唤/特殊召唤的怪兽过滤：原本卡片类型为效果怪兽，且不属于再度召唤（二重）
function c55271628.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:GetOriginalType()&TYPE_EFFECT>0 and sumtype~=SUMMON_TYPE_DUAL
end
