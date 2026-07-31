--無垢なる芸術－「幻創の賢者」
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 以自己的场上·墓地最多3只「幻创」怪兽为对象才能发动。那些怪兽除外。那之后，可以选最多有除外数量的场上的表侧表示卡的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 把墓地的这张卡除外，以自己墓地1只「Symphonith」连接怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以把那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	-- 墓地发动Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 除外目标过滤条件：自己场上表侧表示或墓地的「幻创」怪兽
function s.rmfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1e6) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 除外与无效效果发动准备：选择1~3只目标怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.rmfilter(chkc) and chkc:IsControler(tp) end
	-- 发动条件检查：存在满足除外条件的「幻创」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从场上（再从墓地）选择1~3只满足条件的怪兽作为对象
	local g=aux.SelectTargetFromFieldFirst(tp,s.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,3,nil)
	-- 设置连锁操作信息：除外选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 特殊召唤过滤条件
function s.sfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 卡片发动处理：除外目标怪兽并可无效场上表侧表示卡的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁关联的目标怪兽
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsType,nil,TYPE_MONSTER)
	-- 将目标怪兽表侧表示除外，成功除外时继续处理
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 获取实际被除外的卡片数量
		local ct=Duel.GetOperatedGroup():GetCount()
		if ct>0
			-- 检查场上是否存在其他可无效效果的表侧表示卡
			and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,aux.ExceptThisCard(e))
			-- 询问玩家是否发动效果无效处理
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- 中断效果处理（前后为非同时处理）
			Duel.BreakEffect()
			-- 提示玩家选择要无效效果的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
			-- 让玩家选择最多等同于除外数量的场上表侧表示卡
			local sg=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,aux.ExceptThisCard(e))
			-- 高亮显示选中的卡片
			Duel.HintSelection(sg)
			-- 遍历选中的卡片列表进行效果无效处理
			for tc in aux.Next(sg) do
				-- 无效涉及该卡已发动的连锁
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				-- 使目标卡的效果无效直到回合结束
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				-- 使目标卡发动的效果无效直到回合结束
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
				if tc:IsType(TYPE_TRAPMONSTER) then
					-- 若目标为陷阱怪兽，则使其陷阱怪兽状态无效直到回合结束
					local e3=Effect.CreateEffect(c)
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tc:RegisterEffect(e3)
				end
			end
		end
	end
end
-- 返回卡组过滤条件：墓地的「Symphonith」连接怪兽
function s.tdfilter(c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_LINK) and c:IsAbleToDeck()
end
-- 回收特召效果发动准备与目标确认
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：墓地存在满足条件的连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设置连锁操作信息：将墓地的1张卡回到额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
-- 回收特召效果处理：墓地怪兽回到额外卡组并可特殊召唤
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 二次检查墓地是否存在满足条件的怪兽
	if Duel.GetMatchingGroupCount(s.tdfilter,tp,LOCATION_GRAVE,0,nil)<1 then return end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从墓地选择1只满足条件的连接怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if g:GetCount()>0 then
		-- 高亮显示选中的卡片
		Duel.HintSelection(g)
		-- 将选中的怪兽返回额外卡组，成功时继续判断
		if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
			and tc:IsLocation(LOCATION_EXTRA)
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检查额外怪兽区域是否有空位
			and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
			-- 询问玩家是否特殊召唤该怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			-- 中断效果处理（前后为非同时处理）
			Duel.BreakEffect()
			-- 将该怪兽表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
