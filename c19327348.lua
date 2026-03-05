--闇霊使いダルク
-- 效果：
-- ①：这张卡反转的场合，以对方场上1只暗属性怪兽为对象发动。这只怪兽表侧表示存在期间，得到那只怪兽的控制权。
function c19327348.initial_effect(c)
	-- 这张卡反转时发动，以对方场上1只暗属性怪兽为对象，得到那只怪兽的控制权
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19327348,0))  --"获得对方场上1只暗属性怪兽的控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c19327348.target)
	e1:SetOperation(c19327348.operation)
	c:RegisterEffect(e1)
end
-- 筛选满足表侧表示、暗属性且可以改变控制权的怪兽
function c19327348.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToChangeControler()
end
-- 选择目标怪兽，设置为对方场上1只暗属性怪兽
function c19327348.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c19327348.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c19327348.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，确定将要改变控制权的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 将目标怪兽的控制权转移给发动者
function c19327348.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 为选中的怪兽设置控制权效果，使其在表侧表示存在期间控制权归发动者
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetValue(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c19327348.ctcon)
		tc:RegisterEffect(e1)
	end
end
-- 判断目标怪兽是否仍处于发动者控制下，用于控制权效果的条件判断
function c19327348.ctcon(e)
	local c=e:GetOwner()
	local h=e:GetHandler()
	return c:IsHasCardTarget(h)
end
