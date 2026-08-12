--龍の鏡
-- 效果：
-- ①：从自己的场上·墓地把龙族融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。
function c71490127.initial_effect(c)
	-- ①：从自己的场上·墓地把龙族融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c71490127.target)
	e1:SetOperation(c71490127.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上且可以被除外的卡片（用于融合素材检测）
function c71490127.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
-- 过滤场上、可以被除外且不受当前效果影响的卡片（用于实际融合处理）
function c71490127.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的龙族融合怪兽
function c71490127.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤墓地中可以作为融合素材且可以被除外的怪兽卡
function c71490127.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 效果发动的合法性检测与操作信息设置（Target阶段）
function c71490127.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家场上可作为融合素材且能被除外的卡片组
		local mg1=Duel.GetFusionMaterial(tp):Filter(c71490127.filter0,nil)
		-- 获取玩家墓地中可作为融合素材且能被除外的怪兽卡片组
		local mg2=Duel.GetMatchingGroup(c71490127.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在可以使用上述素材进行融合召唤的龙族融合怪兽
		local res=Duel.IsExistingMatchingCard(c71490127.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材（如连锁物质）效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，是否存在可融合召唤的龙族融合怪兽
				res=Duel.IsExistingMatchingCard(c71490127.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息（从额外卡组特召1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置除外的操作信息（从场上或墓地除外卡片）
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果处理的执行逻辑（Activate阶段）
function c71490127.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家场上可作为融合素材、能被除外且不受当前效果影响的卡片组
	local mg1=Duel.GetFusionMaterial(tp):Filter(c71490127.filter1,nil,e)
	-- 获取玩家墓地中可作为融合素材且能被除外的怪兽卡片组
	local mg2=Duel.GetMatchingGroup(c71490127.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 获取额外卡组中可以使用上述素材融合召唤的龙族融合怪兽组
	local sg1=Duel.GetMatchingGroup(c71490127.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下，额外卡组中可融合召唤的龙族融合怪兽组
		sg2=Duel.GetMatchingGroup(c71490127.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡自身的效果进行融合召唤（而非连锁素材的效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择一组满足条件的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材怪兽表侧表示除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与除外同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式从额外卡组表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果下，让玩家选择一组满足条件的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
