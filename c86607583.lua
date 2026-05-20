--リミット・コード
-- 效果：
-- 这个卡名的卡在决斗中只能发动1张。
-- ①：自己墓地有电子界族连接怪兽存在的场合才能把这张卡发动。那些怪兽数量的指示物给这张卡放置，从额外卡组把1只「码语者」怪兽特殊召唤，把这张卡当作装备卡使用给那只怪兽装备。这张卡从场上离开时那只怪兽破坏。
-- ②：自己结束阶段发动。这张卡1个指示物取除。不能取除的场合这张卡破坏。
function c86607583.initial_effect(c)
	c:EnableCounterPermit(0x47)
	-- 这个卡名的卡在决斗中只能发动1张。①：自己墓地有电子界族连接怪兽存在的场合才能把这张卡发动。那些怪兽数量的指示物给这张卡放置，从额外卡组把1只「码语者」怪兽特殊召唤，把这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,86607583+EFFECT_COUNT_CODE_DUEL+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c86607583.cost)
	e1:SetTarget(c86607583.target)
	e1:SetOperation(c86607583.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c86607583.desop)
	c:RegisterEffect(e2)
	-- ②：自己结束阶段发动。这张卡1个指示物取除。不能取除的场合这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(c86607583.rccon)
	e3:SetOperation(c86607583.rcop)
	c:RegisterEffect(e3)
end
-- 发动时的Cost处理：使这张卡在发动后留在场上，并注册连锁被无效时送去墓地的效果
function c86607583.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 把这张卡当作装备卡使用给那只怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 把这张卡当作装备卡使用给那只怪兽装备
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c86607583.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将连锁被无效时送去墓地的效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理：如果该连锁被无效，则取消留在场上的状态，正常送去墓地
function c86607583.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：额外卡组的「码语者」怪兽，且可以特殊召唤
function c86607583.spfilter(c,e,tp)
	-- 检查卡片是否属于「码语者」系列、能否在额外怪兽区域或连接端特殊召唤
	return c:IsSetCard(0x101) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 过滤条件：自己墓地的电子界族连接怪兽
function c86607583.cfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK)
end
-- 发动时的效果对象与可行性检查
function c86607583.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查这张卡能否放置至少1个指示物
		and Duel.IsCanAddCounter(tp,0x47,1,e:GetHandler())
		-- 检查额外卡组是否存在可以特殊召唤的「码语者」怪兽
		and Duel.IsExistingMatchingCard(c86607583.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		-- 检查自己墓地是否存在电子界族连接怪兽
		and Duel.IsExistingMatchingCard(c86607583.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 计算自己墓地中电子界族连接怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c86607583.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 设置操作信息：给这张卡放置对应数量的指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,0x47)
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：将这张卡作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制：只能装备给特殊召唤的那只怪兽
function c86607583.eqlimit(e,c)
	return e:GetLabelObject()==c
end
-- 发动时的效果处理：放置指示物、特殊召唤「码语者」怪兽并装备此卡
function c86607583.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己墓地中电子界族连接怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c86607583.cfilter,tp,LOCATION_GRAVE,0,nil)
	if c:IsRelateToEffect(e) and ct>0 and c:IsCanAddCounter(0x47,ct) then
		c:AddCounter(0x47,ct)
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足条件的「码语者」怪兽
		local g=Duel.SelectMatchingCard(tp,c86607583.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 如果成功将选中的怪兽以表侧表示特殊召唤
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 将这张卡装备给特殊召唤的怪兽
			Duel.Equip(tp,c,tc)
			-- 把这张卡当作装备卡使用给那只怪兽装备
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c86607583.eqlimit)
			e1:SetLabelObject(tc)
			c:RegisterEffect(e1)
			-- 完成特殊召唤的流程处理
			Duel.SpecialSummonComplete()
		elseif not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			c:CancelToGrave(false)
		end
	end
end
-- 离场时的效果处理：破坏装备的怪兽
function c86607583.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果破坏装备的怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 结束阶段效果的发动条件：当前回合是自己的回合
function c86607583.rccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 结束阶段效果的处理：取除1个指示物，不能取除的场合破坏这张卡
function c86607583.rcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		if c:IsCanRemoveCounter(tp,0x47,1,REASON_EFFECT) then
			c:RemoveCounter(tp,0x47,1,REASON_EFFECT)
		else
			-- 因效果破坏这张卡
			Duel.Destroy(c,REASON_EFFECT)
		end
	end
end
