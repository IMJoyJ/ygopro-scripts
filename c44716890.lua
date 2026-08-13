--通行増税
-- 效果：
-- ①：双方玩家若不把1张手卡送去墓地则不能攻击宣言。
function c44716890.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：双方玩家若不把1张手卡送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ATTACK_COST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCost(c44716890.atcost)
	e2:SetOperation(c44716890.atop)
	c:RegisterEffect(e2)
	-- 则不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_FLAG_EFFECT+44716890)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	c:RegisterEffect(e3)
end
-- 作为攻击代价的判定函数，检查当前玩家的手牌中是否存在足够数量（至少ct张）可以送去墓地的卡，以允许进行攻击宣言。
function c44716890.atcost(e,c,tp)
	-- 获取当前玩家tp身上编号为44716890的标志效果数量ct，用于累计该玩家已进行过攻击宣言的次数（或已需要支付的手牌数）。
	local ct=Duel.GetFlagEffect(tp,44716890)
	-- 检查当前玩家手牌中是否存在至少ct张能够作为代价送去墓地的卡片，存在则允许攻击宣言。
	return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,ct,nil)
end
-- 攻击宣言代价的实际处理函数：当前玩家选择手牌并送去墓地。
function c44716890.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家显示选择提示，提示其选择一张要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让当前玩家从手牌中选择1张可作为代价送去墓地的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡以代价（REASON_COST）送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
