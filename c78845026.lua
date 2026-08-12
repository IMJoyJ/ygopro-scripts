--ライトニング・チューン
-- 效果：
-- 选择自己场上表侧表示存在的1只4星的光属性怪兽发动。选择怪兽只要在场上表侧表示存在当作调整使用。
function c78845026.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只4星的光属性怪兽发动。选择怪兽只要在场上表侧表示存在当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c78845026.target)
	e1:SetOperation(c78845026.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示、4星、光属性且不是调整的怪兽
function c78845026.filter(c)
	return c:IsFaceup() and c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and not c:IsType(TYPE_TUNER)
end
-- 效果发动的靶向处理，用于确认和选择符合条件的对象怪兽
function c78845026.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c78845026.filter(chkc) end
	-- 在发动阶段检查场上是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c78845026.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c78845026.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理，使选择的对象怪兽在场上表侧表示存在期间当作调整使用
function c78845026.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择怪兽只要在场上表侧表示存在当作调整使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
