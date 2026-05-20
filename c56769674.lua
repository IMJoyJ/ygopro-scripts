--DNA移植手術
-- 效果：
-- 这张卡发动时，宣言1种属性。这张卡在场上存在时，场上所有表侧表示的怪兽全部变成被宣言的属性。
function c56769674.initial_effect(c)
	-- 这张卡发动时，宣言1种属性。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1c1)
	e1:SetTarget(c56769674.target)
	c:RegisterEffect(e1)
	-- 这张卡在场上存在时，场上所有表侧表示的怪兽全部变成被宣言的属性。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetValue(c56769674.value)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
-- 卡片发动时的效果处理，让玩家宣言1种属性，并将宣言的属性保存到永续效果中，同时在卡片上显示提示。
function c56769674.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家发送选择属性的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从所有属性中宣言1种属性。
	local rc=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	e:GetLabelObject():SetLabel(rc)
	e:GetHandler():SetHint(CHINT_ATTRIBUTE,rc)
end
-- 获取保存的宣言属性，作为改变属性效果的返回值。
function c56769674.value(e,c)
	return e:GetLabel()
end
