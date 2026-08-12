--アルバスの落胤
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，丢弃1张手卡才能发动。包含这张卡的自己·对方场上的怪兽作为融合素材，把1只融合怪兽融合召唤。那个时候，不能把自己场上的其他怪兽作为融合素材。
function c68468459.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡召唤·特殊召唤的场合，丢弃1张手卡才能发动。包含这张卡的自己·对方场上的怪兽作为融合素材，把1只融合怪兽融合召唤。那个时候，不能把自己场上的其他怪兽作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,68468459)
	e1:SetCondition(c68468459.condition)
	e1:SetCost(c68468459.cost)
	e1:SetTarget(c68468459.target)
	e1:SetOperation(c68468459.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 效果发动条件判定函数
function c68468459.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否不处于伤害步骤或伤害计算时
	return Duel.GetCurrentPhase()&(PHASE_DAMAGE+PHASE_DAMAGE_CAL)==0
end
-- 效果发动代价处理函数
function c68468459.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除自身以外可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：场上表侧表示且可作为融合素材的怪兽
function c68468459.filter0(c)
	return c:IsFaceup() and c:IsCanBeFusionMaterial()
end
-- 过滤条件：不受当前效果影响的怪兽
function c68468459.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以进行融合召唤的融合怪兽
function c68468459.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 过滤条件：自己场上的怪兽
function c68468459.chkfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp)
end
-- 辅助过滤函数：用于限制不能使用自己场上的其他怪兽作为融合素材
function c68468459.fcheck(c)
	return function(tp,sg,fc)
				return not sg:IsExists(c68468459.chkfilter,1,c,tp)
			end
end
-- 效果发动目标判定与操作信息设置函数
function c68468459.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取自己场上可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 获取对方场上表侧表示可作为融合素材的怪兽
		local mg2=Duel.GetMatchingGroup(c68468459.filter0,tp,0,LOCATION_MZONE,nil)
		if mg2:GetCount()>0 then
			mg1:Merge(mg2)
		end
		-- 设定融合素材检查的额外限制条件（不能使用自己场上的其他怪兽）
		aux.FCheckAdditional=c68468459.fcheck(c)
		-- 检查额外卡组中是否存在可以使用包含这张卡在内的素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(c68468459.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在连锁素材效果存在时，检查是否能进行融合召唤
				res=Duel.IsExistingMatchingCard(c68468459.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,c,chkf)
			end
		end
		-- 重置融合素材检查的额外限制条件
		aux.FCheckAdditional=nil
		return res and c:IsRelateToEffect(e)
	end
	-- 设置操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：执行融合召唤
function c68468459.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 若在伤害步骤或伤害计算时则不处理效果
	if Duel.GetCurrentPhase()&(PHASE_DAMAGE+PHASE_DAMAGE_CAL)~=0 then return end
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 获取自己场上不受此效果影响且可作为融合素材的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil):Filter(c68468459.filter1,nil,e)
	-- 获取对方场上表侧表示、不受此效果影响且可作为融合素材的怪兽
	local mg2=Duel.GetMatchingGroup(c68468459.filter0,tp,0,LOCATION_MZONE,nil):Filter(c68468459.filter1,nil,e)
	if mg2:GetCount()>0 then
		mg1:Merge(mg2)
	end
	-- 设定融合素材检查的额外限制条件（不能使用自己场上的其他怪兽）
	aux.FCheckAdditional=c68468459.fcheck(c)
	-- 获取额外卡组中可以使用当前素材融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(c68468459.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(c68468459.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判定是否使用常规融合方式进行融合召唤（而非连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家选择包含这张卡在内的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使送墓与特殊召唤不视为同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 玩家根据连锁素材效果选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 重置融合素材检查的额外限制条件
	aux.FCheckAdditional=nil
end
