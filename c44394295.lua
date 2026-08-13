--影依融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只「影依」融合怪兽融合召唤。从额外卡组特殊召唤的怪兽在对方场上存在的场合，自己卡组的怪兽也能作为融合素材。
function c44394295.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的手卡·场上的怪兽作为融合素材，把1只「影依」融合怪兽融合召唤。从额外卡组特殊召唤的怪兽在对方场上存在的场合，自己卡组的怪兽也能作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,44394295+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c44394295.target)
	e1:SetOperation(c44394295.activate)
	c:RegisterEffect(e1)
end
-- 定义卡组素材过滤函数：筛选出卡组中可以作为融合素材且能够被送去墓地的怪兽。
function c44394295.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 定义素材免疫过滤函数：排除不受此效果影响的卡，确保素材可被正常作为融合素材。
function c44394295.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 定义融合怪兽过滤函数：筛选出额外卡组中的「影依」融合怪兽，且满足可被融合召唤、可被特殊召唤，并可用当前素材进行融合。
function c44394295.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x9d) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 定义条件过滤函数：检测怪兽是否为从额外卡组特殊召唤到场上。
function c44394295.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 发动时的目标检查函数：在发动前判断是否存在可用当前手卡·场上（以及满足条件时卡组）怪兽作为素材来融合召唤的「影依」融合怪兽，并设置操作信息。
function c44394295.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取当前玩家可用的融合素材组（包含手卡和场上的怪兽，以及受EXTRA_FUSION_MATERIAL影响的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查对方场上是否存在从额外卡组特殊召唤的怪兽。
		if Duel.IsExistingMatchingCard(c44394295.cfilter,tp,0,LOCATION_MZONE,1,nil) then
			-- 若对方场上有从额外卡组特殊召唤的怪兽，则从己方卡组中筛选可作为融合素材的怪兽。
			local mg2=Duel.GetMatchingGroup(c44394295.filter0,tp,LOCATION_DECK,0,nil)
			mg1:Merge(mg2)
		end
		-- 检查额外卡组中是否存在可用当前素材融合召唤的「影依」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c44394295.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家可用的连锁素材效果（例如「融合」相关的替代素材效果）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的素材组再次检查是否存在可融合召唤的「影依」融合怪兽。
				res=Duel.IsExistingMatchingCard(c44394295.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果处理时的操作信息，表示将进行特殊召唤（从额外卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：实际进行融合召唤，在普通素材和连锁素材之间选择来源，将素材送墓并特殊召唤融合怪兽。
function c44394295.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取当前可用融合素材，并排除不受此效果影响的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c44394295.filter1,nil,e)
	-- 再次检测对方场上是否存在从额外卡组特殊召唤的怪兽。
	if Duel.IsExistingMatchingCard(c44394295.cfilter,tp,0,LOCATION_MZONE,1,nil) then
		-- 若存在，则从卡组中选出可作为融合素材的怪兽并加入素材组。
		local mg2=Duel.GetMatchingGroup(c44394295.filter0,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
	end
	-- 筛选出所有可用普通素材融合召唤的「影依」融合怪兽。
	local sg1=Duel.GetMatchingGroup(c44394295.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 筛选出使用连锁素材可融合召唤的「影依」融合怪兽。
		sg2=Duel.GetMatchingGroup(c44394295.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 显示选择提示，让玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断玩家选择的融合怪兽属于哪一素材来源：若来自普通素材组（且未选择使用连锁素材），则执行普通融合流程；否则使用连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从普通素材组中选择这组融合召唤所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送去墓地，原因标记为效果、融合素材、融合召唤。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不被视为同一时点处理。
			Duel.BreakEffect()
			-- 将融合怪兽以表侧攻击表示特殊召唤，召唤方式为融合召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁素材提供的素材组中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
