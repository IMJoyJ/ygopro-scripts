--無死虫団の補給兵
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：昆虫族怪兽的效果发动时才能发动。这张卡从手卡特殊召唤。连锁对方的效果的发动把这个效果发动的场合，再把那个效果无效。这个效果的发动后，直到下次的自己回合的结束时自己不是昆虫族怪兽不能从额外卡组特殊召唤。
-- ②：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只昆虫族融合怪兽融合召唤。
local s,id,o=GetID()
-- 初始化效果：为这张卡注册两个效果——①为诱发即时效果（手牌发动，连锁昆虫族怪兽效果发动时特召自身、无效对方效果并附加自肃），②为起动效果（场上发动，进行昆虫族融合召唤）。
function s.initial_effect(c)
	-- ①：昆虫族怪兽的效果发动时才能发动。这张卡从手卡特殊召唤。连锁对方的效果的发动把这个效果发动的场合，再把那个效果无效。这个效果的发动后，直到下次的自己回合的结束时自己不是昆虫族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只昆虫族融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 发动条件：连锁发动的效果必须是昆虫族怪兽的效果（效果类型为怪兽效果且触发种族含昆虫族）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁ev处触发效果的种族，用于判断是否为昆虫族效果。
	local race=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE)
	return re:IsActiveType(TYPE_MONSTER) and race&RACE_INSECT>0
end
-- 发动合法性检测：自己主要怪兽区有空位，且这张卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：效果处理时将这张卡特殊召唤，对象为本卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	if ep~=tp then
		-- 设置操作信息：当连锁的是对方效果时，将无效该连锁效果，对象为对方发动的效果来源卡eg。
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	end
end
-- 处理①效果：将本卡特殊召唤；若连锁了对方效果且特殊召唤成功，则无效该效果；随后附加自肃，使自己在下次自己回合结束前不能从额外卡组特殊召唤非昆虫族怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断条件：这张卡仍与效果关联、特殊召唤成功，且被连锁的效果是对方发动的，满足则执行无效。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and ep~=tp then
		-- 使连锁ev的效果无效。
		Duel.NegateEffect(ev)
	end
	-- 这个效果的发动后，直到下次的自己回合的结束时自己不是昆虫族怪兽不能从额外卡组特殊召唤。②：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只昆虫族融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 若当前回合玩家是自己，自肃效果重置计数为2（持续到下次自己回合结束）；否则重置计数为1（在下一个自己回合结束时重置）。
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	end
	-- 将自肃效果作为场地效果注册给玩家tp，使其在该期间受到'不能特殊召唤非昆虫族额外怪兽'的限制。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制条件：位于额外卡组且种族不是昆虫族的怪兽不能特殊召唤。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_INSECT)
end
-- 融合素材过滤条件：素材卡不能对当前融合效果免疫。
function s.spfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 融合怪兽候选条件：必须是昆虫族融合怪兽，且能被融合召唤，并能够用提供的素材组成合法融合素材组合。
function s.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_INSECT) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果发动检查：确认存在可用融合素材（且素材不被免疫），额外卡组存在符合条件的昆虫族融合怪兽；若存在连锁素材效果，也一并检查；最后设置融合召唤的操作信息。
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家tp可用的融合素材（手卡·场上的怪兽及额外融合素材效果），并排除对当前效果免疫的卡。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.spfilter1,nil,e)
		-- 检查额外卡组是否存在至少1只满足条件的昆虫族融合怪兽，其素材要求能被mg1满足。
		local res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家tp当前适用的连锁素材效果（替代融合素材的效果），用于扩展素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在使用连锁素材效果的情况下，用mg2和素材检查函数mf再次检查额外卡组是否存在可融合召唤的昆虫族融合怪兽。
				res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：效果处理时将进行特殊召唤，预计从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理②效果：获取可用融合素材及额外卡组中的昆虫族融合怪兽候选；让玩家选择要融合召唤的怪兽；若使用常规素材，则选择素材送去墓地后融合召唤；若使用连锁素材效果，则按该效果处理；最后完成融合召唤手续。
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取并过滤可用融合素材，排除对当前效果免疫的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.spfilter1,nil,e)
	-- 获取额外卡组中所有用mg1作为素材可融合召唤的昆虫族融合怪兽，作为候选。
	local sg1=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家tp的连锁素材效果，用于支持替代素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 根据连锁素材效果提供的素材组mg2和素材检查函数mf，获取额外卡组中可融合召唤的候选怪兽。
		sg2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡（HINTMSG_SPSUMMON）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断：若所选怪兽不在连锁素材候选中，或玩家选择不使用连锁素材效果，则按常规融合处理；否则使用连锁素材效果处理。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从常规素材组mg1中选择融合素材（需满足所选融合怪兽的素材要求）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将所选融合素材送去墓地，作为融合素材。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果链条，使接下来的特殊召唤作为独立处理，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以表侧表示进行融合召唤（特殊召唤）到tp场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 在使用连锁素材效果的情况下，让玩家从连锁素材组mg2中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
