--ジェムナイト・フュージョン
-- 效果：
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只「宝石骑士」融合怪兽融合召唤。
-- ②：这张卡在墓地存在的场合，从自己墓地把1只「宝石骑士」怪兽除外才能发动。这张卡加入手卡。
function c1264319.initial_effect(c)
	-- ①：自己的手卡·场上的怪兽作为融合素材，把1只「宝石骑士」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1264319,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1264319.target)
	e1:SetOperation(c1264319.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从自己墓地把1只「宝石骑士」怪兽除外才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetDescription(aux.Stringid(1264319,1))  --"加入手卡"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c1264319.thcost)
	e2:SetTarget(c1264319.thtg)
	e2:SetOperation(c1264319.thop)
	c:RegisterEffect(e2)
end
-- 过滤融合素材：排除免疫此效果的卡，确保素材不受该效果影响且可作为融合素材。
function c1264319.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 筛选额外卡组中符合条件的「宝石骑士」融合怪兽：必须为融合怪兽、属于「宝石骑士」字段、满足额外素材效果的限制、可被融合召唤，且能用当前素材组构成融合素材。
function c1264319.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1047) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动时的目标判定：检查是否存在可融合召唤的「宝石骑士」融合怪兽，分别考虑通常素材和连锁素材；若存在则登记特殊召唤操作信息。
function c1264319.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取当前玩家可用的融合素材组（手卡·场上的怪兽及受额外融合素材效果影响的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 在额外卡组中检查是否存在至少1只可用通常素材作为融合素材来融合召唤的「宝石骑士」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c1264319.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家受到的连锁素材效果（若有）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的素材组和附加条件，再次检查额外卡组中是否存在可融合召唤的「宝石骑士」融合怪兽。
				res=Duel.IsExistingMatchingCard(c1264319.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记本次效果将进行特殊召唤（从额外卡组特殊召唤1只怪兽）的操作信息，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从可选的素材组和可融合召唤的「宝石骑士」融合怪兽中选择1只；若使用通常素材则选择素材送墓并融合召唤，若使用连锁素材则按连锁素材效果处理。
function c1264319.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取可用的融合素材组，并排除免疫此效果的卡，得到实际可用的通常素材组。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c1264319.filter1,nil,e)
	-- 使用通常素材组在额外卡组中筛选出所有可融合召唤的「宝石骑士」融合怪兽，作为候选。
	local sg1=Duel.GetMatchingGroup(c1264319.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前玩家受到的连锁素材效果（若有）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材的素材组和条件，在额外卡组中筛选出可融合召唤的「宝石骑士」融合怪兽，作为另一组候选。
		sg2=Duel.GetMatchingGroup(c1264319.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选择的融合怪兽是否只能/优先使用通常素材召唤；若也能用连锁素材召唤则询问玩家是否使用连锁素材。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从通常素材组中选择融合召唤所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送去墓地，作为融合召唤的素材（原因包含效果、素材、融合）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续特殊召唤视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以表侧表示进行融合召唤特殊召唤到己方场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材效果提供的素材组中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 墓地中可作为除外代价的「宝石骑士」怪兽的过滤条件。
function c1264319.thfilter(c)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：从自己墓地除外1只「宝石骑士」怪兽，作为发动此效果的代价。
function c1264319.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在至少1只符合除外的「宝石骑士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c1264319.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只墓地中的「宝石骑士」怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c1264319.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 目标判定：确认墓地中的这张卡本身能加入手卡，并登记回手牌操作信息。
function c1264319.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 登记将这张卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果相关，则将其加入持有者手卡，并向对方展示。
function c1264319.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入其持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家展示这张卡，确认已加入手卡。
		Duel.ConfirmCards(1-tp,c)
	end
end
