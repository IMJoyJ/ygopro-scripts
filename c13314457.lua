--深海の大ウナギ
-- 效果：
-- 这张卡从场上送去墓地时，自己场上表侧表示存在的全部水属性怪兽的攻击力直到结束阶段时上升500。
function c13314457.initial_effect(c)
	-- 这张卡从场上送去墓地时，自己场上表侧表示存在的全部水属性怪兽的攻击力直到结束阶段时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13314457,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c13314457.condition)
	e1:SetOperation(c13314457.operation)
	c:RegisterEffect(e1)
end
-- 检查此卡是否从场上离开
function c13314457.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：表侧表示的水属性怪兽
function c13314457.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果处理函数：为符合条件的怪兽增加攻击力
function c13314457.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检索满足条件的场上水属性怪兽组
	local g=Duel.GetMatchingGroup(c13314457.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 将攻击力增加500的效果应用到怪兽上，直到结束阶段重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
