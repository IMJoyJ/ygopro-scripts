--幻影融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上把「英雄」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。自己的魔法与陷阱区域有融合素材怪兽当作永续陷阱卡使用而存在的场合，也能把那怪兽卡除外作为融合素材（最多2张）。
function c57425061.initial_effect(c)
	-- ①：从自己的手卡·场上把「英雄」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。自己的魔法与陷阱区域有融合素材怪兽当作永续陷阱卡使用而存在的场合，也能把那怪兽卡除外作为融合素材（最多2张）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,57425061+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c57425061.target)
	e1:SetOperation(c57425061.activate)
	c:RegisterEffect(e1)
end
-- 过滤在魔法与陷阱区域表侧表示存在、原本是怪兽卡且当作永续陷阱卡使用的卡片
function c57425061.cfilter(c)
	return c:IsFaceup() and c:GetSequence()<5
		and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER
end
-- 过滤可以送去墓地且不受当前效果影响的卡片
function c57425061.filter1(c,e)
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
-- 过滤在魔法与陷阱区域当作永续陷阱卡使用、可以作为融合素材且可以除外的卡片（用于可行性检查）
function c57425061.exfilter0(c)
	return c57425061.cfilter(c) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤在魔法与陷阱区域当作永续陷阱卡使用、可以作为融合素材、可以除外且不受当前效果影响的卡片（用于效果处理）
function c57425061.exfilter1(c,e)
	return c57425061.cfilter(c) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的「英雄」融合怪兽
function c57425061.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x8) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 限制从魔法与陷阱区域选择的融合素材数量最多为2张
function c57425061.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_SZONE)<=2
end
-- 限制融合素材组中来自魔法与陷阱区域的卡片数量最多为2张
function c57425061.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_SZONE)<=2
end
-- 效果发动的可行性检查与操作信息注册
function c57425061.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材中可以送去墓地的卡片组
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsAbleToGrave,nil)
		-- 检查自己的魔法与陷阱区域是否存在当作永续陷阱卡使用的怪兽卡
		if Duel.IsExistingMatchingCard(c57425061.cfilter,tp,LOCATION_SZONE,0,1,nil) then
			-- 获取自己的魔法与陷阱区域中可以除外作为融合素材的卡片组
			local sg=Duel.GetMatchingGroup(c57425061.exfilter0,tp,LOCATION_SZONE,0,nil)
			if sg:GetCount()>0 then
				mg1:Merge(sg)
				-- 设置融合素材检查的附加条件（限制魔陷区素材最多2张）
				aux.FCheckAdditional=c57425061.fcheck
				-- 设置融合素材组检查的附加条件（限制魔陷区素材最多2张）
				aux.GCheckAdditional=c57425061.gcheck
			end
		end
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的「英雄」怪兽
		local res=Duel.IsExistingMatchingCard(c57425061.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 重置融合素材检查的附加条件
		aux.FCheckAdditional=nil
		-- 重置融合素材组检查的附加条件
		aux.GCheckAdditional=nil
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果下是否存在可以融合召唤的「英雄」怪兽
				res=Duel.IsExistingMatchingCard(c57425061.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果处理的操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的处理
function c57425061.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材中可以送去墓地且不受当前效果影响的卡片组
	local mg1=Duel.GetFusionMaterial(tp):Filter(c57425061.filter1,nil,e)
	local exmat=false
	-- 检查自己的魔法与陷阱区域是否存在当作永续陷阱卡使用的怪兽卡
	if Duel.IsExistingMatchingCard(c57425061.cfilter,tp,LOCATION_SZONE,0,1,nil) then
		-- 获取自己的魔法与陷阱区域中可以除外作为融合素材且不受当前效果影响的卡片组
		local sg=Duel.GetMatchingGroup(c57425061.exfilter1,tp,LOCATION_SZONE,0,nil,e)
		if sg:GetCount()>0 then
			mg1:Merge(sg)
			exmat=true
		end
	end
	if exmat then
		-- 设置融合素材检查的附加条件（限制魔陷区素材最多2张）
		aux.FCheckAdditional=c57425061.fcheck
		-- 设置融合素材组检查的附加条件（限制魔陷区素材最多2张）
		aux.GCheckAdditional=c57425061.gcheck
	end
	-- 获取额外卡组中可以使用当前素材进行融合召唤的「英雄」怪兽组
	local sg1=Duel.GetMatchingGroup(c57425061.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 重置融合素材检查的附加条件
	aux.FCheckAdditional=nil
	-- 重置融合素材组检查的附加条件
	aux.GCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以融合召唤的「英雄」怪兽组
		sg2=Duel.GetMatchingGroup(c57425061.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		-- 判断是否使用本卡的效果进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 设置融合素材检查的附加条件（限制魔陷区素材最多2张）
				aux.FCheckAdditional=c57425061.fcheck
				-- 设置融合素材组检查的附加条件（限制魔陷区素材最多2张）
				aux.GCheckAdditional=c57425061.gcheck
			end
			-- 玩家选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 重置融合素材检查的附加条件
			aux.FCheckAdditional=nil
			-- 重置融合素材组检查的附加条件
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			local rg=mat1:Filter(Card.IsLocation,nil,LOCATION_SZONE)
			mat1:Sub(rg)
			-- 将除魔法与陷阱区域以外的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 将来自魔法与陷阱区域的融合素材除外
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理不与送去墓地/除外同时处理
			Duel.BreakEffect()
			-- 将融合怪兽从额外卡组融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 玩家在连锁素材等效果下选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
