--フォトン・ブースター
-- 效果：
-- 选择衍生物以外的场上表侧表示存在的1只4星以下的光属性怪兽发动。选择的怪兽以及场上表侧表示存在的同名的怪兽的攻击力直到结束阶段时变成2000。
function c71233859.initial_effect(c)
	-- 选择衍生物以外的场上表侧表示存在的1只4星以下的光属性怪兽发动。选择的怪兽以及场上表侧表示存在的同名的怪兽的攻击力直到结束阶段时变成2000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c71233859.target)
	e1:SetOperation(c71233859.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示、非衍生物、4星以下的光属性怪兽
function c71233859.filter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 效果发动时的目标选择与合法性检测
function c71233859.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c71233859.filter(chkc) end
	-- 检查场上是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c71233859.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c71233859.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 过滤场上表侧表示且与指定卡片同名的怪兽
function c71233859.afilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 效果处理，使对象怪兽以及场上同名怪兽的攻击力直到结束阶段变成2000
function c71233859.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 获取场上所有与对象怪兽同名的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c71233859.afilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc:GetCode())
	local tc=g:GetFirst()
	while tc do
		-- 攻击力直到结束阶段时变成2000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(2000)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
