--火霊使いヒータ
-- 效果：
-- ①：这张卡反转的场合，以对方场上1只炎属性怪兽为对象发动。这只怪兽表侧表示存在期间，得到作为对象的怪兽的控制权。
function c759393.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上1只炎属性怪兽为对象发动。这只怪兽表侧表示存在期间，得到作为对象的怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(759393,0))  --"获得对方场上1只炎属性怪兽的控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c759393.target)
	e1:SetOperation(c759393.operation)
	c:RegisterEffect(e1)
end
-- 过滤对方场上表侧表示、炎属性且可以改变控制权的怪兽
function c759393.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToChangeControler()
end
-- 效果①的发动准备，进行取对象检测，并选择对方场上1只炎属性怪兽作为对象
function c759393.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c759393.filter(chkc) end
	if chk==0 then return true end
	-- 在系统提示框中显示“请选择要改变控制权的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家选择对方场上1只满足过滤条件的炎属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c759393.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为“改变控制权”，目标为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果①的处理，若自身在场且表侧表示，且目标怪兽仍存在，则建立对象关系并获得该怪兽的控制权
function c759393.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 这只怪兽表侧表示存在期间，得到作为对象的怪兽的控制权。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetValue(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c759393.ctcon)
		tc:RegisterEffect(e1)
	end
end
-- 控制权转移效果的持续条件：此卡（火灵使 希塔）仍将目标怪兽作为对象（即此卡表侧表示存在于场上）
function c759393.ctcon(e)
	local c=e:GetOwner()
	local h=e:GetHandler()
	return c:IsHasCardTarget(h)
end
