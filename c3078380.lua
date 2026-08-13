--合体竜ティマイオス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从自己的手卡·场上（表侧表示）把1只魔法师族怪兽或者1张有「黑魔术师」的卡名记述的魔法·陷阱卡送去墓地才能发动。这张卡特殊召唤。
-- ②：自己主要阶段才能发动。包含魔法师族怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
function c3078380.initial_effect(c)
	-- 注册本卡卡名记述信息：记录本卡文本中记载了「黑魔术师」（46986414），便于后续判断“有「黑魔术师」的卡名记述的魔法·陷阱卡”。
	aux.AddCodeList(c,46986414)
	-- ①：这张卡在手卡存在的场合，从自己的手卡·场上（表侧表示）把1只魔法师族怪兽或者1张有「黑魔术师」的卡名记述的魔法·陷阱卡送去墓地才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3078380,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,3078380)
	e1:SetCost(c3078380.spcost)
	e1:SetTarget(c3078380.sptg)
	e1:SetOperation(c3078380.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。包含魔法师族怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3078380,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,3078381)
	e2:SetTarget(c3078380.fsptg)
	e2:SetOperation(c3078380.fspop)
	c:RegisterEffect(e2)
end
-- 定义①效果的代价筛选函数：候选卡须为手牌或场上表侧表示，送墓后自己场上仍有空位且可作为代价送墓；且必须是魔法师族怪兽，或记载有「黑魔术师」卡名的魔法·陷阱卡。
function c3078380.cfilter(c,tp)
	-- 检查候选卡位于手牌或场上表侧表示，将其送墓后自己场上有可用怪兽区，并且该卡能作为代价送去墓地。
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGraveAsCost()
		-- 检查候选卡的种类限定：满足魔法师族怪兽，或满足记载有「黑魔术师」卡名的魔法·陷阱卡。
		and (c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_MONSTER) or aux.IsCodeListed(c,46986414) and c:IsType(TYPE_SPELL+TYPE_TRAP))
end
-- 定义①效果的发动代价：确认存在合法素材后，提示玩家选择1张满足条件的卡，并将其送去墓地作为代价。
function c3078380.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：若处于check阶段，返回是否存在至少1张符合条件的卡可作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c3078380.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
	-- 向玩家发送选择提示，提示文案为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的手牌或场上选择1张满足cfilter条件的卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c3078380.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将所选的代价卡送去墓地，送墓理由为REASON_COST（代价）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义①效果发动时的目标判定：确认这张卡能够被特殊召唤，并设置特殊召唤的操作信息。
function c3078380.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：表示本次效果将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义①效果处理：若发动效果的本卡仍与此效果关联，则将其特殊召唤上场。
function c3078380.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到其持有者场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义融合素材过滤：拥有对此效果免疫的卡不能作为融合素材。
function c3078380.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 定义融合怪兽候选过滤：候选必须是融合怪兽，满足额外限制（如f），能够以融合召唤方式特殊召唤，且用给定素材能达成融合。
function c3078380.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 定义额外的融合素材限制：所选择的融合素材组中必须至少包含1只魔法师族怪兽。
function c3078380.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsRace,1,nil,RACE_SPELLCASTER)
end
-- 定义②效果的发动目标检查：确认额外卡组存在能用自己可用素材融合召唤且包含魔法师族怪兽的融合怪兽。
function c3078380.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的通常融合素材组（手牌·场上的怪兽，以及受额外融合素材效果影响的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 设置额外的融合素材合法性检查函数为fcheck，强制素材组中必须包含魔法师族怪兽。
		aux.FCheckAdditional=c3078380.fcheck
		-- 使用通常素材组在额外卡组中检索是否存在可融合召唤的融合怪兽。
		local res=Duel.IsExistingMatchingCard(c3078380.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如可以代替融合素材的效果），用于扩展素材范围。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若通常素材无法满足，则使用连锁素材提供的素材组再次检查额外卡组是否存在可融合召唤的融合怪兽。
				res=Duel.IsExistingMatchingCard(c3078380.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 清除额外的融合素材检查函数，避免影响后续其他效果。
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置操作信息：本次效果将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义②效果处理：从可用的融合怪兽候选中选择1只，选择相应素材，将其送去墓地并进行融合召唤；若使用连锁素材则按其效果处理。
function c3078380.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材组，并过滤掉对本次效果免疫的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c3078380.filter1,nil,e)
	-- 设置额外的融合素材合法性检查函数为fcheck，强制素材组中必须包含魔法师族怪兽。
	aux.FCheckAdditional=c3078380.fcheck
	-- 用通常素材组获取所有可融合召唤的融合怪兽候选。
	local sg1=Duel.GetMatchingGroup(c3078380.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的素材组获取所有可融合召唤的融合怪兽候选。
		sg2=Duel.GetMatchingGroup(c3078380.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家发送选择提示，提示文案为“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选中的融合怪兽：如果可用通常素材融合，并且（没有连锁素材或玩家选择不使用连锁素材），则执行通常融合流程；否则执行连锁素材融合流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从通常素材组中选择满足该融合怪兽所需的一组融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地，理由为效果+作为融合素材。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使接下来的融合召唤单独视为一次特殊召唤处理，避免时点合并。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式表侧表示特殊召唤到玩家场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁素材提供的素材组中选择满足该融合怪兽所需的一组融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清除额外的融合素材检查函数，避免影响后续其他效果。
	aux.FCheckAdditional=nil
end
