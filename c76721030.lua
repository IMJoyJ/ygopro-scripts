--暴君の暴言
-- 效果：
-- 把自己场上存在的2只怪兽解放发动。只要这张卡在场上存在，双方不能把手卡以及场上发动的效果怪兽的效果发动。
function c76721030.initial_effect(c)
	-- 把自己场上存在的2只怪兽解放发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c76721030.cost)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，双方不能把手卡以及场上发动的效果怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(c76721030.aclimit)
	c:RegisterEffect(e2)
end
-- 定义卡片发动的代价（Cost）函数，用于解放自己场上的2只怪兽
function c76721030.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认自己场上是否存在至少2只可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,2,nil) end
	-- 让玩家从自己场上选择2只可解放的怪兽
	local rg=Duel.SelectReleaseGroup(tp,nil,2,2,nil)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(rg,REASON_COST)
end
-- 定义禁止发动的效果范围：在手牌或场上发动的效果怪兽的效果
function c76721030.aclimit(e,re,tp)
	local loc=re:GetActivateLocation()
	return (loc==LOCATION_MZONE or loc==LOCATION_HAND) and re:IsActiveType(TYPE_MONSTER)
end
