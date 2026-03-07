--地霊使いアウス
-- 效果：
-- ①：这张卡反转的场合，以对方场上1只地属性怪兽为对象发动。这只怪兽表侧表示存在期间，得到作为对象的怪兽的控制权。
function c37970940.initial_effect(c)
	-- 效果原文内容：①：这张卡反转的场合，以对方场上1只地属性怪兽为对象发动。这只怪兽表侧表示存在期间，得到作为对象的怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37970940,0))  --"获得对方场上1只地属性怪兽的控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c37970940.target)
	e1:SetOperation(c37970940.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的对方场上地属性怪兽
function c37970940.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToChangeControler()
end
-- 选择对象怪兽并设置操作信息
function c37970940.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c37970940.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示“请选择要改变控制权的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只地属性怪兽作为对象
	local g=Duel.SelectTarget(tp,c37970940.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 处理控制权转移效果
function c37970940.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 为对象怪兽注册控制权效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetValue(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c37970940.ctcon)
		tc:RegisterEffect(e1)
	end
end
-- 判断对象怪兽是否仍处于控制权效果影响下
function c37970940.ctcon(e)
	local c=e:GetOwner()
	local h=e:GetHandler()
	return c:IsHasCardTarget(h)
end
