--魔法の歯車
-- 效果：
-- ①：把自己场上3张表侧表示的「古代的机械」卡送去墓地才能发动。从手卡以及卡组各把最多1只「古代的机械巨人」无视召唤条件特殊召唤。那之后，自己场上有「古代的机械巨人」以外的怪兽存在的场合，那些怪兽全部破坏。这个效果的发动后，用自己回合计算的2回合内，自己不能通常召唤。
function c313513.initial_effect(c)
	-- 将卡号83104731（古代的机械巨人）登记到魔法齿车的“记载卡名”列表中，使相关检索/关联效果能识别这张卡记载了「古代的机械巨人」。
	aux.AddCodeList(c,83104731)
	-- 该段代码实现了整条①效果的注册与后续处理，对应原文：①：把自己场上3张表侧表示的「古代的机械」卡送去墓地才能发动。从手卡以及卡组各把最多1只「古代的机械巨人」无视召唤条件特殊召唤。那之后，自己场上有「古代的机械巨人」以外的怪兽存在的场合，那些怪兽全部破坏。这个效果的发动后，用自己回合计算的2回合内，自己不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c313513.cost)
	e1:SetTarget(c313513.target)
	e1:SetOperation(c313513.activate)
	c:RegisterEffect(e1)
end
-- 定义代价过滤条件：元素须为表侧表示的「古代的机械」卡，且可以作为代价送去墓地。用于筛选可作为发动代价的候选卡。
function c313513.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7) and c:IsAbleToGraveAsCost()
end
-- 代价支付处理：从己方场上选取3张满足条件的表侧「古代的机械」卡，确认送墓后仍留有可用怪兽区，然后将它们送入墓地作为发动代价。
function c313513.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得己方场上所有满足代价过滤条件的表侧「古代的机械」卡作为候选集合。
	local tg=Duel.GetMatchingGroup(c313513.cfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then
		e:SetLabel(1)
		-- 检查候选集合中是否存在3张卡，将它们作为代价送去墓地后自己场上仍有可用怪兽区域空位，以保证后续特殊召唤可以进行。
		return tg:CheckSubGroup(aux.mzctcheck,3,3,tp)
	end
	-- 显示选择提示，提示玩家选择要送去墓地的卡（发动代价）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从候选中选择3张卡作为代价，并保证选择后送墓仍满足怪兽区空位条件，且不可取消选择。
	local g=tg:SelectSubGroup(tp,aux.mzctcheck,false,3,3,tp)
	-- 将选中的3张卡作为代价送入墓地，完成效果的发动cost。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义可特殊召唤的对象：卡号为83104731的「古代的机械巨人」，且在当前效果下可以被无视召唤条件特殊召唤。
function c313513.filter(c,e,tp)
	return c:IsCode(83104731) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果发动时的目标检查/声明：确认手牌·卡组中存在可特殊召唤的「古代的机械巨人」，并设定本次发动将进行特殊召唤的操作信息。
function c313513.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若尚未因代价检查而放宽空位判断（label为0）且己方场上没有可用怪兽区域，则不能发动；代价已付费时允许后续送墓腾出空位。
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		-- 检查己方手牌·卡组中是否存在至少1只满足特殊召唤条件的「古代的机械巨人」。
		return Duel.IsExistingMatchingCard(c313513.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置操作信息：本次效果处理将进行特殊召唤，来源为手牌·卡组，数量为1（用于其他效果感知本连锁，如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义破坏对象：己方场上的里侧表示怪兽，或不是「古代的机械巨人」的表侧表示怪兽（即需要被破坏的怪兽）。
function c313513.dfilter(c)
	return c:IsFacedown() or not c:IsCode(83104731)
end
-- 选择函数，确保选出的卡来自不同的位置（手牌/卡组各最多1只），否则不合法。
function c313513.fselect(g)
	return g:GetClassCount(Card.GetLocation)==g:GetCount()
end
-- 效果处理总流程：计算可特召数量，选择并进行特召；若特召成功，破坏己场上非「古代的机械巨人」的怪兽；最后附加2回合不能通常召唤/覆盖怪兽的自肃。
function c313513.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算可特殊召唤的最大数量：取当前怪兽区可用空格数和2的较小值。
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	-- 取得所有本次可特殊召唤的「古代的机械巨人」（手牌+卡组）作为候选。
	local g=Duel.GetMatchingGroup(c313513.filter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if ft>0 and g:GetCount()>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 显示选择提示，要求玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroup(tp,c313513.fselect,false,1,ft)
		-- 将选中的卡无视召唤条件地以表侧表示特殊召唤到己方场上；若特殊召唤成功（数量大于0），继续后续破坏处理。
		if sg and Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)>0 then
			-- 取得己方场上所有应该被破坏的怪兽（里侧表示或不是「古代的机械巨人」的怪兽）。
			local dg=Duel.GetMatchingGroup(c313513.dfilter,tp,LOCATION_MZONE,0,nil)
			if dg:GetCount()>0 then
				-- 中断当前效果处理，使接下来的破坏作为独立效果处理，避免错过时点。
				Duel.BreakEffect()
				-- 以效果破坏这些怪兽。
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
	-- 这个效果的发动后，用自己回合计算的2回合内，自己不能通常召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_SELF_TURN+RESET_PHASE+PHASE_END,2)
	e1:SetTargetRange(1,0)
	-- 为发动玩家注册一个持续2回合的“不能通常召唤怪兽”的永续效果（影响己方玩家）。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 为发动玩家再注册一个持续2回合的“不能覆盖怪兽”的永续效果，因为通常召唤也包括里侧覆盖，所以一并禁止。
	Duel.RegisterEffect(e2,tp)
end
