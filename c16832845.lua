--ファイナル・ギアス
-- 效果：
-- ①：原本等级是7星以上的怪兽从自己以及对方的场上各有1只以上被送去墓地的回合才能发动。双方墓地的怪兽全部除外。那之后，可以把这个效果除外的怪兽之内等级最高的1只魔法师族怪兽在自己场上特殊召唤。
function c16832845.initial_effect(c)
	-- 原本等级是7星以上的怪兽从自己以及对方的场上各有1只以上被送去墓地的回合才能发动。双方墓地的怪兽全部除外。那之后，可以把这个效果除外的怪兽之内等级最高的1只魔法师族怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_TOGRAVE)
	e1:SetCondition(c16832845.condition)
	e1:SetTarget(c16832845.target)
	e1:SetOperation(c16832845.activate)
	c:RegisterEffect(e1)
	if not c16832845.global_check then
		c16832845.global_check=true
		c16832845[0]=false
		c16832845[1]=false
		-- 原本等级是7星以上的怪兽从自己以及对方的场上各有1只以上被送去墓地
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c16832845.checkop)
		-- 将全局监测效果ge1注册到场上（对所有玩家生效），持续监听“怪兽被送去墓地”事件，以记录双方是否满足原等级7星以上从场上送墓的条件。
		Duel.RegisterEffect(ge1,0)
		-- 的回合才能发动。双方墓地的怪兽全部除外。那之后，可以把这个效果除外的怪兽之内等级最高的1只魔法师族怪兽在自己场上特殊召唤。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c16832845.clear)
		-- 将抽卡阶段开始时重置标记的全局效果ge2注册到场上，使“回合内曾发生7星以上怪兽从场上送墓”的记录在每个回合的抽卡阶段被清空，从而保证“这个回合”的限制。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 检查本次进入墓地的每只怪兽：若其原本等级在7星以上且是从场上（怪兽区）被送去墓地，则把该怪兽原控制者对应的标记设为true，用于记录该控制者本回合已满足送墓条件。
function c16832845.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:GetOriginalLevel()>=7 and tc:IsPreviousLocation(LOCATION_MZONE) then
			c16832845[tc:GetPreviousControler()]=true
		end
		tc=eg:GetNext()
	end
end
-- 将双方标记都重置为false，表示进入新回合后重新计算本回合内是否各有1只以上符合条件的怪兽从双方场上送墓。
function c16832845.clear(e,tp,eg,ep,ev,re,r,rp)
	c16832845[0]=false
	c16832845[1]=false
end
-- 发动条件判定：当自己方标记和对方方标记都为true时，即本回合内自己场上和对方场上都各有至少1只原本等级7星以上的怪兽被送去墓地，才允许发动。
function c16832845.condition(e,tp,eg,ep,ev,re,r,rp)
	return c16832845[0] and c16832845[1]
end
-- 筛选墓地中满足“是怪兽且可以被除外”的卡片，作为后面除外处理和操作信息设置的候选对象。
function c16832845.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果发动时的目标阶段：检测墓地中至少存在1张可除外的怪兽；若存在，则获取所有可除外的墓地怪兽并设置本次连锁的除外操作信息，数量为这些怪兽的总数。
function c16832845.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时检查发动合法性：若双方墓地中不存在任何1张可除外的怪兽，则不能发动该效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c16832845.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 获取当前双方墓地中所有满足可除外条件的怪兽组，用于设置操作信息（CATEGORY_REMOVE）时告知系统将除外的对象和数量。
	local g=Duel.GetMatchingGroup(c16832845.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	-- 向当前连锁设置操作信息：本次效果包含除外，处理对象为墓地所有可除外的怪兽g，数量为g:GetCount()，目标玩家和位置为0（由效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 筛选被除外的怪兽中满足“魔法师族、可以特殊召唤、位于除外区、等级大于0”的怪兽，作为“等级最高的1只魔法师族怪兽”的候选。
function c16832845.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsLocation(LOCATION_REMOVED) and c:GetLevel()>0
end
-- 效果处理主流程：先获取双方墓地所有可除外的怪兽并全部除外；随后从被除外的怪兽中筛出可特殊召唤的魔法师族怪兽，若存在且玩家选择是，则中断效果并从中选出等级最高的1只特殊召唤到自己场上。
function c16832845.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新获取双方墓地所有可除外的怪兽组，确保实际处理的除外对象是最新状态下的墓地怪兽。
	local g=Duel.GetMatchingGroup(c16832845.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	-- 将上述怪兽组全部以表侧表示除外，除外原因视为效果；若至少除外成功1张，才继续执行后续特殊召唤。
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		-- 获取刚才实际被除外的怪兽组，并筛选出其中满足特殊召唤条件的魔法师族怪兽（spfilter），得到候选集合og。
		local og=Duel.GetOperatedGroup():Filter(c16832845.spfilter,nil,e,tp)
		-- 若存在可特殊召唤的魔法师族怪兽，且发动玩家选择“是”（是否特殊召唤），则继续执行；否则不再进行特殊召唤。
		if og:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(16832845,0)) then  --"是否把魔法师族怪兽在自己场上特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤与之前的除外分开处理，以避免错过时点或连锁时点问题。
			Duel.BreakEffect()
			local sg=og:GetMaxGroup(Card.GetLevel)
			if sg:GetCount()>1 then
				-- 当等级最高的魔法师族候选数量超过1张时，向玩家弹出选择提示，并让玩家从中选择1张作为最终特殊召唤对象。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				sg=sg:Select(tp,1,1,nil)
			end
			-- 将选定的1只魔法师族怪兽以表侧表示特殊召唤到发动玩家的场上（需正常满足特殊召唤与苏生限制）。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
