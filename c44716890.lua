--通行増税
-- 效果：
-- ①：双方玩家若不把1张手卡送去墓地则不能攻击宣言。
function c44716890.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：双方玩家若不把1张手卡送去墓地则不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ATTACK_COST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCost(c44716890.atcost)
	e2:SetOperation(c44716890.atop)
	c:RegisterEffect(e2)
	-- ①：双方玩家若不把1张手卡送去墓地则不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_FLAG_EFFECT+44716890)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	c:RegisterEffect(e3)
end
-- 判断是否满足支付攻击代价的条件，即手卡是否有足够数量的卡可以送去墓地
function c44716890.atcost(e,c,tp)
	-- 获取玩家当前已使用的“通行增税”效果次数
	local ct=Duel.GetFlagEffect(tp,44716890)
	-- 检查玩家手卡中是否存在满足条件的卡（数量等于已使用次数）
	return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,ct,nil)
end
-- 执行攻击宣言时的处理，提示玩家选择将手卡送去墓地
function c44716890.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示其选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选择1张可送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡送去墓地作为攻击宣言的代价
	Duel.SendtoGrave(g,REASON_COST)
end
