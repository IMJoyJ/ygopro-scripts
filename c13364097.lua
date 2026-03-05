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
	-- ①：以场上1张表侧表示的卡为对象才能发动。选除外的2张自己的「电脑堺」卡回到卡组（同名卡最多1张）。那之后，作为对象的卡破坏。
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
	-- 将此卡除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c13364097.lvtg)
	e3:SetOperation(c13364097.lvop)
	c:RegisterEffect(e3)
end
-- 过滤函数：返回满足「电脑堺」卡族、可以送入卡组、表侧表示的卡
function c13364097.tdfilter(c)
	return c:IsSetCard(0x14e) and c:IsAbleToDeck() and c:IsFaceup()
end
-- 效果处理：选择对象怪兽并检查除外区是否有2张不同名的「电脑堺」卡
function c13364097.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取除外区中所有「电脑堺」卡的集合
	local g=Duel.GetMatchingGroup(c13364097.tdfilter,tp,LOCATION_REMOVED,0,nil)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	local xg=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then xg=e:GetHandler() end
	-- 检查是否满足选择对象和除外卡数量及卡名不同的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,xg) and g:CheckSubGroup(aux.dncheck,2,2) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择场上1张表侧表示的卡作为对象
	local tg=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,xg)
	-- 设置操作信息：破坏对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	-- 设置操作信息：将2张除外的「电脑堺」卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_REMOVED)
end
-- 效果处理：选择除外的2张不同名的「电脑堺」卡并送回卡组，然后破坏对象卡
function c13364097.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象卡
	local tc=Duel.GetFirstTarget()
	-- 获取除外区中所有「电脑堺」卡的集合
	local g=Duel.GetMatchingGroup(c13364097.tdfilter,tp,LOCATION_REMOVED,0,nil)
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 从除外区选择2张不同名的「电脑堺」卡
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 显示选中的卡作为对象的动画效果
		Duel.HintSelection(sg)
		-- 判断是否成功将卡送回卡组且对象卡存在
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
			and tc:IsRelateToEffect(e) then
			-- 破坏对象卡
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- 效果发动条件：当前为自己的主要阶段
function c13364097.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前为自己的主要阶段
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 过滤函数：返回满足「电脑堺」卡族、怪兽类型、表侧表示、等级或阶级大于0的卡
function c13364097.lvfilter(c)
	return c:IsSetCard(0x14e) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and (c:GetLevel()>0 or c:GetRank()>0)
end
-- 效果处理：选择场上1只符合条件的「电脑堺」怪兽作为对象
function c13364097.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c13364097.lvfilter(chkc) end
	-- 检查是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c13364097.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变等级/阶级的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择场上1只符合条件的「电脑堺」怪兽作为对象
	local g=Duel.SelectTarget(tp,c13364097.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：选择提升或降低等级/阶级
function c13364097.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local sel=0
		local lvl=3
		if tc:IsLevelBelow(3) or tc:IsRankBelow(3) then
			-- 选择提升等级/阶级或降低等级/阶级
			sel=Duel.SelectOption(tp,aux.Stringid(13364097,2))  --"上升"
		else
			-- 选择提升等级/阶级或降低等级/阶级
			sel=Duel.SelectOption(tp,aux.Stringid(13364097,2),aux.Stringid(13364097,3))  --"上升"
		end
		if sel==1 then
			lvl=-3
		end
		-- 使对象怪兽的等级变化
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lvl)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使对象怪兽的阶级变化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_RANK)
		e2:SetValue(lvl)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
