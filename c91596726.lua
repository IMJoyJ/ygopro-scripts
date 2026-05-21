--ダーク・クルセイダー
-- 效果：
-- 可以从手卡把1只暗属性怪兽送去墓地，这张卡的攻击力上升400。
function c91596726.initial_effect(c)
	-- 可以从手卡把1只暗属性怪兽送去墓地，这张卡的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91596726,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c91596726.cost)
	e1:SetOperation(c91596726.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：手牌中可以作为代价送去墓地的暗属性怪兽
function c91596726.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGraveAsCost()
end
-- 发动代价：从手卡把1只暗属性怪兽送去墓地
function c91596726.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1只可以作为代价送去墓地的暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91596726.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择手牌中1只满足条件的暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,c91596726.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果处理：若此卡在场上表侧表示存在，则使其攻击力上升400
function c91596726.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升400
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
