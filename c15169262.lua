--ラヴァル炎樹海の妖女
-- 效果：
-- 这张卡从场上送去墓地时，自己场上表侧表示存在的名字带有「熔岩」的怪兽的攻击力直到结束阶段时上升自己墓地存在的名字带有「熔岩」的怪兽数量×200的数值。
function c15169262.initial_effect(c)
	-- 这张卡从场上送去墓地时，自己场上表侧表示存在的名字带有「熔岩」的怪兽的攻击力直到结束阶段时上升自己墓地存在的名字带有「熔岩」的怪兽数量×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15169262,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c15169262.condition)
	e1:SetOperation(c15169262.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：这张卡是从场上送去墓地的
function c15169262.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数：返回场上表侧表示且名字带有「熔岩」的怪兽
function c15169262.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x39)
end
-- 效果处理：检索满足条件的场上表侧表示的「熔岩」怪兽，为它们加上攻击力提升效果
function c15169262.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的场上表侧表示的「熔岩」怪兽组
	local g=Duel.GetMatchingGroup(c15169262.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	if not tc then return end
	local c=e:GetHandler()
	-- 计算自己墓地里名字带有「熔岩」的怪兽数量并乘以200作为攻击力提升值
	local atk=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x39)*200
	while tc do
		-- 为满足条件的怪兽加上攻击力提升效果，提升值为之前计算的数值，效果在结束阶段重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
