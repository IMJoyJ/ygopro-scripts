--悪魔嬢マリス
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把自己场上2只怪兽解放，从自己墓地的卡以及除外的自己的卡之中以1张通常陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡从场上离开的场合回到持有者卡组最下面。这个效果在对方回合也能发动。
function c25643346.initial_effect(c)
	-- 创建效果1，用于发动恶魔娘玛莉丝的①效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25643346,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,25643346)
	e1:SetCost(c25643346.stcost)
	e1:SetTarget(c25643346.sttg)
	e1:SetOperation(c25643346.stop)
	c:RegisterEffect(e1)
end
-- 检查并选择2只可解放的怪兽作为代价
function c25643346.stcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少2只可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,aux.TRUE,2,nil) end
	-- 选择2只可解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,2,2,nil)
	-- 将选择的怪兽解放作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 定义过滤函数，用于筛选可盖放的通常陷阱卡
function c25643346.stfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- 设置效果的目标选择逻辑，选择墓地或除外区的陷阱卡
function c25643346.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c25643346.stfilter(chkc) end
	-- 检查是否存在满足条件的陷阱卡作为目标
	if chk==0 then return Duel.IsExistingTarget(c25643346.stfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c25643346.stfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息，记录将要离开墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 执行效果的处理逻辑，将卡盖放并设置其离场时回到卡组底部
function c25643346.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡有效且成功盖放
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		-- 设置盖放的卡在离场时回到持有者卡组最下面的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		tc:RegisterEffect(e1)
	end
end
