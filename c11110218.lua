--常世離レ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方墓地最多5张卡为对象，并以那个数量的对方的除外状态的卡为对象才能发动。作为对象的墓地的卡除外，作为对象的除外状态的卡回到墓地。
function c11110218.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方墓地最多5张卡为对象，并以那个数量的对方的除外状态的卡为对象才能发动。作为对象的墓地的卡除外，作为对象的除外状态的卡回到墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,11110218+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c11110218.target)
	e1:SetOperation(c11110218.activate)
	c:RegisterEffect(e1)
end
-- 效果的目标处理函数：先判断是否为连锁中检查对象（chkc非空则不能选对象），再在发动时检查是否存在满足条件的墓地卡与除外区卡，决定效果能否发动。
function c11110218.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方墓地是否存在至少1张可以被除外的卡（作为除外对象的条件）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
		-- 检查对方除外区是否存在至少1张可以被送去墓地的卡（作为回墓对象的条件）。
		and Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_REMOVED,1,nil) end
	-- 统计对方除外区中可以作为对象的卡的数量，作为最多可选数，超过5张则上限取5。
	local rt=Duel.GetTargetCount(aux.TRUE,tp,0,LOCATION_REMOVED,nil)
	if rt>5 then rt=5 end
	-- 给操作者弹出选择提示，提示文案为“请选择要除外的卡”，用于从墓地选卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地选择1到rt张可以被除外的卡，并将它们登记为效果对象。
	local g1=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,rt,nil)
	-- 给操作者弹出选择提示，提示文案为“请选择要送去墓地的卡”，用于从除外区选卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从对方除外区选择与墓地已选数量（#g1）相同的、可以被送去墓地的卡，并登记为效果对象，保证两类对象数量一致。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_REMOVED,#g1,#g1,nil)
	-- 登记本次连锁的除外操作信息：将要除外的目标组g1及其数量告知系统，供其他卡效果（如星尘龙的无效判定）检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,#g1,0,0)
	-- 登记本次连锁的送去墓地操作信息：将要送去墓地的目标组g2及其数量告知系统。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g2,#g2,0,0)
end
-- 定义处理时过滤器：只保留当前仍然在指定区域（墓地或除外区）且与效果仍有关联的目标卡，避免处理已离场或对象重置的卡。
function c11110218.filter(c,loc,e)
	return c:IsLocation(loc) and c:IsRelateToEffect(e)
end
-- 效果处理主函数：从连锁信息中取出发动时选择的所有目标，按当前区域分为墓地组和除外区组，先把墓地组除外，成功后再把除外区组送回墓地。
function c11110218.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得发动时登记的目标卡组（即所有被选择的对象）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg1=g:Filter(c11110218.filter,nil,LOCATION_GRAVE,e)
	local tg2=g:Filter(c11110218.filter,nil,LOCATION_REMOVED,e)
	-- 将仍位于墓地的目标卡以表侧表示除外；若除外处理执行成功（至少除外了1张），才继续执行除外区卡回墓地的处理。
	if Duel.Remove(tg1,POS_FACEUP,REASON_EFFECT)>0 then
		-- 将仍位于除外区的目标卡以效果原因送去墓地，并附加REASON_RETURN表示这是从除外区“回到墓地”的特殊移动。
		Duel.SendtoGrave(tg2,REASON_EFFECT+REASON_RETURN)
	end
end
