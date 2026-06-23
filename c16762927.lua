--墓守の使い魔
-- 效果：
-- 对方若不把卡组最上面的1张卡送去墓地，则不能攻击宣言。
function c16762927.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方若不把卡组最上面的1张卡送去墓地，则不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ATTACK_COST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCost(c16762927.atcost)
	e2:SetOperation(c16762927.atop)
	c:RegisterEffect(e2)
	-- 对方若不把卡组最上面的1张卡送去墓地，则不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_FLAG_EFFECT+16762927)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
end
-- 检查玩家是否能作为Cost把count张卡送去墓地。
function c16762927.atcost(e,c,tp)
	-- 获取玩家当前已使用的标记效果数量。
	local ct=Duel.GetFlagEffect(tp,16762927)
	-- 判断玩家是否能支付将count张卡从卡组送去墓地的代价。
	return Duel.IsPlayerCanDiscardDeckAsCost(tp,ct)
end
-- 将玩家卡组最上面的1张卡送去墓地。
function c16762927.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行将卡组最上端1张卡送去墓地的操作。
	Duel.DiscardDeck(tp,1,REASON_COST)
end
