--燃え上がる大海
-- 效果：
-- 自己场上有7星以上的水属性或者炎属性的怪兽存在的场合才能发动。自己场上的怪兽属性的以下效果适用。
-- ●水属性：把这个回合为让效果怪兽的效果发动而被送去自己墓地的水属性怪兽尽可能特殊召唤。那之后，选自己场上1只怪兽破坏。
-- ●炎属性：选场上1只怪兽破坏。那之后，自己手卡有1张以上的场合，选1张丢弃去墓地。
function c32542011.initial_effect(c)
	-- 效果设定：将此卡注册为发动时点为自由连锁的魔法卡，条件为己方场上存在7星以上水属性或炎属性的怪兽，效果分类为特殊召唤与破坏，触发时机为结束阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c32542011.condition)
	e1:SetTarget(c32542011.target)
	e1:SetOperation(c32542011.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查场上是否有正面表示且等级7以上且属性为水或火的怪兽。
function c32542011.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsAttribute(ATTRIBUTE_WATER+ATTRIBUTE_FIRE)
end
-- 发动条件判断：检查己方场上是否存在满足cfilter条件的怪兽。
function c32542011.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在满足cfilter条件的怪兽。
	return Duel.IsExistingMatchingCard(c32542011.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：检查场上是否有正面表示且属性为指定属性的怪兽。
function c32542011.cfilter2(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 过滤函数：检查墓地中的怪兽是否为本回合因效果cost被送去墓地且为水属性，且可以特殊召唤。
function c32542011.spfilter(c,tid,e,tp)
	local re=c:GetReasonEffect()
	return c:GetTurnID()==tid and c:IsReason(REASON_COST) and re and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理目标设定：判断是否满足发动条件，若满足则设置操作信息，若为火属性则设置破坏目标，若为水属性则设置特殊召唤目标及破坏目标。
function c32542011.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查己方场上是否存在正面表示且属性为火的怪兽。
	local b1=Duel.IsExistingMatchingCard(c32542011.cfilter2,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_FIRE)
		-- 检查己方场上是否存在至少1只正面表示的怪兽。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	-- 检查己方场上是否存在正面表示且属性为水的怪兽。
	local b2=Duel.IsExistingMatchingCard(c32542011.cfilter2,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_WATER)
		-- 检查己方场上是否有可用区域且墓地存在满足spfilter条件的怪兽。
		and ft>0 and Duel.IsExistingMatchingCard(c32542011.spfilter,tp,LOCATION_GRAVE,0,1,nil,Duel.GetTurnCount(),e,tp)
	if chk==0 then return b1 or b2 end
	if b1 then
		-- 获取己方场上所有正面表示的怪兽。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 设置操作信息：将己方场上所有正面表示的怪兽作为破坏目标。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
	if b2 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 获取满足spfilter条件的墓地怪兽。
		local g=Duel.GetMatchingGroup(c32542011.spfilter,tp,LOCATION_GRAVE,0,nil,Duel.GetTurnCount(),e,tp)
		-- 设置操作信息：将满足条件的墓地怪兽作为特殊召唤目标。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,ft,0,0)
		-- 获取己方场上所有怪兽。
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
		-- 设置操作信息：将己方场上所有怪兽作为破坏目标。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	end
end
-- 效果处理：根据场上属性决定执行水属性或火属性效果，水属性则特殊召唤墓地符合条件的怪兽并破坏己方场上1只怪兽，火属性则破坏场上1只怪兽并丢弃手牌。
function c32542011.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=0
	-- 检查己方场上是否存在正面表示且属性为水的怪兽，若存在则opt加1。
	if Duel.IsExistingMatchingCard(c32542011.cfilter2,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_WATER) then opt=opt+1 end
	-- 检查己方场上是否存在正面表示且属性为火的怪兽，若存在则opt加2。
	if Duel.IsExistingMatchingCard(c32542011.cfilter2,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_FIRE) then opt=opt+2 end
	if opt==1 or opt==3 then
		-- 获取己方场上可用的怪兽区域数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft>0 then
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足spfilter条件的墓地怪兽。
			local g=Duel.SelectMatchingCard(tp,c32542011.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,Duel.GetTurnCount(),e,tp)
			if g:GetCount()>0 then
				-- 将选中的怪兽特殊召唤到己方场上。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
				-- 中断当前效果处理，使后续处理视为错时点。
				Duel.BreakEffect()
				-- 提示玩家选择要破坏的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				-- 选择己方场上1只怪兽作为破坏目标。
				local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
				-- 将选中的怪兽破坏。
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
	if opt==2 or opt==3 then
		-- 中断当前效果处理，使后续处理视为错时点。
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上1只怪兽作为破坏目标。
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 显示选中的怪兽被选为对象的动画效果。
			Duel.HintSelection(g)
			-- 将选中的怪兽破坏。
			Duel.Destroy(g,REASON_EFFECT)
			-- 中断当前效果处理，使后续处理视为错时点。
			Duel.BreakEffect()
			-- 丢弃1张手牌至墓地。
			Duel.DiscardHand(tp,nil,1,1,REASON_DISCARD+REASON_EFFECT)
		end
	end
end
