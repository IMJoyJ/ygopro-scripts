--無死虫団の補給兵
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：昆虫族怪兽的效果发动时才能发动。这张卡从手卡特殊召唤。连锁对方的效果的发动把这个效果发动的场合，再把那个效果无效。这个效果的发动后，直到下次的自己回合的结束时自己不是昆虫族怪兽不能从额外卡组特殊召唤。
-- ②：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只昆虫族融合怪兽融合召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果
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
-- 判断连锁的种族是否为昆虫族
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁发动时的种族信息
	local race=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE)
	return re:IsActiveType(TYPE_MONSTER) and race&RACE_INSECT>0
end
-- 判断是否满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的卡为操作对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	if ep~=tp then
		-- 设置使对方效果无效的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	end
end
-- 执行①效果的处理流程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否能成功特殊召唤并满足无效条件
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and ep~=tp then
		-- 使连锁效果无效
		Duel.NegateEffect(ev)
	end
	-- 设置一个场上的效果，禁止非昆虫族怪兽从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 判断当前回合玩家是否为效果使用者
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	end
	-- 注册该禁止效果
	Duel.RegisterEffect(e1,tp)
end
-- 定义禁止特殊召唤的条件
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_INSECT)
end
-- 定义过滤函数，用于筛选未免疫效果的卡
function s.spfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 定义过滤函数，用于筛选满足融合召唤条件的昆虫族融合怪兽
function s.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_INSECT) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 判断是否可以发动②效果
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.spfilter1,nil,e)
		-- 检查是否存在满足条件的昆虫族融合怪兽
		local res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 如果存在连锁融合素材效果，则检查其提供的融合怪兽
				res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置融合召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行②效果的处理流程
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.spfilter1,nil,e)
	-- 获取满足条件的昆虫族融合怪兽
	local sg1=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 如果存在连锁融合素材效果，则获取其提供的融合怪兽
		sg2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用第一组融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 进行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 选择第二组融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
