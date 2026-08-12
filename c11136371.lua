--カウンター・ジェム
-- 效果：
-- ①：把这张卡以外的自己的魔法与陷阱区域的卡全部送去墓地才能发动。从自己墓地把「宝玉兽」怪兽尽可能当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。这个回合的结束阶段让自己场上的「宝玉兽」卡全部破坏。
function c11136371.initial_effect(c)
	-- ①：把这张卡以外的自己的魔法与陷阱区域的卡全部送去墓地才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c11136371.plcost)
	e1:SetTarget(c11136371.pltg)
	e1:SetOperation(c11136371.plop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查场上是否满足条件的卡
function c11136371.cfilter(c)
	return c:GetSequence()<5 and c:IsAbleToGraveAsCost()
end
-- 发动时的费用处理函数
function c11136371.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c11136371.cfilter,tp,LOCATION_SZONE,0,1,e:GetHandler()) end
	-- 获取满足条件的卡组
	local g=Duel.GetMatchingGroup(c11136371.cfilter,tp,LOCATION_SZONE,0,e:GetHandler())
	-- 将满足条件的卡送入墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数，用于检查墓地是否满足条件的卡
function c11136371.plfilter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 发动时的处理函数
function c11136371.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c11136371.plfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息，表示将要从墓地取出卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数
function c11136371.plop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家魔法与陷阱区域的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c11136371.plfilter,tp,LOCATION_GRAVE,0,ft,ft,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			-- 将卡移至场上
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 将卡变为永续魔法卡
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
	-- 在结束阶段时破坏场上宝玉兽卡
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCondition(c11136371.descon)
	e1:SetOperation(c11136371.desop)
	-- 注册效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数，用于检查场上是否满足条件的卡
function c11136371.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034)
end
-- 判断是否满足破坏条件
function c11136371.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足条件的卡
	return Duel.IsExistingMatchingCard(c11136371.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 破坏效果处理函数
function c11136371.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组
	local g=Duel.GetMatchingGroup(c11136371.desfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 将卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
