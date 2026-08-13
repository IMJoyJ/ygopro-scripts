--集いし願い
-- 效果：
-- ①：自己墓地有龙族同调怪兽5种类以上存在的场合才能发动。从额外卡组把1只「星尘龙」当作同调召唤作特殊召唤，把这张卡装备。这个效果特殊召唤的怪兽在结束阶段除外。
-- ②：装备怪兽的攻击力上升自己墓地的龙族同调怪兽的攻击力的合计数值。
-- ③：每次装备怪兽战斗破坏对方怪兽，把自己墓地1只龙族同调怪兽除外才能发动。装备怪兽向对方怪兽可以继续攻击。
function c20007374.initial_effect(c)
	-- 登记这张卡的效果文本中记载的「星尘龙」卡名（代码44508094），使相关规则可识别。
	aux.AddCodeList(c,44508094)
	-- ①：自己墓地有龙族同调怪兽5种类以上存在的场合才能发动。从额外卡组把1只「星尘龙」当作同调召唤作特殊召唤，把这张卡装备。这个效果特殊召唤的怪兽在结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c20007374.condition)
	e1:SetCost(c20007374.cost)
	e1:SetTarget(c20007374.target)
	e1:SetOperation(c20007374.activate)
	c:RegisterEffect(e1)
	-- ②：装备怪兽的攻击力上升自己墓地的龙族同调怪兽的攻击力的合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c20007374.atkval)
	c:RegisterEffect(e2)
	-- ③：每次装备怪兽战斗破坏对方怪兽，把自己墓地1只龙族同调怪兽除外才能发动。装备怪兽向对方怪兽可以继续攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(20007374,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c20007374.cacon)
	e4:SetCost(c20007374.cacost)
	e4:SetTarget(c20007374.catg)
	e4:SetOperation(c20007374.caop)
	c:RegisterEffect(e4)
end
-- 定义筛选条件：判断一张卡是否为龙族同调怪兽。
function c20007374.cfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON)
end
-- 发动条件：自己墓地的龙族同调怪兽按卡名不同计数达到5种类以上时才可发动。
function c20007374.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地所有龙族同调怪兽，作为条件判定的集合。
	local g=Duel.GetMatchingGroup(c20007374.cfilter,tp,LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)>=5
end
-- 发动代价处理：本身不支付LP/卡片等实际代价，但设置誓约效果使本卡在此连锁中不会被送去墓地，并注册连锁被无效时的补救效果。
function c20007374.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 取得当前连锁的唯一ID，用于后续连锁被无效时的比对。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 从额外卡组把1只「星尘龙」当作同调召唤作特殊召唤，把这张卡装备。这个效果特殊召唤的怪兽在结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c20007374.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将连锁被无效时的补救效果注册到当前玩家场上，以便该连锁被无效时让本卡留在场上。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理：若对应连锁ID一致且本卡仍可关联，则取消本卡被送去墓地，使其留在场上。
function c20007374.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的ID，用来判断是否就是本卡发动的连锁。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 定义可特殊召唤的「星尘龙」的筛选条件：卡号正确、可以同调召唤方式特殊召唤、额外卡组怪兽区域有空位。
function c20007374.filter(c,e,tp)
	return c:IsCode(44508094) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 确认从额外卡组特殊召唤「星尘龙」时有可用的怪兽区域。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动的目标判定：确认费用已检查、不存在必须作为同调素材的卡、且额外卡组有符合条件的「星尘龙」，满足才可发动。
function c20007374.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查是否存在受『必须作为同调素材』效果影响的卡，若存在则本效果不能发动（因为无法进行正规同调召唤手续）。
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 确认额外卡组中至少存在1只满足筛选条件的「星尘龙」。
		and Duel.IsExistingMatchingCard(c20007374.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置本连锁的操作信息：效果包含从额外卡组特殊召唤1只怪兽，便于其他连锁（如星尘龙等）进行响应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从额外卡组选择1只「星尘龙」以同调召唤方式特殊召唤，将本卡装备给它，并注册结束阶段除外效果；若未成功特殊召唤则让本卡留在场上。
function c20007374.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认不存在『必须作为同调素材』的限制，否则效果不处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 显示『选择要特殊召唤的卡』的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只符合条件的「星尘龙」用于特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c20007374.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选择的「星尘龙」以同调召唤的形式进行特殊召唤（作为同调召唤处理）。
		Duel.SpecialSummonStep(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 将这张「聚集的祈愿」作为装备卡装备给那只「星尘龙」。
			Duel.Equip(tp,c,tc)
			-- 把这张卡装备（限定只能装备给本效果特殊召唤的那只「星尘龙」）。
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c20007374.eqlimit)
			c:RegisterEffect(e1)
		end
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(20007374,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段除外。②：装备怪兽的攻击力上升自己墓地的龙族同调怪兽的攻击力的合计数值。③：每次装备怪兽战斗破坏对方怪兽，把自己墓地1只龙族同调怪兽除外才能发动。装备怪兽向对方怪兽可以继续攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCountLimit(1)
		e2:SetLabel(fid)
		e2:SetLabelObject(tc)
		e2:SetCondition(c20007374.rmcon)
		e2:SetOperation(c20007374.rmop)
		-- 注册结束阶段除外的持续效果，在结束阶段时执行除外。
		Duel.RegisterEffect(e2,tp)
		-- 完成特别召唤手续，使之前分解的特殊召唤步骤最终生效。
		Duel.SpecialSummonComplete()
		tc:CompleteProcedure()
	elseif c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		c:CancelToGrave(false)
	end
end
-- 装备限制判定：仅当装备对象是那只「星尘龙」时才允许装备。
function c20007374.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 结束阶段除外效果的发动条件：判断要除外的怪兽仍为本效果特殊召唤的那只星尘龙（标记一致），否则不再除外。
function c20007374.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(20007374)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外的执行：将特殊召唤的「星尘龙」除外。
function c20007374.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽表侧表示除外，原因为效果。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
-- 攻击力计算筛选：龙族同调怪兽且攻击力大于0。
function c20007374.atkfilter(c)
	return c20007374.cfilter(c) and c:GetAttack()>0
end
-- 计算自己墓地所有龙族同调怪兽的攻击力合计，作为装备怪兽的攻击力上升值。
function c20007374.atkval(e,c)
	-- 获取自己墓地的所有龙族同调怪兽，用于合计攻击力。
	local g=Duel.GetMatchingGroup(c20007374.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return g:GetSum(Card.GetAttack)
end
-- ③的发动条件：装备怪兽在战斗中破坏了对方怪兽。
function c20007374.cacon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsContains(ec)
end
-- ③的除外对象筛选：自己墓地的龙族同调怪兽且可以作为代价除外。
function c20007374.cafilter(c)
	return c20007374.cfilter(c) and c:IsAbleToRemoveAsCost()
end
-- ③的代价处理：从自己墓地把1只龙族同调怪兽表侧除外作为发动代价。
function c20007374.cacost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己墓地存在至少1只符合条件的龙族同调怪兽可供除外。
	if chk==0 then return Duel.IsExistingMatchingCard(c20007374.cafilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示『选择要除外的卡』的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只符合条件的龙族同调怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c20007374.cafilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的龙族同调怪兽表侧除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ③的目标判定：确认装备怪兽可以进行追加攻击。
function c20007374.catg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return ec:IsChainAttackable(0,true) end
end
-- ③的效果处理：使装备怪兽获得对对方怪兽的追加攻击机会，并附加本回合不能直接攻击的限制。
function c20007374.caop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec:IsRelateToBattle() then return end
	-- 使装备怪兽可以再进行1次攻击。
	Duel.ChainAttack()
	-- 装备怪兽向对方怪兽可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE+PHASE_DAMAGE_CAL)
	ec:RegisterEffect(e1)
end
