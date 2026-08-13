--光と昇華の竜
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：从额外卡组把1只龙族·8星怪兽除外才能发动。这张卡从手卡特殊召唤。这个回合，自己不是龙族怪兽不能特殊召唤。
-- ②：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
-- ③：对方怪兽的攻击宣言时才能发动。这张卡的攻击力·守备力下降500，那只对方怪兽的攻击力下降1500。
local s,id,o=GetID()
-- 注册该卡的三个效果：①除外额外卡组1只龙族·8星怪兽从手牌特殊召唤，并附加本回合非龙族不能特殊召唤的限制；②自己主要阶段用自己手卡·场上的怪兽作为融合素材进行融合召唤；③对方怪兽攻击宣言时自身攻守下降500，对方攻击怪兽攻击力下降1500。
function s.initial_effect(c)
	-- ①：从额外卡组把1只龙族·8星怪兽除外才能发动。这张卡从手卡特殊召唤。这个回合，自己不是龙族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.ftg)
	e2:SetOperation(s.fop)
	c:RegisterEffect(e2)
	-- ③：对方怪兽的攻击宣言时才能发动。这张卡的攻击力·守备力下降500，那只对方怪兽的攻击力下降1500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"攻守下降"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
s.fusion_effect=true
-- 代价筛选函数：判断怪兽是否为龙族·8星，且可以作为代价从额外卡组除外。
function s.costfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(8) and c:IsAbleToRemoveAsCost()
end
-- 代价函数：从额外卡组选择1只龙族·8星怪兽，将其表侧表示除外作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检查：确认额外卡组中是否存在至少1只满足代价筛选条件的龙族·8星怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要除外的卡，显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己的额外卡组中选择1只满足costfilter条件的怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选中的怪兽以表侧表示除外，作为效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤目标函数：检查自己主要怪兽区有空位，且这张卡能够以表侧表示特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：将特殊召唤这张卡的信息加入当前连锁，供后续检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：先特殊召唤这张卡，然后给自己附加本回合不能特殊召唤龙族以外怪兽的自肃效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是龙族怪兽不能特殊召唤。②：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。③：对方怪兽的攻击宣言时才能发动。这张卡的攻击力·守备力下降500，那只对方怪兽的攻击力下降1500。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.spelimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到当前玩家tp，使其在本回合内不能特殊召唤龙族以外的怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制函数：当对象怪兽不是龙族时返回true，表示不能特殊召唤该怪兽。
function s.spelimit(e,c)
	return not c:IsRace(RACE_DRAGON)
end
-- 融合素材过滤函数：排除对当前融合效果免疫的卡片，确保素材不会被无效。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 融合怪兽候选过滤函数：筛选额外卡组中满足融合召唤条件、能够特殊召唤且能与当前素材组成合法素材组合的融合怪兽。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤目标函数：检查是否能用常规素材或连锁素材从额外卡组融合召唤1只融合怪兽，并在发动时登记特殊召唤信息。
function s.ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取当前玩家可用的融合素材组，通常包含手卡和场上的怪兽，以及额外融合素材效果提供的卡。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 用常规融合素材mg1检查额外卡组是否存在可融合召唤的融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取连锁素材效果（若存在），用于判断是否可以借助连锁素材进行融合召唤。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 用连锁素材提供的素材mg2及素材限制f，确认额外卡组中是否存在可融合召唤的融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记操作信息：本效果将从额外卡组特殊召唤1只怪兽，供后续连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤处理：选择要融合召唤的怪兽，选择融合素材，将素材送入墓地并融合召唤；若使用连锁素材，则调用其特殊处理。
function s.fop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取常规融合素材组，并过滤掉对此融合效果免疫的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 用常规素材组mg1从额外卡组筛选所有可融合召唤的融合怪兽，作为候选组sg1。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果（如果有），以便在常规素材不可用时使用连锁素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 用连锁素材组mg2及素材限制f从额外卡组筛选可融合召唤的融合怪兽，作为候选组sg2。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽是否走常规融合流程：若其可用常规素材融合，且没有连锁素材可使用（或该怪兽不在连锁素材候选中，或玩家选择不使用连锁素材），则进行常规融合；否则走连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从常规素材组mg1中选择用于融合召唤的素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将常规融合素材mat1送入墓地，原因记为效果·素材·融合。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的融合召唤处理成为独立事件，避免错过时点。
			Duel.BreakEffect()
			-- 以融合召唤方式将所选融合怪兽表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材组mg2中选择用于融合召唤的素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- ③效果发动条件：对方怪兽进行攻击宣言时满足条件。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击宣言的怪兽是否属于对方控制，即攻击者是tp的对手。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- ③效果目标检查：确认这张卡的攻击力和守备力均不低于500，以保证可以发动下降效果。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAttackAbove(500) and c:IsDefenseAbove(500) end
end
-- ③效果处理：这张卡的攻击力和守备力各下降500，若条件满足，再使那只攻击怪兽的攻击力下降1500。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击宣言的对方怪兽，作为后续攻击力下降效果的对象。
	local bc=Duel.GetAttacker()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsAttackAbove(500) and c:IsDefenseAbove(500) then
		-- 这张卡的攻击力·守备力下降500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
		if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) and bc:IsControler(1-tp) and bc:IsFaceup() and bc:IsRelateToBattle() then
			-- 那只对方怪兽的攻击力下降1500。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_UPDATE_ATTACK)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetValue(-1500)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			bc:RegisterEffect(e3)
		end
	end
end
