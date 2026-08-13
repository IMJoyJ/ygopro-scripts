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
	-- 每次「宝玉兽」怪兽卡在魔法与陷阱区域被放置，给这张卡放置1个宝石指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c47408488.ctcon1)
	e2:SetOperation(c47408488.ctop1)
	c:RegisterEffect(e2)
	-- 每次「宝玉兽」怪兽卡在魔法与陷阱区域被放置，给这张卡放置1个宝石指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetCode(EVENT_MOVE)
	e0:SetRange(LOCATION_SZONE)
	e0:SetCondition(c47408488.regcon)
	e0:SetOperation(c47408488.regop)
	c:RegisterEffect(e0)
	-- 每次「宝玉兽」怪兽卡在魔法与陷阱区域被放置，给这张卡放置1个宝石指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c47408488.ctcon2)
	e3:SetOperation(c47408488.ctop2)
	c:RegisterEffect(e3)
	-- 把有宝石指示物放置的这张卡送去墓地才能发动。从卡组选这张卡放置的宝石指示物数量的「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(47408488,1))  --"放置宝玉兽到魔法陷阱区"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c47408488.plcost)
	e4:SetTarget(c47408488.pltg)
	e4:SetOperation(c47408488.plop)
	c:RegisterEffect(e4)
end
-- 过滤出被放置到魔法与陷阱区域的「宝玉兽」怪兽卡（需位于主要魔陷区、非场地区，且原始类型或在场上的类型为怪兽）。
function c47408488.cfilter(c)
	local type=c:GetOriginalType()
	if c:IsPreviousLocation(LOCATION_ONFIELD) then type=c:GetPreviousTypeOnField() end
	return c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5 and c:IsSetCard(0x1034) and bit.band(type,TYPE_MONSTER)~=0
end
-- 当有「宝玉兽」怪兽卡被放置到魔法与陷阱区域且当前不在连锁处理中时，条件成立。
function c47408488.ctcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 存在满足条件的「宝玉兽」怪兽卡被放置到魔法与陷阱区域，且当前不在连锁处理中。
	return eg:IsExists(c47408488.cfilter,1,nil) and not Duel.IsChainSolving()
end
-- 给「宝玉之树」自身放置1个宝石指示物。
function c47408488.ctop1(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x6,1)
end
-- 当有「宝玉兽」怪兽卡被放置到魔法与陷阱区域且当前正在连锁处理中时，条件成立。
function c47408488.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 存在满足条件的「宝玉兽」怪兽卡被放置到魔法与陷阱区域，且当前正在连锁处理中。
	return eg:IsExists(c47408488.cfilter,1,nil) and Duel.IsChainSolving()
end
-- 记录“本连锁中有宝玉兽被放置”的标志，待连锁处理结束后统一放置宝石指示物。
function c47408488.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(47408488,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
end
-- 检测到此卡存在本连锁中放置过宝玉兽的记录标志，连锁处理结束时的效果条件成立。
function c47408488.ctcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(47408488)>0
end
-- 清除记录标志，并给这张卡放置1个宝石指示物（补偿连锁处理中未即时放置的指示物）。
function c47408488.ctop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(47408488)
	e:GetHandler():AddCounter(0x6,1)
end
-- ②效果的代价处理：检查此卡能否作为代价送去墓地，若能则将当前宝石指示物数量记录到效果标签，再把此卡作为代价送入墓地。
function c47408488.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabel(e:GetHandler():GetCounter(0x6))
	-- 将「宝玉之树」自身作为代价送入墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ②效果发动时点检查：此卡有宝石指示物、魔陷区空位足够、且卡组中有足够数量的「宝玉兽」怪兽卡。
function c47408488.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local ct=c:GetCounter(0x6)
		-- 检查宝石指示物数量大于0，且我方魔陷区可用空格数不少于指示物数量。
		return ct>0 and Duel.GetSZoneCount(tp,c)>=ct
			-- 检查卡组中是否存在至少 ct 张符合条件的「宝玉兽」怪兽卡。
			and Duel.IsExistingMatchingCard(c47408488.plfilter,tp,LOCATION_DECK,0,ct,nil)
	end
end
-- 选择条件：卡组中的「宝玉兽」怪兽卡、且不是禁止卡，可作为②效果放置到魔陷区的对象。
function c47408488.plfilter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- ②效果处理：按记录的数量计算可放置张数，从卡组选择相应数量的「宝玉兽」怪兽卡，以表侧表示放置到己方魔陷区，并赋予其“当作永续魔法卡”的效果。
function c47408488.plop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方魔法与陷阱区域当前可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<e:GetLabel() then return end
	if ft>e:GetLabel() then ft=e:GetLabel() end
	-- 向操作玩家发出“请选择要放置到场上的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择 ft 张符合条件的「宝玉兽」怪兽卡（ft为实际可放置数量）。
	local g=Duel.SelectMatchingCard(tp,c47408488.plfilter,tp,LOCATION_DECK,0,ft,ft,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			-- 将选中的怪兽卡移动到己方魔法与陷阱区域，以表侧表示放置，并立即适用其效果。
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
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
