--強化人類サイコ
-- 效果：
-- 把自己墓地存在的1只念动力族怪兽从游戏中除外发动。这张卡的攻击力上升500。这个效果1回合可以使用最多2次。
function c80102359.initial_effect(c)
	-- 把自己墓地存在的1只念动力族怪兽从游戏中除外发动。这张卡的攻击力上升500。这个效果1回合可以使用最多2次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80102359,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2)
	e1:SetCost(c80102359.cost)
	e1:SetOperation(c80102359.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地可以作为发动代价除外的念动力族怪兽
function c80102359.cfilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：把自己墓地存在的1只念动力族怪兽从游戏中除外
function c80102359.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c80102359.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c80102359.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理：使这张卡的攻击力上升500
function c80102359.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
