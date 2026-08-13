--電脳堺門－朱雀
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上1张表侧表示的卡为对象才能发动。选除外的2张自己的「电脑堺」卡回到卡组（同名卡最多1张）。那之后，作为对象的卡破坏。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只「电脑堺」怪兽为对象才能发动。那只怪兽的等级或者阶级直到回合结束时上升或者下降3。
function c13364097.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以场上1张表侧表示的卡为对象才能发动。选除外的2张自己的「电脑堺」卡回到卡组（同名卡最多1张）。那之后，作为对象的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13364097,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,13364097)
	e2:SetTarget(c13364097.target)
	e2:SetOperation(c13364097.operation)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只「电脑堺」怪兽为对象才能发动。那只怪兽的等级或者阶级直到回合结束时上升或者下降3。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13364097,1))  --"改变等级·阶级"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,13364098)
	e3:SetCondition(c13364097.lvcon)
	-- 设置②效果的发动代价：把墓地的这张卡除外（aux.bfgcost为除外自身作cost的通用辅助函数）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c13364097.lvtg)
	e3:SetOperation(c13364097.lvop)
	c:RegisterEffect(e3)
end
-- 定义①效果中“除外的自己的「电脑堺」卡”的过滤条件：必须是表侧表示、属于「电脑堺」系列且可以返回卡组。
function c13364097.tdfilter(c)
	return c:IsSetCard(0x14e) and c:IsAbleToDeck() and c:IsFaceup()
end
-- ①效果的发动处理：判定场上是否存在表侧表示卡可作为对象，以及除外区是否有2张卡名不同的「电脑堺」卡；随后选择对象并设置破坏和回卡组的操作信息。
function c13364097.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 取得自己除外区中满足tdfilter条件的所有「电脑堺」卡，用于后续选择返回卡组的卡。
	local g=Duel.GetMatchingGroup(c13364097.tdfilter,tp,LOCATION_REMOVED,0,nil)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	local xg=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then xg=e:GetHandler() end
	-- 发动合法性检查：场上存在至少1张表侧表示的卡可取对象，且除外区存在2张卡名不同的「电脑堺」卡可返回卡组。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,xg) and g:CheckSubGroup(aux.dncheck,2,2) end
	-- 向玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择1张表侧表示的卡作为效果对象，并将其登记为当前连锁的对象。
	local tg=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,xg)
	-- 设置操作信息：本次效果将破坏所选对象卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	-- 设置操作信息：本次效果将把自己除外的2张「电脑堺」卡返回卡组（具体卡片在效果处理时选择，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_REMOVED)
end
-- ①效果处理：从除外区选择2张卡名不同的「电脑堺」卡返回卡组并洗牌；若返回成功且对象仍与效果相关，则破坏对象卡。
function c13364097.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 取得自己除外区中满足tdfilter条件的所有「电脑堺」卡，用于选择返回卡组。
	local g=Duel.GetMatchingGroup(c13364097.tdfilter,tp,LOCATION_REMOVED,0,nil)
	-- 向玩家显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从除外区的「电脑堺」卡中选择2张卡名不同的卡（同名卡最多1张）。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 展示所选卡并标记为被选择的对象（用于动画与连锁关联）。
		Duel.HintSelection(sg)
		-- 将所选的2张卡返回持有者卡组并洗牌；若确实有卡返回卡组/额外卡组且对象仍与效果关联，则继续执行破坏。
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
			and tc:IsRelateToEffect(e) then
			-- 对象卡被效果破坏。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件函数：仅限自己回合的主要阶段才能发动。
function c13364097.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前为回合玩家的主要阶段1或主要阶段2。
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 定义②效果的对象过滤条件：自己场上的表侧表示怪兽，属于「电脑堺」系列，且拥有等级或阶级。
function c13364097.lvfilter(c)
	return c:IsSetCard(0x14e) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and (c:GetLevel()>0 or c:GetRank()>0)
end
-- ②效果的目标处理：从自己场上选择1只符合条件的「电脑堺」怪兽作为对象，并处理发动时的合法性检查。
function c13364097.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c13364097.lvfilter(chkc) end
	-- 发动时检查自己场上是否存在至少1只满足lvfilter条件的「电脑堺」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c13364097.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的选择提示（实际选择对象为怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只符合条件的「电脑堺」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c13364097.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：若对象等级/阶级不足3则只能选择上升，否则可选择上升或下降3；随后将等级和阶级变化效果赋予对象直到回合结束。
function c13364097.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local sel=0
		local lvl=3
		if tc:IsLevelBelow(3) or tc:IsRankBelow(3) then
			-- 当对象等级和阶级都≤3时，只提供“上升”选项（下降会让数值变得不合法）。
			sel=Duel.SelectOption(tp,aux.Stringid(13364097,2))  --"上升"
		else
			-- 当对象等级或阶级大于3时，提供“上升”和“下降”两个选项，由玩家选择变化方向。
			sel=Duel.SelectOption(tp,aux.Stringid(13364097,2),aux.Stringid(13364097,3))  --"上升/下降"
		end
		if sel==1 then
			lvl=-3
		end
		-- 使对象怪兽的等级直到回合结束时上升或下降3。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lvl)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使对象怪兽的阶级直到回合结束时上升或下降3。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_RANK)
		e2:SetValue(lvl)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
