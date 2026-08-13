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
-- 作为 EFFECT_ATTACK_COST 的代价检查函数，判断对方玩家能否满足“把卡组最上面的1张卡送去墓地”的代价；通过查询对方玩家身上的守墓的使魔标记数量来决定需要丢弃的卡数（此处为1），并调用 Duel.IsPlayerCanDiscardDeckAsCost 检查是否能将等量卡组送去墓地。
function c16762927.atcost(e,c,tp)
	-- 取得对方玩家 tp 身上 code 为 16762927 的标记效果数量，用于表示该效果要求丢弃的卡组数量（由于 e3 的注册，此处通常为1）。
	local ct=Duel.GetFlagEffect(tp,16762927)
	-- 返回对方玩家 tp 能否将 ct 张卡组最上面的卡作为 Cost 送去墓地；若可行则允许攻击宣言支付代价，否则不能攻击宣言。
	return Duel.IsPlayerCanDiscardDeckAsCost(tp,ct)
end
-- EFFECT_ATTACK_COST 的代价支付操作函数，在对方玩家攻击宣言时，实际执行“把卡组最上面的1张卡送去墓地”的处理。
function c16762927.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方玩家 tp 的卡组最上面1张卡以 Cost 为理由送去墓地，从而完成攻击宣言所需的代价。
	Duel.DiscardDeck(tp,1,REASON_COST)
end
