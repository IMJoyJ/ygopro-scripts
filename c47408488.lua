--宝玉の樹
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，每次「宝玉兽」怪兽卡在魔法与陷阱区域被放置，给这张卡放置1个宝石指示物。
-- ②：把有宝石指示物放置的这张卡送去墓地才能发动。从卡组选这张卡放置的宝石指示物数量的「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c47408488.initial_effect(c)
	c:EnableCounterPermit(0x6)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，每次「宝玉兽」怪兽卡在魔法与陷阱区域被放置，给这张卡放置1个宝石指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c47408488.ctcon1)
	e2:SetOperation(c47408488.ctop1)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在魔法与陷阱区域存在，每次「宝玉兽」怪兽卡在魔法与陷阱区域被放置，给这张卡放置1个宝石指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetCode(EVENT_MOVE)
	e0:SetRange(LOCATION_SZONE)
	e0:SetCondition(c47408488.regcon)
	e0:SetOperation(c47408488.regop)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在魔法与陷阱区域存在，每次「宝玉兽」怪兽卡在魔法与陷阱区域被放置，给这张卡放置1个宝石指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c47408488.ctcon2)
	e3:SetOperation(c47408488.ctop2)
	c:RegisterEffect(e3)
	-- ②：把有宝石指示物放置的这张卡送去墓地才能发动。从卡组选这张卡放置的宝石指示物数量的「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(47408488,1))  --"放置宝玉兽到魔法陷阱区"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c47408488.plcost)
	e4:SetTarget(c47408488.pltg)
	e4:SetOperation(c47408488.plop)
	c:RegisterEffect(e4)
end
-- 用于判断是否为「宝玉兽」怪兽卡从场上移至魔法与陷阱区域，以触发效果添加宝石指示物。
function c47408488.cfilter(c)
	local type=c:GetOriginalType()
	if c:IsPreviousLocation(LOCATION_ONFIELD) then type=c:GetPreviousTypeOnField() end
	return c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5 and c:IsSetCard(0x1034) and bit.band(type,TYPE_MONSTER)~=0
end
-- 当有卡片移动到魔法与陷阱区域时，检查是否有「宝玉兽」怪兽卡被放置，且当前不在连锁处理中。
function c47408488.ctcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有「宝玉兽」怪兽卡被放置，且当前不在连锁处理中。
	return eg:IsExists(c47408488.cfilter,1,nil) and not Duel.IsChainSolving()
end
-- 将宝石指示物添加到该卡上。
function c47408488.ctop1(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x6,1)
end
-- 当有卡片移动到魔法与陷阱区域时，检查是否有「宝玉兽」怪兽卡被放置，且当前正在连锁处理中。
function c47408488.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有「宝玉兽」怪兽卡被放置，且当前正在连锁处理中。
	return eg:IsExists(c47408488.cfilter,1,nil) and Duel.IsChainSolving()
end
-- 为该卡注册一个标记，表示已触发过一次连锁处理中的宝石指示物添加逻辑。
function c47408488.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(47408488,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
end
-- 当连锁处理结束后，判断是否已触发过宝石指示物添加逻辑。
function c47408488.ctcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(47408488)>0
end
-- 重置标记并再次添加一个宝石指示物。
function c47408488.ctop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(47408488)
	e:GetHandler():AddCounter(0x6,1)
end
-- 发动效果时支付代价，将该卡送去墓地，并记录当前宝石指示物数量。
function c47408488.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabel(e:GetHandler():GetCounter(0x6))
	-- 将该卡送去墓地作为发动效果的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 判断是否满足发动条件：有宝石指示物且场上空位足够、卡组中有符合条件的「宝玉兽」怪兽。
function c47408488.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local ct=c:GetCounter(0x6)
		-- 检查场上是否有足够的魔法与陷阱区域来放置宝石指示物数量的怪兽。
		return ct>0 and Duel.GetSZoneCount(tp,c)>=ct
			-- 检查卡组中是否存在至少与宝石指示物数量相等的「宝玉兽」怪兽。
			and Duel.IsExistingMatchingCard(c47408488.plfilter,tp,LOCATION_DECK,0,ct,nil)
	end
end
-- 用于筛选卡组中符合条件的「宝玉兽」怪兽，即为怪兽卡且未被禁止使用。
function c47408488.plfilter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 选择并放置符合条件的「宝玉兽」怪兽到魔法与陷阱区域，并将其转换为永续魔法卡。
function c47408488.plop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家当前可用的魔法与陷阱区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<e:GetLabel() then return end
	if ft>e:GetLabel() then ft=e:GetLabel() end
	-- 提示玩家选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择指定数量的「宝玉兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c47408488.plfilter,tp,LOCATION_DECK,0,ft,ft,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			-- 将选中的怪兽移动到魔法与陷阱区域并正面表示。
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 将该怪兽转换为永续魔法卡类型。
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
end
