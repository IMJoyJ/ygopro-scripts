--水霊使いエリア
-- 效果：
-- ①：这张卡反转的场合，以对方场上1只水属性怪兽为对象发动。这只怪兽表侧表示存在期间，得到作为对象的怪兽的控制权。
function c74364659.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上1只水属性怪兽为对象发动。这只怪兽表侧表示存在期间，得到作为对象的怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74364659,0))  --"获得对方场上1只水属性怪兽的控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c74364659.target)
	e1:SetOperation(c74364659.operation)
	c:RegisterEffect(e1)
end
-- 过滤对方场上表侧表示、水属性且可以改变控制权的怪兽
function c74364659.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToChangeControler()
end
-- 效果发动的靶向处理，用于检测并选择合法的对象怪兽
function c74364659.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c74364659.filter(chkc) end
	if chk==0 then return true end
	-- 向发动效果的玩家发送提示信息，要求选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只符合条件的水属性怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c74364659.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理的操作信息，表明此效果包含改变控制权的操作
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果处理的执行函数，建立对象关联并赋予目标怪兽控制权转移的效果
function c74364659.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
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
		e1:SetCondition(c74364659.ctcon)
		tc:RegisterEffect(e1)
	end
end
-- 控制权转移效果的维持条件：自身（水灵使）依然将目标怪兽作为卡片对象（即自身在场上表侧表示存在）
function c74364659.ctcon(e)
	local c=e:GetOwner()
	local h=e:GetHandler()
	return c:IsHasCardTarget(h)
end
