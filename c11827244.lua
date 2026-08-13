--円融魔術
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的场上·墓地的怪兽作为融合素材除外，把1只魔法师族融合怪兽融合召唤。
function c11827244.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的场上·墓地的怪兽作为融合素材除外，把1只魔法师族融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,11827244+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c11827244.target)
	e1:SetOperation(c11827244.activate)
	c:RegisterEffect(e1)
end
-- 判断怪兽是否在场上且可以被除外，用于筛选场上可作为融合素材的怪兽（发动时合法性检查用，不免疫检测）。
function c11827244.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
-- 判断怪兽是否在场上、可被除外且不免疫此效果，用于实际效果处理时筛选场上素材，避免选择不受该效果影响的卡。
function c11827244.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 筛选额外卡组中可作为融合召唤对象的魔法师族融合怪兽，要求其能够以给定的素材组m进行融合召唤，并能被效果以融合召唤方式特殊召唤。
function c11827244.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_SPELLCASTER) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 筛选墓地中可作为融合素材且可被除外的怪兽，用于补充融合素材组。
function c11827244.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 效果发动时的合法性检查和操作信息设置：检查自己场上·墓地素材能否融合召唤魔法师族融合怪兽（含连锁素材情况），若合法则设置特殊召唤和除外的操作信息。
function c11827244.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己场上可作为融合素材且可被除外的怪兽（来自常规融合素材区域）。
		local mg1=Duel.GetFusionMaterial(tp):Filter(c11827244.filter0,nil)
		-- 获取自己墓地中可作为融合素材且可被除外的怪兽。
		local mg2=Duel.GetMatchingGroup(c11827244.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在可用当前素材（场上+墓地）融合召唤的魔法师族融合怪兽。
		local res=Duel.IsExistingMatchingCard(c11827244.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家可用的连锁素材效果（如《沼地的魔神王》等），用于扩展融合素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查使用连锁素材提供的素材时，额外卡组是否仍存在可融合召唤的魔法师族融合怪兽。
				res=Duel.IsExistingMatchingCard(c11827244.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本效果将进行1次特殊召唤，对象为额外卡组的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：本效果将除外场上·墓地的卡（作为融合素材）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果处理时的实际操作：根据可用的常规素材和连锁素材，选择要融合召唤的魔法师族融合怪兽，选择融合素材并除外，然后进行融合召唤。
function c11827244.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取自己场上可作为融合素材、可被除外且不免疫此效果的怪兽。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c11827244.filter1,nil,e)
	-- 获取自己墓地中可作为融合素材且可被除外的怪兽。
	local mg2=Duel.GetMatchingGroup(c11827244.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 获取额外卡组中所有能够用场上·墓地素材融合召唤的魔法师族融合怪兽。
	local sg1=Duel.GetMatchingGroup(c11827244.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前玩家可用的连锁素材效果，用于后续扩展素材组。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取额外卡组中所有能够用连锁素材提供的素材融合召唤的魔法师族融合怪兽。
		sg2=Duel.GetMatchingGroup(c11827244.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 弹出选择提示，让玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否走常规融合流程：若选择的怪兽能用常规素材融合召唤，或虽能用连锁素材但玩家选择不使用连锁素材，则执行常规融合；否则执行连锁素材融合。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从常规可用素材中选择该融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材以表侧表示除外，作为融合召唤的素材。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使素材除外的处理与后续融合怪兽的特殊召唤分开处理，避免错失时点。
			Duel.BreakEffect()
			-- 将选择的魔法师族融合怪兽以融合召唤方式特殊召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材提供的素材中选择该融合怪兽所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
