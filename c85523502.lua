--ウィスカ・ブリッツクリーク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的「雷盟」卡的效果把卡破坏的自己·对方回合，把手卡的这张卡给对方观看才能发动。从手卡把最多3只雷族怪兽特殊召唤。那之后，可以把最多有那个数量的场上的卡破坏。这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。
-- ②：手卡以外有怪兽的效果发动时，让自己场上1只其他的雷族怪兽回到手卡才能发动。那个发动无效并破坏。
local s,id,o=GetID()
-- 初始化晶须雷盟兵的卡片效果，注册效果①的特殊召唤与破坏效果，注册效果②的无效并破坏效果，并注册全局破坏监测效果。
function s.initial_effect(c)
	-- ①：自己的「雷盟」卡的效果把卡破坏的自己·对方回合，把手卡的这张卡给对方观看才能发动。从手卡把最多3只雷族怪兽特殊召唤。那之后，可以把最多有那个数量的场上的卡破坏。这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：手卡以外有怪兽的效果发动时，让自己场上1只其他的雷族怪兽回到手卡才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- ①：自己的「雷盟」卡的效果把卡破坏的自己·对方回合，把手卡的这张卡给对方观看才能发动。从手卡把最多3只雷族怪兽特殊召唤。那之后，可以把最多有那个数量的场上的卡破坏。这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.regop)
		-- 将全局破坏监测效果注册到全局环境中。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局破坏监测效果的被破坏卡过滤条件：必须是由效果导致破坏的卡。
function s.dcfilter(c)
	return c:IsReason(REASON_EFFECT)
end
-- 全局破坏监测效果的执行操作：当有卡被「雷盟」卡的效果破坏时，为该效果的发动玩家注册一个本回合有效的标识。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if re and eg:IsExists(s.dcfilter,1,nil) and re:GetHandler():IsSetCard(0x1df) then
		-- 为该玩家注册一个本回合有效的标记效果，表示本回合自己有「雷盟」卡的效果将卡破坏。
		Duel.RegisterFlagEffect(rp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 效果①的发动条件：本回合自己的「雷盟」卡的效果把卡破坏过。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果①的发动条件判定：检查当前玩家本回合是否有「雷盟」卡的效果将卡破坏的标记。
	return Duel.GetFlagEffect(tp,id)>0
end
-- 效果①的发动代价：确认手牌中的这张卡没有处于公开状态。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 效果①中特殊召唤怪兽的过滤条件：过滤手牌中雷族的且能特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_THUNDER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的目标选择与发动判定：检查己方主要怪兽区域是否有空位且手牌中是否存在能特殊召唤的雷族怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果①发动判定的一部分：检查己方主要怪兽区域是否拥有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果①发动判定的一部分：检查手牌中是否存在可以特殊召唤的雷族怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果①处理时的操作信息：预计从手牌特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的执行操作：从手牌选择最多3只雷族怪兽特殊召唤到己方场上（同时受怪兽区域空位以及「青眼精灵龙」等限制效果的影响），然后可以破坏最多有该特殊召唤数量的场上的卡。此后为玩家注册本回合的特召限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上可用的怪兽区域空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 then
		if ft>3 then ft=3 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 提示玩家选择要特殊召唤的雷族怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手牌中选择符合条件的雷族怪兽进行特殊召唤。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选定的雷族怪兽特殊召唤到玩家自己场上。
			local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			-- 立刻刷新场地信息以确保后续步骤中场上卡片数量计算的准确性。
			Duel.AdjustAll()
			-- 获取场上所有可以作为破坏对象的卡片集合。
			local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
			-- 效果①特召后的可选效果判定：如果成功特殊召唤且场上有卡可以破坏，玩家可以选择是否破坏场上的卡。
			if ct~=0 and dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡破坏？"
				-- 中断当前的效果处理，使之后破坏卡片的操作不与特殊召唤同时处理。
				Duel.BreakEffect()
				-- 提示玩家选择要破坏的卡片。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				local sdg=dg:Select(tp,1,ct,nil)
				-- 在场上高亮显示选定要破坏的卡片。
				Duel.HintSelection(sdg)
				-- 以效果原因破坏被选择的卡片。
				Duel.Destroy(sdg,REASON_EFFECT)
			end
		end
	end
	-- 这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。②：手卡以外有怪兽的效果发动时，让自己场上1只其他的雷族怪兽回到手卡才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该玩家在这个回合不能从手牌以外特殊召唤效果怪兽的限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 特召限制的过滤条件：如果是效果怪兽，且特殊召唤来源不是手牌，则限制其特殊召唤。
function s.splimit(e,c)
	return c:IsType(TYPE_EFFECT) and not c:IsLocation(LOCATION_HAND)
end
-- 效果②的发动条件：手牌以外有怪兽的效果发动，且这张卡在怪兽区域存在、该连锁可被无效。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前引发连锁的效果所处的发动位置。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return LOCATION_HAND&loc==0
		and re:IsActiveType(TYPE_MONSTER)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 效果②发动条件判定的一部分：检查被发动的效果是否可以被无效。
		and Duel.IsChainNegatable(ev)
end
-- 效果②的Cost（代价）过滤条件：过滤己方场上表侧表示的、能回到手牌的、除这张卡以外的雷族怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER) and c:IsAbleToHandAsCost()
end
-- 效果②的发动代价：让自己场上1只其他的雷族怪兽回到手卡。
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果②发动代价判定：检查己方场上是否存在除这张卡以外的可回到手牌的雷族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回手牌的雷族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择1只符合条件的雷族怪兽作为回到手牌的代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 在场上高亮显示选定作为代价的雷族怪兽。
	Duel.HintSelection(g)
	-- 将选择的雷族怪兽送回持有者的手牌。
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 效果②的发动判定与操作信息注册：在效果处理时声明将该发动无效并破坏的操作信息。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果②处理时的操作信息：预计将该发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置效果②处理时的操作信息：预计将该效果发动的源头卡片破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果②的执行操作：使该怪兽效果的发动无效，若成功无效则将其破坏。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时：判断该发动是否成功被无效，以及该卡片是否与引发连锁的卡片相关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 以效果原因破坏该效果被无效的发动源头卡片。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
