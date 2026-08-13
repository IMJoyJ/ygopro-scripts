--地霊使いアウス
-- 效果：
-- ①：这张卡反转的场合，以对方场上1只地属性怪兽为对象发动。这只怪兽表侧表示存在期间，得到作为对象的怪兽的控制权。
function c37970940.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上1只地属性怪兽为对象发动。这只怪兽表侧表示存在期间，得到作为对象的怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37970940,0))  --"获得对方场上1只地属性怪兽的控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c37970940.target)
	e1:SetOperation(c37970940.operation)
	c:RegisterEffect(e1)
end
-- 筛选条件：怪兽为表侧表示、地属性，且当前没有被“不能改变控制权”的效果限制。
function c37970940.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToChangeControler()
end
-- 发动时选择对象：若是在连锁处理中检查对象，则校验对象必须位于对方主要怪兽区、由对方控制且满足筛选条件；若是最初发动确认，则直接允许发动。随后提示玩家选择要改变控制权的怪兽，从对方场上选择1只符合条件的怪兽作为效果对象，并设置操作信息为改变控制权。
function c37970940.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c37970940.filter(chkc) end
	if chk==0 then return true end
	-- 向当前玩家显示选择提示：“请选择要改变控制权的怪兽”（该提示会写入选择缓存，供后续选择怪兽时显示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上的主要怪兽区选择1只满足filter条件的表侧表示地属性怪兽作为效果对象，并自动将该对象与当前连锁效果建立联系。
	local g=Duel.SelectTarget(tp,c37970940.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁的效果分类为改变控制权，目标组为已选择的怪兽，数量为其数量，目标持有者和位置暂不确定（填0）。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果处理时：确认地灵使仍与发动效果相关且表侧表示，对象仍与效果相关且不免疫此效果；然后让地灵使将对象设为永续对象，并给对象赋予一个“控制权转移给tp”的单体效果。该效果在标准重置事件（离场、回手、里侧等）发生时重置，并且只有当地灵使仍持有该永续对象时才持续生效。
function c37970940.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出发动时选择的对象怪兽（本效果是取1个对象，所以取第一张目标卡）。
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
		e1:SetCondition(c37970940.ctcon)
		tc:RegisterEffect(e1)
	end
end
-- 控制权赋予效果的持续条件：地灵使仍然以当前被赋予控制权的怪兽为永续对象；若该联系因离场、里侧等原因消失，则控制权赋予效果不再适用。
function c37970940.ctcon(e)
	local c=e:GetOwner()
	local h=e:GetHandler()
	return c:IsHasCardTarget(h)
end
