--アウトバースト・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，这张卡以外的自己场上的怪兽全部破坏。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是暗属性怪兽不能特殊召唤。
-- ②：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为连接素材把1只龙族连接怪兽连接召唤。
function c87263576.initial_effect(c)
	-- ①：自己场上有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，这张卡以外的自己场上的怪兽全部破坏。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是暗属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87263576,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,87263576)
	e1:SetCondition(c87263576.spcon)
	e1:SetTarget(c87263576.sptg)
	e1:SetOperation(c87263576.spop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为连接素材把1只龙族连接怪兽连接召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87263576,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,87263577)
	e2:SetCondition(c87263576.lkcon)
	e2:SetTarget(c87263576.lktg)
	e2:SetOperation(c87263576.lkop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：自己场上有怪兽存在。
function c87263576.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否大于0。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
end
-- 效果①的靶子（Target）函数：检查自身能否特殊召唤，并设置特殊召唤和破坏的操作信息。
function c87263576.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域，且这张卡是否可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，涉及卡片为自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 获取自己场上除这张卡以外的所有怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,e:GetHandler())
	if #g>0 then
		-- 设置破坏的操作信息，涉及卡片为自己场上除这张卡以外的所有怪兽。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	end
end
-- 效果①的效果处理（Operation）函数：特殊召唤自身，适用属性限制，并破坏自己场上的其他怪兽。
function c87263576.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local res=false
		-- 尝试将自身以表侧表示特殊召唤。
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			res=true
			-- 只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是暗属性怪兽不能特殊召唤。②：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为连接素材把1只龙族连接怪兽连接召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(87263576,2))  --"「爆发龙」效果适用中"
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_PLAYER_TARGET)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetAbsoluteRange(tp,1,0)
			e1:SetTarget(c87263576.splimit)
			c:RegisterEffect(e1,true)
		end
		-- 完成特殊召唤的处理。
		Duel.SpecialSummonComplete()
		-- 获取自己场上除这张卡以外的所有怪兽。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,e:GetHandler())
		if res and #g>0 then
			-- 划分效果处理阶段，使后续的破坏处理不与特殊召唤同时进行（造成错时点）。
			Duel.BreakEffect()
			-- 因效果破坏选定的怪兽。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 限制自己不能特殊召唤暗属性以外的怪兽。
function c87263576.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
-- 效果②的发动条件：对方的主要阶段。
function c87263576.lkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 检查当前是否为对方回合，且处于主要阶段1或主要阶段2。
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤可以进行连接召唤的龙族连接怪兽。
function c87263576.lkfilter(c,lc)
	return c:IsRace(RACE_DRAGON) and c:IsLinkSummonable(nil,lc)
end
-- 效果②的靶子（Target）函数：检查额外卡组是否存在可以连接召唤的龙族连接怪兽，并设置特殊召唤的操作信息。
function c87263576.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只满足条件的龙族连接怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c87263576.lkfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 设置特殊召唤的操作信息，涉及卡片为额外卡组的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理（Operation）函数：选择1只龙族连接怪兽，并以包含自身的场上怪兽为素材进行连接召唤。
function c87263576.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有可以使用这张卡作为素材进行连接召唤的龙族连接怪兽。
	local g=Duel.GetMatchingGroup(c87263576.lkfilter,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 进行连接召唤，将选定的怪兽特殊召唤。
		Duel.LinkSummon(tp,sg:GetFirst(),nil,c)
	end
end
