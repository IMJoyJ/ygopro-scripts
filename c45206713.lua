--DDスワラル・スライム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，自己主要阶段才能发动。包含这张卡的手卡的怪兽作为融合素材，把1只「DDD」融合怪兽融合召唤。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只「DD」怪兽特殊召唤。
function c45206713.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在的场合，自己主要阶段才能发动。包含这张卡的手卡的怪兽作为融合素材，把1只「DDD」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,45206713)
	e1:SetTarget(c45206713.target)
	e1:SetOperation(c45206713.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从手卡把1只「DD」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,45206714)
	-- 为②效果设置发动代价：将墓地里的这张卡除外（通过aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c45206713.sptg)
	e2:SetOperation(c45206713.spop)
	c:RegisterEffect(e2)
end
-- 筛选可用的融合素材：必须是手卡怪兽且不免疫此效果，其中包括这张卡自身。
function c45206713.filter1(c,e)
	return c:IsLocation(LOCATION_HAND) and not c:IsImmuneToEffect(e)
end
-- 筛选符合条件的融合怪兽：必须是「DDD」融合怪兽，能够用当前素材组进行融合召唤，自身可被融合召唤，且有额外区域空格。
function c45206713.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x10af) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
		-- 检查玩家tp是否有可用的额外怪兽区域/融合召唤所需空格来特殊召唤融合怪兽c。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ①效果的发动条件部分：确认存在可作为融合素材的手卡怪兽（包含本卡）以及可融合召唤的「DDD」融合怪兽；若存在连锁素材则一并检查；满足后设置操作信息。
function c45206713.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 取得当前玩家可用于融合召唤的所有素材，并筛选出位于手卡的部分（因为①效果限定手卡的怪兽作为融合素材）。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_HAND)
		-- 检查额外卡组中是否存在满足条件的「DDD」融合怪兽（能用筛选出的手卡素材进行融合召唤，且能特殊召唤）。
		local res=Duel.IsExistingMatchingCard(c45206713.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取玩家tp所承受的“连锁素材”类效果（用于将额外卡组以外的卡也作为融合素材的替代条件）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材效果，则根据该效果提供的额外素材组再次检查是否存在可融合召唤的「DDD」融合怪兽。
				res=Duel.IsExistingMatchingCard(c45206713.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置效果处理时的操作信息：将进行1只额外卡组怪兽的特殊召唤（类别为特殊召唤/融合召唤），供相关卡检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理：根据选定的「DDD」融合怪兽，选择对应融合素材（必须包含本卡），将素材送去墓地，进行融合召唤；若有连锁素材效果介入，也可按该效果另行处理。
function c45206713.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 效果处理时重新取得当前可用的手卡融合素材，排除不受此效果影响的怪兽。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c45206713.filter1,nil,e)
	-- 使用普通融合素材（手卡怪兽）筛选出当前可以融合召唤的「DDD」融合怪兽列表。
	local sg1=Duel.GetMatchingGroup(c45206713.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果，以处理替代素材的情况。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材效果，则用其提供的替代素材组再次筛选可融合召唤的「DDD」融合怪兽列表。
		sg2=Duel.GetMatchingGroup(c45206713.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家显示“请选择要特殊召唤的卡”的提示，进入融合怪兽选择界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 如果选择的融合怪兽可以用普通素材召唤，且不存在连锁素材替代（或玩家选择不使用连锁素材效果），则走普通融合召唤流程；否则走连锁素材效果的处理流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从普通手卡素材中选择该融合怪兽所需的融合素材（其中必须包含这张卡）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地，作为融合召唤的素材。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的融合召唤特殊召唤不再与素材送去墓地视为同一时点处理（避免错过时点或连锁误判）。
			Duel.BreakEffect()
			-- 以融合召唤方式将选择的「DDD」融合怪兽表侧攻击表示特殊召唤到自己的场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材效果时，让玩家从连锁素材提供的素材中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 筛选可被②效果特殊召唤的「DD」怪兽：满足字段「DD」且能够被玩家正常特殊召唤。
function c45206713.spfilter(c,e,tp)
	return c:IsSetCard(0xaf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件：自己主要怪兽区有空位，且手卡中存在可特殊召唤的「DD」怪兽。
function c45206713.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认玩家自己场上有可用的主要怪兽区空格，否则无法特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手卡中存在至少1只满足条件的「DD」怪兽可以特殊召唤。
		and Duel.IsExistingMatchingCard(c45206713.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置②效果的操作信息：将从手卡特殊召唤1只怪兽（特殊召唤类别）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果处理：若场上仍有空格，选择手卡中1只「DD」怪兽，将其特殊召唤。
function c45206713.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区仍有空格，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示，然后进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只符合条件的「DD」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c45206713.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「DD」怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
