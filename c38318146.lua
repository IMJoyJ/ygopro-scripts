--暴君の暴力
-- 效果：
-- 把自己场上存在的2只怪兽解放发动。只要这张卡在场上存在，对方若不从卡组把1张魔法卡送去墓地则不能把魔法卡发动。
function c38318146.initial_effect(c)
	-- 把自己场上存在的2只怪兽解放发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c38318146.cost)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，对方若不从卡组把1张魔法卡送去墓地则不能把魔法卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ACTIVATE_COST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c38318146.accon)
	e2:SetTarget(c38318146.actarget)
	e2:SetCost(c38318146.accost)
	e2:SetOperation(c38318146.acop)
	c:RegisterEffect(e2)
end
-- 作为发动代价，从自己场上选择2只怪兽解放。
function c38318146.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己场上是否存在至少2只可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,2,nil) end
	-- 选择自己要解放的2只怪兽。
	local rg=Duel.SelectReleaseGroup(tp,nil,2,2,nil)
	-- 将选择的2只怪兽作为代价解放。
	Duel.Release(rg,REASON_COST)
end
-- 效果适用条件：每次检查时重置已送墓标记为false，并返回true使效果适用。
function c38318146.accon(e)
	c38318146[0]=false
	return true
end
-- 过滤函数：选择卡组中的魔法卡，且该卡可以作为代价送去墓地。
function c38318146.acfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 目标判定：对方发动的效果必须是魔法卡的发动才适用此代价。
function c38318146.actarget(e,te,tp)
	return te:IsActiveType(TYPE_SPELL) and te:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 附加代价检测：确认对方卡组中是否存在至少1张可作为代价送去墓地的魔法卡。
function c38318146.accost(e,te,tp)
	-- 检查对方卡组中是否存在至少1张满足acfilter的魔法卡。
	return Duel.IsExistingMatchingCard(c38318146.acfilter,tp,LOCATION_DECK,0,1,nil)
end
-- 实际执行代价：若尚未执行过此代价，则对方从卡组选择1张魔法卡送去墓地并设置标记，避免重复处理。
function c38318146.acop(e,tp,eg,ep,ev,re,r,rp)
	if c38318146[0] then return end
	-- 向对方玩家显示‘请选择要送去墓地的卡’的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 对方从自己的卡组中选择1张满足条件的魔法卡。
	local g=Duel.SelectMatchingCard(tp,c38318146.acfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的魔法卡送去墓地，作为对方发动魔法卡的代价。
	Duel.SendtoGrave(g,REASON_COST)
	c38318146[0]=true
end
