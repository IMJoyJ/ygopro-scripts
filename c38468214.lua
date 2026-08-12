--エーリアン・ヒュプノ
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●选择放置有A指示物的对方场上1只怪兽得到控制权。每次自己的结束阶段时，得到控制权的怪兽的A指示物取除1个。得到控制权的怪兽的A指示物全部取除的场合，那只怪兽破坏。
function c38468214.initial_effect(c)
	-- 为这张卡添加二重怪兽属性，使其在墓地或场上当作通常怪兽使用、可以作再度召唤
	aux.EnableDualAttribute(c)
	-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。●选择放置有A指示物的对方场上1只怪兽得到控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38468214,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果发动条件：这张卡处于再度召唤状态（当作效果怪兽使用）时才能发动
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c38468214.target)
	e1:SetOperation(c38468214.operation)
	c:RegisterEffect(e1)
end
c38468214.mentioned_counter={
	[0x100e]=true,
}
-- 定义对象筛选条件：放置有A指示物且控制权可以改变的怪兽
function c38468214.filter(c)
	return c:GetCounter(0x100e)>0 and c:IsControlerCanBeChanged()
end
-- 效果的对象选择处理：确认对方场上存在可选择的怪兽后，选择1只放置有A指示物的对方怪兽作为对象并设置控制权变更的操作信息
function c38468214.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c38468214.filter(chkc) end
	-- 发动可行性检测：对方场上是否存在可以成为这个效果对象的、放置有A指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(c38468214.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示「请选择要改变控制权的怪兽」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只满足条件的怪兽，并将其设定为当前连锁的对象
	local g=Duel.SelectTarget(tp,c38468214.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：将改变所选的1只怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：确认对象怪兽仍有效后，赋予其控制权变更、自己结束阶段取除A指示物、A指示物全部取除时自我破坏的效果
function c38468214.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 取得当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:GetCounter(0x100e)>0 and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 选择放置有A指示物的对方场上1只怪兽得到控制权。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetValue(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c38468214.ctcon)
		tc:RegisterEffect(e1)
		-- 每次自己的结束阶段时，得到控制权的怪兽的A指示物取除1个。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1)
		e2:SetLabel(tp)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetCondition(c38468214.rmctcon)
		e2:SetOperation(c38468214.rmctop)
		tc:RegisterEffect(e2)
		-- 得到控制权的怪兽的A指示物全部取除的场合，那只怪兽破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SELF_DESTROY)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetCondition(c38468214.descon)
		tc:RegisterEffect(e3)
	end
end
-- 控制权变更效果的适用条件：这张卡仍然以那只怪兽为对象（维持取对象的关联）
function c38468214.ctcon(e)
	local c=e:GetOwner()
	return c:IsHasCardTarget(e:GetHandler())
end
-- 结束阶段取除指示物效果的触发条件：当前回合玩家是这个效果的发动者
function c38468214.rmctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，即只在自己的结束阶段触发
	return Duel.GetTurnPlayer()==e:GetLabel()
end
-- 结束阶段处理：将得到控制权的怪兽的1个A指示物取除，并触发取除A指示物的事件
function c38468214.rmctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x100e,1,REASON_EFFECT)
	-- 手动触发「取除A指示物」事件，供其他卡片检测A指示物被取除的时点
	Duel.RaiseEvent(e:GetHandler(),EVENT_REMOVE_COUNTER+0x100e,e,REASON_EFFECT,tp,tp,1)
end
-- 自我破坏的判定条件：得到控制权的怪兽的A指示物为0个（全部取除）
function c38468214.descon(e)
	return e:GetHandler():GetCounter(0x100e)==0
end
