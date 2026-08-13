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
-- 发动条件：这张卡是从场上（而非手牌或卡组等地方）送去墓地。
function c15169262.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选自己场上表侧表示、且名字带有「熔岩」的怪兽。
function c15169262.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x39)
end
-- 效果处理：先获取自己场上符合条件的熔岩怪兽，再计算自己墓地熔岩怪兽数量×200作为攻击力上升值，为每只符合条件的怪兽赋予直到结束阶段生效的攻击力上升效果。
function c15169262.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上表侧表示的名字带有「熔岩」的怪兽的集合。
	local g=Duel.GetMatchingGroup(c15169262.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	if not tc then return end
	local c=e:GetHandler()
	-- 计数自己墓地中名字带有「熔岩」的怪兽数量，乘以200得到攻击力上升数值。
	local atk=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x39)*200
	while tc do
		-- 自己场上表侧表示存在的名字带有「熔岩」的怪兽的攻击力直到结束阶段时上升自己墓地存在的名字带有「熔岩」的怪兽数量×200的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
