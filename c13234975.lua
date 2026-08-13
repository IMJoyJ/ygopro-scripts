--騎甲虫隊上陸態勢
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从自己的手卡·场上把昆虫族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：从自己墓地把2只昆虫族怪兽除外才能发动。墓地的这张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c13234975.initial_effect(c)
	-- ①：从自己的手卡·场上把昆虫族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetDescription(aux.Stringid(13234975,0))  --"融合召唤"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c13234975.target)
	e1:SetOperation(c13234975.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：从自己墓地把2只昆虫族怪兽除外才能发动。墓地的这张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13234975,1))  --"这张卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,13234975)
	-- 设置②效果的发动条件，即这张卡送去墓地的回合不能发动（除非是作为连锁等特殊原因返回墓地）。
	e2:SetCondition(aux.exccon)
	e2:SetCost(c13234975.thcost)
	e2:SetTarget(c13234975.thtg)
	e2:SetOperation(c13234975.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否不免疫此效果，用于从可选融合素材中剔除不受该效果影响的卡。
function c13234975.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 筛选候选融合怪兽：必须是昆虫族融合怪兽，满足连锁素材等追加条件，可被融合召唤，且当前素材能满足其融合素材要求。
function c13234975.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_INSECT) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动时检测：检查能否从额外卡组选出可融合召唤的昆虫族融合怪兽，通常素材不行时再检测连锁素材；可行则登记特殊召唤操作信息。
function c13234975.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得玩家当前可用于融合召唤的素材组（手卡·场上怪兽以及受额外融合素材效果影响的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在至少1只符合filter2条件的昆虫族融合怪兽，其中融合素材使用通常素材组mg1。
		local res=Duel.IsExistingMatchingCard(c13234975.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家适用的连锁素材效果（若有），以便在通常素材不足时使用连锁素材提供的替代素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的素材组mg2及追加条件mf，再次检查额外卡组是否存在可融合召唤的昆虫族融合怪兽。
				res=Duel.IsExistingMatchingCard(c13234975.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记本次将进行特殊召唤的操作信息，使相关卡（如星尘龙、暴走魔法阵等）能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：实际执行融合召唤。从通常素材和连锁素材候选组中选择1只融合怪兽，并选择对应素材；通常素材则送去墓地后融合召唤，连锁素材则执行连锁素材效果的操作。
function c13234975.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 取得通常融合素材组，并过滤掉免疫此效果的卡，得到实际可用的素材组。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c13234975.filter1,nil,e)
	-- 使用可用素材组mg1筛选额外卡组中所有可融合召唤的昆虫族融合怪兽，形成候选组sg1。
	local sg1=Duel.GetMatchingGroup(c13234975.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果（若存在），用于扩展可选融合素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的素材组mg2及追加条件mf筛选额外卡组，形成候选组sg2。
		sg2=Duel.GetMatchingGroup(c13234975.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 弹出选择提示，让玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选的融合怪兽是否不属于连锁素材候选（或玩家选择不使用连锁素材），决定走通常融合流程还是连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从通常素材组mg1中选择该融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材从手卡·场上送去墓地，送墓原因为效果+融合素材。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使融合召唤的时点与效果处理分离，避免造成错时点。
			Duel.BreakEffect()
			-- 以融合召唤方式将融合怪兽表侧表示特殊召唤到玩家场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材组mg2中选择该融合怪兽所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2,SUMMON_TYPE_FUSION)
		end
		tc:CompleteProcedure()
	end
end
-- 代价过滤函数：筛选墓地中的昆虫族怪兽，要求是昆虫族且可以作为代价除外。
function c13234975.cfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价：从墓地选择2只昆虫族怪兽除外才能发动。
function c13234975.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在2只以上符合条件的昆虫族怪兽（自身除外）作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c13234975.cfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 弹出选择提示，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择2张符合条件的昆虫族怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c13234975.cfilter,tp,LOCATION_GRAVE,0,2,2,e:GetHandler())
	-- 将选择的卡表侧除外，除外原因为代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标判定：判断墓地的这张卡能否加入手卡，并登记回收操作信息。
function c13234975.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 登记将这张卡加入手卡的操作信息，用于后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联，则将其加入持有者手卡。
function c13234975.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡送去持有者手卡，原因为效果处理。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
