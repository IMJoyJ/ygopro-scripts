--合体竜ティマイオス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从自己的手卡·场上（表侧表示）把1只魔法师族怪兽或者1张有「黑魔术师」的卡名记述的魔法·陷阱卡送去墓地才能发动。这张卡特殊召唤。
-- ②：自己主要阶段才能发动。包含魔法师族怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
function c3078380.initial_effect(c)
	-- 注册此卡效果文本中记载着黑魔术师（卡号46986414）的事实
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
-- 过滤函数，用于判断是否满足①效果的cost条件，即：手牌或场上表侧表示的怪兽或含黑魔术师的魔法陷阱卡，且有可用怪兽区，且能送入墓地
function c3078380.cfilter(c,tp)
	-- 判断目标是否为手牌或场上表侧表示的卡，且有可用怪兽区，且能送入墓地
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGraveAsCost()
		-- 判断目标是否为魔法师族怪兽或含黑魔术师的魔法陷阱卡
		and (c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_MONSTER) or aux.IsCodeListed(c,46986414) and c:IsType(TYPE_SPELL+TYPE_TRAP))
end
-- ①效果的cost处理，选择满足条件的1张卡送入墓地
function c3078380.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足①效果的cost条件
	if chk==0 then return Duel.IsExistingMatchingCard(c3078380.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c3078380.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选中的卡送去墓地作为cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的发动处理，判断是否能特殊召唤
function c3078380.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的发动处理，执行特殊召唤
function c3078380.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于判断是否免疫效果
function c3078380.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于判断是否为融合怪兽且满足特殊召唤条件
function c3078380.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤时的额外检查函数，判断是否有魔法师族怪兽作为融合素材
function c3078380.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsRace,1,nil,RACE_SPELLCASTER)
end
-- ②效果的发动处理，判断是否有满足条件的融合怪兽可融合召唤
function c3078380.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 设置融合召唤时的额外检查函数
		aux.FCheckAdditional=c3078380.fcheck
		-- 检查是否有满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c3078380.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若连锁存在，则检查是否有满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c3078380.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 取消设置融合召唤时的额外检查函数
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置操作信息，表示将融合召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的发动处理，执行融合召唤
function c3078380.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材并过滤掉免疫效果的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(c3078380.filter1,nil,e)
	-- 设置融合召唤时的额外检查函数
	aux.FCheckAdditional=c3078380.fcheck
	-- 获取满足融合召唤条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c3078380.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若连锁存在，则获取满足条件的融合怪兽
		sg2=Duel.GetMatchingGroup(c3078380.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用第一组融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择第二组融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 取消设置融合召唤时的额外检查函数
	aux.FCheckAdditional=nil
end
