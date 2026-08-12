--シャドール・ネフィリム
-- 效果：
-- 反转怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「影依」融合怪兽融合召唤。
-- ②：这张卡在墓地存在的场合才能发动。从自己的手卡·场上（表侧表示）把1张「影依」卡送去墓地，这张卡特殊召唤。
function c86938484.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要反转怪兽2只作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_FLIP),2,2)
	-- ①：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「影依」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86938484,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,86938484)
	e1:SetTarget(c86938484.sptg)
	e1:SetOperation(c86938484.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合才能发动。从自己的手卡·场上（表侧表示）把1张「影依」卡送去墓地，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86938484,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,86938485)
	e2:SetTarget(c86938484.sptg2)
	e2:SetOperation(c86938484.spop2)
	c:RegisterEffect(e2)
end
-- 过滤不受效果影响的怪兽
function c86938484.spfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤可以进行融合召唤的「影依」融合怪兽
function c86938484.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x9d) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的发动准备与可行性检查
function c86938484.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在可以使用当前融合素材进行融合召唤的「影依」融合怪兽
		local res=Duel.IsExistingMatchingCard(c86938484.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，是否存在可以融合召唤的「影依」融合怪兽
				res=Duel.IsExistingMatchingCard(c86938484.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置当前连锁的操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的处理
function c86938484.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取并过滤掉不受当前效果影响的可用融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c86938484.spfilter1,nil,e)
	-- 获取可以使用当前融合素材进行融合召唤的「影依」融合怪兽组
	local sg1=Duel.GetMatchingGroup(c86938484.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下可以融合召唤的「影依」融合怪兽组
		sg2=Duel.GetMatchingGroup(c86938484.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式（而非连锁素材效果）进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材作为融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理不与送去墓地同时进行
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果下，让玩家选择融合召唤所需的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤手卡或场上表侧表示的「影依」卡，且该卡送去墓地后能腾出怪兽区域
function c86938484.cfilter(c,tp)
	-- 检查卡片是否在手卡或场上表侧表示、是否为「影依」卡、是否能送去墓地，且该卡送去墓地后自身特殊召唤所需的怪兽区域是否足够
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsSetCard(0x9d) and c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>0
end
-- 墓地特殊召唤效果的发动准备与可行性检查
function c86938484.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手卡或场上（表侧表示）是否存在可以送去墓地的「影依」卡
		and Duel.IsExistingMatchingCard(c86938484.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
	-- 设置当前连锁的操作信息为将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 墓地特殊召唤效果的处理
function c86938484.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或场上（表侧表示）选择1张「影依」卡
	local tg=Duel.SelectMatchingCard(tp,c86938484.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	local c=e:GetHandler()
	local tc=tg:GetFirst()
	-- 将选定的卡送去墓地，并确认其已成功送去墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToEffect(e) then
		-- 将墓地的这张卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
