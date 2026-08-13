--カウンター・ジェム
-- 效果：
-- ①：把这张卡以外的自己的魔法与陷阱区域的卡全部送去墓地才能发动。从自己墓地把「宝玉兽」怪兽尽可能当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。这个回合的结束阶段让自己场上的「宝玉兽」卡全部破坏。
function c11136371.initial_effect(c)
	-- ①：把这张卡以外的自己的魔法与陷阱区域的卡全部送去墓地才能发动。从自己墓地把「宝玉兽」怪兽尽可能当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。这个回合的结束阶段让自己场上的「宝玉兽」卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c11136371.plcost)
	e1:SetTarget(c11136371.pltg)
	e1:SetOperation(c11136371.plop)
	c:RegisterEffect(e1)
end
-- 筛选自己魔法与陷阱区域中位于普通魔陷格（序号小于5）且可以作为代价送去墓地的卡，用于检索可送的魔陷卡。
function c11136371.cfilter(c)
	return c:GetSequence()<5 and c:IsAbleToGraveAsCost()
end
-- 代价函数：检查是否存在满足条件的卡；若存在，则将这张卡以外的自己魔法与陷阱区域的所有满足条件的卡全部作为代价送去墓地。
function c11136371.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认自己魔法与陷阱区域除这张卡外至少存在1张可送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c11136371.cfilter,tp,LOCATION_SZONE,0,1,e:GetHandler()) end
	-- 取得自己魔法与陷阱区域除这张卡外所有可作为代价送去墓地的卡。
	local g=Duel.GetMatchingGroup(c11136371.cfilter,tp,LOCATION_SZONE,0,e:GetHandler())
	-- 将取得的卡作为发动代价全部送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 筛选自己墓地中符合「宝玉兽」怪兽且不是禁止卡的卡，用于从墓地放置到魔法与陷阱区域。
function c11136371.plfilter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 效果发动目标判定：确认自己墓地存在至少1只「宝玉兽」怪兽，并设置操作信息，表示涉及从墓地移动卡。
function c11136371.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果可否发动的检查：确认自己墓地存在至少1只符合条件的「宝玉兽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c11136371.plfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息为涉及从墓地离开（CATEGORY_LEAVE_GRAVE），使相关效果（如王家长眠之谷）能够正确响应。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：计算可用魔陷区空格，从墓地选择最多为该数量的「宝玉兽」怪兽，以表侧表示放置到自己的魔法与陷阱区域，并将其变为永续魔法卡；然后在本回合结束阶段设置一个诱发效果，破坏自己场上所有「宝玉兽」卡。
function c11136371.plop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上魔法与陷阱区域的可用空格数量，用于决定可以从墓地放置的卡数上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	-- 提示玩家选择要放置到场上的卡（显示选择提示消息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从自己墓地选择数量为可用空格数的「宝玉兽」怪兽（如果可用空格数为0则之前已返回，此处实际至少为1）。
	local g=Duel.SelectMatchingCard(tp,c11136371.plfilter,tp,LOCATION_GRAVE,0,ft,ft,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			-- 将选中的卡移动到自己的魔法与陷阱区域，以表侧表示放置，并立即使其效果适用。
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 当作永续魔法卡使用
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
	-- 这个回合的结束阶段让自己场上的「宝玉兽」卡全部破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCondition(c11136371.descon)
	e1:SetOperation(c11136371.desop)
	-- 将上述结束阶段破坏效果以玩家tp的身份注册到全场，使该效果在结束阶段触发并执行破坏。
	Duel.RegisterEffect(e1,tp)
end
-- 筛选表侧表示且属于「宝玉兽」的卡，用于后续破坏效果的判定与执行。
function c11136371.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034)
end
-- 结束阶段破坏效果的触发条件：检查自己场上是否存在至少1张表侧表示的「宝玉兽」卡。
function c11136371.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示且为「宝玉兽」的卡，作为破坏效果触发的前提。
	return Duel.IsExistingMatchingCard(c11136371.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 破坏效果的结算：取得自己场上所有表侧表示的「宝玉兽」卡并全部破坏。
function c11136371.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示且属于「宝玉兽」的卡，构成待破坏的集合。
	local g=Duel.GetMatchingGroup(c11136371.desfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 将取得的「宝玉兽」卡全部以效果破坏（送入墓地）。
	Duel.Destroy(g,REASON_EFFECT)
end
