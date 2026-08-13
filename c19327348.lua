--闇霊使いダルク
-- 效果：
-- ①：这张卡反转的场合，以对方场上1只暗属性怪兽为对象发动。这只怪兽表侧表示存在期间，得到那只怪兽的控制权。
function c19327348.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上1只暗属性怪兽为对象发动。这只怪兽表侧表示存在期间，得到那只怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19327348,0))  --"获得对方场上1只暗属性怪兽的控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c19327348.target)
	e1:SetOperation(c19327348.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择对方场上表侧表示、暗属性且能够改变控制权的怪兽。
function c19327348.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToChangeControler()
end
-- 发动时的目标处理：验证对象合法性（对方场上表侧暗属性且可改变控制权）、提示选择、从对方怪兽区选择1只作为对象，并设置改变控制权的操作信息。
function c19327348.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c19327348.filter(chkc) end
	if chk==0 then return true end
	-- 给玩家显示选择提示，内容为“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方场上选择1只满足条件的暗属性怪兽作为效果对象（取对象），选中的卡会与当前连锁关联。
	local g=Duel.SelectTarget(tp,c19327348.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：本次处理将改变控制权，对象为已选目标卡组，数量为其数量。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果处理：若发动怪兽仍与效果关联且表侧表示、目标仍关联且不免疫此效果，则将目标设为发动怪兽的永续对象，为对象附加把控制权转移给tp的永续效果，并在标准重置时机或不再满足持续条件时解除。
function c19327348.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的目标怪兽。
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
		e1:SetCondition(c19327348.ctcon)
		tc:RegisterEffect(e1)
	end
end
-- 持续条件：仅当效果持有者（暗灵使）仍以所控制的目标怪兽为永续对象时，控制权变更效果才继续适用。
function c19327348.ctcon(e)
	local c=e:GetOwner()
	local h=e:GetHandler()
	return c:IsHasCardTarget(h)
end
