--悪魔嬢マリス
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把自己场上2只怪兽解放，从自己墓地的卡以及除外的自己的卡之中以1张通常陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡从场上离开的场合回到持有者卡组最下面。这个效果在对方回合也能发动。
function c25643346.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把自己场上2只怪兽解放，从自己墓地的卡以及除外的自己的卡之中以1张通常陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡从场上离开的场合回到持有者卡组最下面。这个效果在对方回合也能发动。
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
-- 作为发动代价，从自己场上选择2只怪兽解放；先检查是否有足够可解放的怪兽，再实际选择并解放。
function c25643346.stcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）确认自己场上是否存在至少2只可解放的怪兽，满足代价条件才能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,aux.TRUE,2,nil) end
	-- 从自己场上选择2只可解放的怪兽（非上级召唤用）作为代价。
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,2,2,nil)
	-- 以代价（REASON_COST）解放所选怪兽，完成支付。
	Duel.Release(g,REASON_COST)
end
-- 定义过滤条件：对象必须是表侧表示或位于墓地的通常陷阱卡，且当前可以被盖放到魔陷区。
function c25643346.stfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- 设定发动时的目标选择和合法性检查：以自己墓地或除外状态的1张通常陷阱卡为对象，并设置操作信息。
function c25643346.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c25643346.stfilter(chkc) end
	-- 在发动时（chk==0）确认自己墓地或除外状态存在至少1张符合条件且能成为对象的通常陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c25643346.stfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 向玩家显示选择提示，要求选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地和除外状态中选择1张符合条件的通常陷阱卡作为效果对象，并建立连锁对象关系。
	local g=Duel.SelectTarget(tp,c25643346.stfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息，标记这些卡涉及从墓地/除外区域被操作，用于触发相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理：取回目标卡并把它盖放到自己场上；若成功，给该卡附加离场时回到持有者卡组最下面的效果。
function c25643346.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与该效果关联且成功盖放到魔陷区。
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡从场上离开的场合回到持有者卡组最下面。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		tc:RegisterEffect(e1)
	end
end
