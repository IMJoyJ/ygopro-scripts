--暴君の暴力
-- 效果：
-- 把自己场上存在的2只怪兽解放发动。只要这张卡在场上存在，对方若不从卡组把1张魔法卡送去墓地则不能把魔法卡发动。
function c38318146.initial_effect(c)
	-- 卡片效果：把自己场上存在的2只怪兽解放发动。
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
-- 检查玩家是否可以解放2只怪兽作为发动代价
function c38318146.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以解放2只怪兽作为发动代价
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,2,nil) end
	-- 选择2只怪兽进行解放
	local rg=Duel.SelectReleaseGroup(tp,nil,2,2,nil)
	-- 将选中的怪兽解放作为发动代价
	Duel.Release(rg,REASON_COST)
end
-- 设置效果的发动条件，用于控制是否触发效果
function c38318146.accon(e)
	c38318146[0]=false
	return true
end
-- 定义魔法卡的过滤条件，用于判断卡组中是否存在可作为代价送去墓地的魔法卡
function c38318146.acfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 设置效果的目标过滤条件，用于判断是否为魔法卡的发动
function c38318146.actarget(e,te,tp)
	return te:IsActiveType(TYPE_SPELL) and te:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 检查对方是否可以从卡组中选择一张魔法卡送去墓地作为发动代价
function c38318146.accost(e,te,tp)
	-- 检查对方是否可以从卡组中选择一张魔法卡送去墓地作为发动代价
	return Duel.IsExistingMatchingCard(c38318146.acfilter,tp,LOCATION_DECK,0,1,nil)
end
-- 当对方发动魔法卡时，若未满足代价则强制从卡组选择一张魔法卡送去墓地
function c38318146.acop(e,tp,eg,ep,ev,re,r,rp)
	if c38318146[0] then return end
	-- 提示玩家选择要送去墓地的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一张魔法卡从卡组送去墓地
	local g=Duel.SelectMatchingCard(tp,c38318146.acfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的魔法卡送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	c38318146[0]=true
end
