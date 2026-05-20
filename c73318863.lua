--光霊使いライナ
-- 效果：
-- ①：这张卡反转的场合，以对方场上1只光属性怪兽为对象发动。这只怪兽表侧表示存在期间，得到那只怪兽的控制权。
function c73318863.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上1只光属性怪兽为对象发动。这只怪兽表侧表示存在期间，得到那只怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73318863,0))  --"获得对方场上1只光属性怪兽的控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c73318863.target)
	e1:SetOperation(c73318863.operation)
	c:RegisterEffect(e1)
end
-- 过滤满足“表侧表示”、“光属性”且“可以改变控制权”的怪兽
function c73318863.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToChangeControler()
end
-- 效果发动的目标选择与检测函数
function c73318863.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c73318863.filter(chkc) end
	if chk==0 then return true end
	-- 给玩家发送提示信息，提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只符合条件的光属性怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c73318863.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为改变所选怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果处理函数，在自身表侧表示且对象合法时，建立对象关系并转移控制权
function c73318863.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 这只怪兽表侧表示存在期间，得到那只怪兽的控制权。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetValue(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c73318863.ctcon)
		tc:RegisterEffect(e1)
	end
end
-- 控制权转移效果的持续条件：自身（光灵使 莱娜）仍将目标怪兽作为对象（即自身表侧表示存在）
function c73318863.ctcon(e)
	local c=e:GetOwner()
	local h=e:GetHandler()
	return c:IsHasCardTarget(h)
end
