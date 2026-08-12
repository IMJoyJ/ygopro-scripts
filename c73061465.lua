--氷結界の封魔団
-- 效果：
-- ①：1回合1次，从手卡把1只「冰结界」怪兽送去墓地才能发动。这只怪兽表侧表示存在期间，直到下次的自己回合的结束时双方不能把魔法卡发动。
function c73061465.initial_effect(c)
	-- ①：1回合1次，从手卡把1只「冰结界」怪兽送去墓地才能发动。这只怪兽表侧表示存在期间，直到下次的自己回合的结束时双方不能把魔法卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73061465,0))  --"不能发动魔法卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c73061465.cost)
	e1:SetOperation(c73061465.operation)
	c:RegisterEffect(e1)
end
-- 过滤手卡中可以送去墓地的「冰结界」怪兽，或墓地中可适用的替代卡
function c73061465.cfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
	else
		return e:GetHandler():IsSetCard(0x2f) and c:IsAbleToRemove() and c:IsHasEffect(18319762,tp)
	end
end
-- 发动代价：从手卡将1只「冰结界」怪兽送去墓地（或使用墓地替代卡）
function c73061465.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手卡或墓地是否存在可作为代价的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c73061465.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张手卡中的「冰结界」怪兽或墓地中的替代卡
	local g=Duel.SelectMatchingCard(tp,c73061465.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local te=tc:IsHasEffect(18319762,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将替代卡表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		-- 将选中的「冰结界」怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_COST)
	end
end
-- 效果处理：若此卡表侧表示存在，则适用封锁魔法卡发动的效果
function c73061465.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这只怪兽表侧表示存在期间，直到下次的自己回合的结束时双方不能把魔法卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c73061465.tgval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,3)
	c:RegisterEffect(e1)
end
-- 限制发动的类型判定：魔法卡的发动
function c73061465.tgval(e,re,rp)
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
