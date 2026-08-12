--鎖付き飛龍炎刃
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以场上1只炎属性怪兽为对象才能把这张卡发动。这张卡当作攻击力上升700的装备卡使用给那只怪兽装备。那之后，可以把场上1只效果怪兽变成里侧守备表示。
-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上·墓地的怪兽作为融合素材回到卡组，把1只战士族·龙族而炎属性的融合怪兽融合召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果：①效果（发动并装备、变里侧）和②效果（墓地除外融合召唤）。
function s.initial_effect(c)
	-- ①：以场上1只炎属性怪兽为对象才能把这张卡发动。这张卡当作攻击力上升700的装备卡使用给那只怪兽装备。那之后，可以把场上1只效果怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置发动条件为伤害步骤中伤害计算前以外的时机。
	e1:SetCondition(aux.dscon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上·墓地的怪兽作为融合素材回到卡组，把1只战士族·龙族而炎属性的融合怪兽融合召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id)
	-- 将墓地的这张卡除外作为发动的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 陷阱卡发动时的代价处理，设置卡片在发动后留在场上，并处理连锁被无效时送去墓地的逻辑。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作攻击力上升700的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以场上1只炎属性怪兽为对象才能把这张卡发动。这张卡当作攻击力上升700的装备卡使用给那只怪兽装备。那之后，可以把场上1只效果怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(s.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册全局效果，用于在连锁被无效时将该卡送去墓地。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理：如果该卡仍与该连锁相关，则取消送去墓地的状态（使其正常送墓）。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：场上表侧表示的炎属性怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- ①效果的发动准备：检查是否能选择场上1只表侧表示的炎属性怪兽作为对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否存在至少1只满足条件的炎属性怪兽。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的炎属性怪兽作为效果的对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为装备这张卡。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 过滤条件：场上表侧表示的效果怪兽且可以变成里侧表示。
function s.posfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup() and c:IsCanTurnSet()
end
-- ①效果的处理：将这张卡装备给对象怪兽，使其攻击力上升700，之后可以选场上1只效果怪兽变成里侧守备表示。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍在场上表侧表示存在，则将这张卡装备给该怪兽。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Equip(tp,c,tc) then
		-- 攻击力上升700
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 装备卡使用给那只怪兽装备。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(s.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 检查场上是否存在可以变成里侧守备表示的效果怪兽，并询问玩家是否发动该效果。
		if Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选场上1只怪兽变成里侧守备表示？"
			-- 中断当前效果处理，使后续的改变表示形式处理不与装备同时处理。
			Duel.BreakEffect()
			-- 提示玩家选择要改变表示形式的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			-- 玩家选择场上1只表侧表示的效果怪兽。
			local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			-- 选中卡片并向双方玩家展示。
			Duel.HintSelection(g)
			local tc2=g:GetFirst()
			-- 将选择的怪兽变成里侧守备表示。
			Duel.ChangePosition(tc2,POS_FACEDOWN_DEFENSE)
		end
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制：只能装备给炎属性怪兽。
function s.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 过滤条件：墓地的怪兽卡且可以回到卡组。
function s.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 过滤条件：不受该效果影响以外的怪兽卡且可以回到卡组。
function s.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
-- 过滤条件：额外卡组中炎属性、战士族或龙族的融合怪兽，且可以使用指定的素材进行融合召唤。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR+RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果的发动准备：检查是否能将手卡·场上·墓地的怪兽作为素材回到卡组，从额外卡组融合召唤1只满足条件的融合怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上可用的融合素材怪兽。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 获取玩家墓地中可作为融合素材的怪兽。
		local mg2=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的炎属性·战士族/龙族融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查是否存在适用的连锁融合效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁融合效果适用下，是否存在可融合召唤的怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息为从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息为将手卡·场上·墓地的卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
-- ②效果的处理：选择1只融合怪兽，将手卡·场上·墓地的素材怪兽回到卡组，将该融合怪兽融合召唤，并设置其在结束阶段破坏。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取手卡·场上不受该效果影响以外的融合素材怪兽。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取墓地中不受该效果影响以外的融合素材怪兽。
	local mg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,0,nil,e)
	mg1:Merge(mg2)
	-- 获取额外卡组中可以使用当前素材进行融合召唤的怪兽组。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取适用的连锁融合效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁融合效果适用下，可以融合召唤的怪兽组。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判定是否使用常规的融合素材回到卡组的方式进行融合召唤。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家选择融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(s.fdfilter,1,nil) then
				local cg=mat1:Filter(s.fdfilter,nil)
				-- 给对方玩家确认作为素材的手卡或里侧表示怪兽。
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(s.gdfilter,1,nil) then
				local gg=mat1:Filter(s.gdfilter,nil)
				-- 选中作为素材的场上表侧表示怪兽或墓地怪兽并向双方展示。
				Duel.HintSelection(gg)
			end
			-- 将融合素材怪兽送回持有者卡组并洗牌。
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送回卡组同时处理。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁融合效果适用下，玩家选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		tc:CompleteProcedure()
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetLabelObject(tc)
		e2:SetCondition(s.descon)
		-- 设置结束阶段的处理为破坏该怪兽。
		e2:SetOperation(aux.EPDestroyOperation)
		-- 注册全局延迟效果，在结束阶段执行破坏。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 结束阶段破坏效果的触发条件：被特殊召唤的怪兽仍带有对应的标记。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 过滤条件：场上里侧表示的怪兽或手卡中的怪兽（用于确认卡片）。
function s.fdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 过滤条件：场上表侧表示的怪兽或墓地中的怪兽（用于展示卡片）。
function s.gdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
