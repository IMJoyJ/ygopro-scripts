--風霊使いウィン
-- 效果：
-- ①：这张卡反转的场合，以对方场上1只风属性怪兽为对象发动。这只怪兽表侧表示存在期间，得到作为对象的怪兽的控制权。
function c37744402.initial_effect(c)
	-- 创建一个反转时发动的效果，用于获得对方场上1只风属性怪兽的控制权
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37744402,0))  --"获得对方场上1只风属性怪兽的控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c37744402.target)
	e1:SetOperation(c37744402.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择表侧表示、风属性且可以改变控制权的怪兽
function c37744402.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToChangeControler()
end
-- 效果处理时选择目标怪兽，条件为对方场上的风属性怪兽
function c37744402.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c37744402.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示“请选择要改变控制权的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上满足条件的1只风属性怪兽作为目标
	local g=Duel.SelectTarget(tp,c37744402.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表示将要改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果发动时执行的操作，将目标怪兽的控制权转移给使用者
function c37744402.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 为目标怪兽注册一个控制权效果，使其在表侧表示存在期间由使用者控制
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetValue(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c37744402.ctcon)
		tc:RegisterEffect(e1)
	end
end
-- 控制权变更条件函数：当目标怪兽仍被当前卡作为对象时生效
function c37744402.ctcon(e)
	local c=e:GetOwner()
	local h=e:GetHandler()
	return c:IsHasCardTarget(h)
end
