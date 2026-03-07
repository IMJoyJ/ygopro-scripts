--エーリアン・ヒュプノ
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●选择放置有A指示物的对方场上1只怪兽得到控制权。每次自己的结束阶段时，得到控制权的怪兽的A指示物取除1个。得到控制权的怪兽的A指示物全部取除的场合，那只怪兽破坏。
function c38468214.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ●选择放置有A指示物的对方场上1只怪兽得到控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38468214,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	-- 效果的发动条件为该卡处于再度召唤状态
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c38468214.target)
	e1:SetOperation(c38468214.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查目标怪兽是否具有A指示物且可以改变控制权
function c38468214.filter(c)
	return c:GetCounter(0x100e)>0 and c:IsControlerCanBeChanged()
end
-- 设置效果目标：选择对方场上1只具有A指示物的怪兽作为目标
function c38468214.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c38468214.filter(chkc) end
	-- 判断是否满足发动条件：场上是否存在对方怪兽具有A指示物
	if chk==0 then return Duel.IsExistingTarget(c38468214.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c38468214.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：将改变控制权的效果加入连锁
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理函数：执行控制权转移及相关效果
function c38468214.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:GetCounter(0x100e)>0 and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 为被控制的怪兽设置控制权效果，使其获得控制权
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetValue(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c38468214.ctcon)
		tc:RegisterEffect(e1)
		-- 设置一个在结束阶段触发的效果，用于每次移除A指示物
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
		-- 设置一个自我破坏效果，当A指示物全部移除时破坏该怪兽
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SELF_DESTROY)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetCondition(c38468214.descon)
		tc:RegisterEffect(e3)
	end
end
-- 控制权效果的触发条件：该卡是否仍为目标怪兽
function c38468214.ctcon(e)
	local c=e:GetOwner()
	return c:IsHasCardTarget(e:GetHandler())
end
-- 移除指示物效果的触发条件：当前回合玩家是否为效果发起者
function c38468214.rmctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发起者
	return Duel.GetTurnPlayer()==e:GetLabel()
end
-- 移除指示物的操作函数：每次结束阶段移除1个A指示物
function c38468214.rmctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x100e,1,REASON_EFFECT)
	-- 手动触发指示物移除的时点事件
	Duel.RaiseEvent(e:GetHandler(),EVENT_REMOVE_COUNTER+0x100e,e,REASON_EFFECT,tp,tp,1)
end
-- 破坏效果的触发条件：该怪兽的A指示物是否已全部移除
function c38468214.descon(e)
	return e:GetHandler():GetCounter(0x100e)==0
end
