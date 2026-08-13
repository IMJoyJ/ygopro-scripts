--風霊使いウィン
-- 效果：
-- ①：这张卡反转的场合，以对方场上1只风属性怪兽为对象发动。这只怪兽表侧表示存在期间，得到作为对象的怪兽的控制权。
function c37744402.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上1只风属性怪兽为对象发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37744402,0))  --"获得对方场上1只风属性怪兽的控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c37744402.target)
	e1:SetOperation(c37744402.operation)
	c:RegisterEffect(e1)
end
-- 定义效果的对象筛选条件：对象必须表侧表示、风属性，并且未被“不能改变控制权”的效果限制。
function c37744402.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToChangeControler()
end
-- 效果发动时的取对象处理：若在连锁处理中检查对象，则验证其位于对方怪兽区且满足筛选条件；若为发动时点，则弹出选择提示并从对方场上选择1只符合条件的怪兽作为对象，同时设置改变控制权的操作信息。
function c37744402.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c37744402.filter(chkc) end
	if chk==0 then return true end
	-- 向操作者显示选择提示：‘请选择要改变控制权的怪兽’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上选择1只满足筛选条件的表侧风属性怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c37744402.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，标明本效果将改变控制权，操作对象为已选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果处理：当发动怪兽仍与效果关联且表侧表示，对象怪兽仍与效果关联且不免疫此效果时，将对象怪兽设为风灵使的永续对象，并给对象怪兽赋予控制权转移给发动者的持续效果。
function c37744402.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的第1个（也是唯一一个）对象怪兽。
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
		e1:SetCondition(c37744402.ctcon)
		tc:RegisterEffect(e1)
	end
end
-- 该持续效果的适用条件：风灵使薇茵仍然持有该对象作为永续对象（即仍表侧表示且对象未离场/未重置）时才适用控制权转移。
function c37744402.ctcon(e)
	local c=e:GetOwner()
	local h=e:GetHandler()
	return c:IsHasCardTarget(h)
end
