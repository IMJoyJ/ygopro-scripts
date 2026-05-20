--超越融合
-- 效果：
-- 不能对应这张卡的发动让卡的效果发动。
-- ①：支付2000基本分才能发动。自己场上的怪兽2只作为融合素材，把1只融合怪兽融合召唤。
-- ②：把墓地的这张卡除外，以这张卡的效果融合召唤的1只怪兽为对象才能发动。那只怪兽的融合召唤使用过的一组融合素材怪兽从自己墓地特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0，效果无效化。
function c76647978.initial_effect(c)
	-- 不能对应这张卡的发动让卡的效果发动。①：支付2000基本分才能发动。自己场上的怪兽2只作为融合素材，把1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76647978,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c76647978.cost)
	e1:SetTarget(c76647978.target)
	e1:SetOperation(c76647978.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以这张卡的效果融合召唤的1只怪兽为对象才能发动。那只怪兽的融合召唤使用过的一组融合素材怪兽从自己墓地特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0，效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76647978,1))  --"融合素材特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果②的发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c76647978.sptg)
	e2:SetOperation(c76647978.spop)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
-- 效果①的发动代价（Cost）处理函数：检查并支付2000点基本分。
function c76647978.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能支付2000点基本分。
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 让玩家支付2000点基本分。
	Duel.PayLPCost(tp,2000)
end
-- 融合素材数量检查辅助函数：限制融合素材的数量最多为2只。
function c76647978.fcheck(tp,sg,fc)
	return #sg<=2
end
-- 融合素材组数量检查辅助函数：限制选择的融合素材数量最多为2只。
function c76647978.gcheck(sg)
	return #sg<=2
end
-- 过滤场上且不受当前效果影响的怪兽（用于融合素材）。
function c76647978.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的融合怪兽。
function c76647978.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果①的发动准备（Target）处理函数：检查是否能进行融合召唤，并设置连锁限制。
function c76647978.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家场上可用的融合素材怪兽。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 设置融合素材数量限制的额外检查函数。
		aux.FCheckAdditional=c76647978.fcheck
		-- 设置融合素材组数量限制的额外检查函数。
		aux.GCheckAdditional=c76647978.gcheck
		-- 检查额外卡组是否存在可以使用场上素材进行融合召唤的怪兽。
		local res=Duel.IsExistingMatchingCard(c76647978.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如连锁素材）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，是否存在可以融合召唤的怪兽。
				res=Duel.IsExistingMatchingCard(c76647978.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 重置融合素材数量限制的额外检查函数。
		aux.FCheckAdditional=nil
		-- 重置融合素材组数量限制的额外检查函数。
		aux.GCheckAdditional=nil
		return res
	end
	-- 设置连锁信息：包含从额外卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制：任何卡的效果都不能对应这张卡的发动而发动。
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 效果①的效果处理（Operation）函数：将场上的2只怪兽送去墓地，从额外卡组融合召唤1只融合怪兽。
function c76647978.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家场上不受该效果影响的可用融合素材怪兽。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c76647978.filter1,nil,e)
	-- 在效果处理时，设置融合素材数量限制的额外检查函数。
	aux.FCheckAdditional=c76647978.fcheck
	-- 在效果处理时，设置融合素材组数量限制的额外检查函数。
	aux.GCheckAdditional=c76647978.gcheck
	-- 获取额外卡组中可以使用场上素材进行融合召唤的怪兽组。
	local sg1=Duel.GetMatchingGroup(c76647978.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 在效果处理时，获取玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下，可以融合召唤的怪兽组。
		sg2=Duel.GetMatchingGroup(c76647978.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤（融合召唤）的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡的效果进行常规融合召唤（而非连锁素材等其他效果）。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择一组满足融合召唤条件的场上怪兽作为融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材怪兽送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤与送去墓地不视为同时处理。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在使用连锁素材等效果时，选择对应的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:RegisterFlagEffect(76647978,RESET_EVENT+RESETS_STANDARD,0,1)
		tc:CompleteProcedure()
		local e1=e:GetLabelObject()
		if e1 then e1:SetLabelObject(tc) end
	end
	-- 在效果处理结束前，重置融合素材数量限制的额外检查函数。
	aux.FCheckAdditional=nil
	-- 在效果处理结束前，重置融合素材组数量限制的额外检查函数。
	aux.GCheckAdditional=nil
end
-- 过滤作为该融合怪兽的融合素材且存在于墓地中的怪兽。
function c76647978.mgfilter(c,e,tp,fusc,mg)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and c:GetReason()&(REASON_FUSION+REASON_MATERIAL)==(REASON_FUSION+REASON_MATERIAL) and c:GetReasonCard()==fusc
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and fusc:CheckFusionMaterial(mg,c,PLAYER_NONE,true)
end
-- 过滤符合特殊召唤素材条件的融合怪兽（必须是由本卡效果融合召唤且素材都在墓地）。
function c76647978.spfilter(c,e,tp)
	if c:IsFaceup() and c:GetFlagEffect(76647978)~=0 and c==e:GetLabelObject() then
		local mg=c:GetMaterial()
		local ct=mg:GetCount()
		-- 检查融合素材数量是否大于0，且自己场上的怪兽区域空位数是否足够容纳这些素材。
		return ct>0 and ct<=Duel.GetLocationCount(tp,LOCATION_MZONE)
			and mg:FilterCount(c76647978.mgfilter,nil,e,tp,c,mg)==ct
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			and not Duel.IsPlayerAffectedByEffect(tp,59822133)
	else return false end
end
-- 效果②的发动准备（Target）处理函数：选择由本卡效果融合召唤的1只怪兽作为对象，并设置特殊召唤的连锁信息。
function c76647978.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c76647978.spfilter(chkc,e,tp) end
	-- 在发动准备阶段，检查场上是否存在符合条件的、由本卡效果融合召唤的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c76647978.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只由本卡效果融合召唤的表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,c76647978.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置连锁信息：包含从墓地特殊召唤2只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理（Operation）函数：将作为对象的融合怪兽的一组融合素材从墓地特殊召唤，并使其攻击力·守备力变成0，效果无效化。
function c76647978.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的融合怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local mg=tc:GetMaterial()
	local ct=mg:GetCount()
	-- 在效果处理时，再次检查融合素材数量是否大于0，且自己场上的怪兽区域空位数是否足够。
	if ct>0 and ct<=Duel.GetLocationCount(tp,LOCATION_MZONE)
		and mg:FilterCount(c76647978.mgfilter,nil,e,tp,tc,mg)==ct
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		local sc=mg:GetFirst()
		while sc do
			-- 尝试将融合素材怪兽以表侧表示特殊召唤到自己场上（分步处理）。
			if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
				-- 效果无效化。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1,true)
				-- 效果无效化。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2,true)
				-- 这个效果特殊召唤的怪兽的攻击力·守备力变成0，效果无效化。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_SET_ATTACK_FINAL)
				e3:SetValue(0)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e3,true)
				local e4=e3:Clone()
				e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
				sc:RegisterEffect(e4,true)
			end
			sc=mg:GetNext()
		end
		-- 完成所有分步特殊召唤怪兽的处理。
		Duel.SpecialSummonComplete()
	end
end
