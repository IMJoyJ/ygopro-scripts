--混沌の夢魔鏡
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：「梦魔镜」融合怪兽卡决定的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。场地区域有「圣光之梦魔镜」存在的场合，手卡的怪兽也能作为融合素材。场地区域有「黯黑之梦魔镜」存在的场合，也能把自己墓地的怪兽除外作为融合素材。
function c98570539.initial_effect(c)
	-- 注册卡片关联密码，记录本卡记载了「圣光之梦魔镜」和「黯黑之梦魔镜」的卡名
	aux.AddCodeList(c,74665651,1050355)
	-- 这个卡名的卡在1回合只能发动1张。①：「梦魔镜」融合怪兽卡决定的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。场地区域有「圣光之梦魔镜」存在的场合，手卡的怪兽也能作为融合素材。场地区域有「黯黑之梦魔镜」存在的场合，也能把自己墓地的怪兽除外作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,98570539+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c98570539.target)
	e1:SetOperation(c98570539.activate)
	c:RegisterEffect(e1)
end
-- 过滤墓地中可以作为融合素材且能被除外的怪兽
function c98570539.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤不受当前效果影响的怪兽
function c98570539.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的「梦魔镜」融合怪兽
function c98570539.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x131) and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动的目标确认与合法性检测函数
function c98570539.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家场上可用的融合素材怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		local mg2=nil
		-- 检查场地区域是否存在「圣光之梦魔镜」
		if Duel.IsEnvironment(74665651,PLAYER_ALL,LOCATION_FZONE) then
			-- 获取玩家手牌中可用的融合素材怪兽
			mg2=Duel.GetFusionMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_HAND)
			mg1:Merge(mg2)
		end
		-- 检查场地区域是否存在「黯黑之梦魔镜」
		if Duel.IsEnvironment(1050355,PLAYER_ALL,LOCATION_FZONE) then
			-- 获取玩家墓地中满足条件的可用融合素材怪兽
			mg2=Duel.GetMatchingGroup(c98570539.filter0,tp,LOCATION_GRAVE,0,nil)
			mg1:Merge(mg2)
		end
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的「梦魔镜」融合怪兽
		local res=Duel.IsExistingMatchingCard(c98570539.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材效果提供的素材时，是否存在可融合召唤的「梦魔镜」融合怪兽
				res=Duel.IsExistingMatchingCard(c98570539.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息，表示将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置除外的操作信息，表示可能需要除外墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end
-- 效果处理（激活）函数
function c98570539.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取场上不受此卡效果影响以外的可用融合素材怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil):Filter(c98570539.filter1,nil,e)
	local mg2=nil
	-- 检查场地区域是否存在「圣光之梦魔镜」
	if Duel.IsEnvironment(74665651,PLAYER_ALL,LOCATION_FZONE) then
		-- 获取手牌中可用的融合素材怪兽
		mg2=Duel.GetFusionMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_HAND)
		mg1:Merge(mg2)
	end
	-- 检查场地区域是否存在「黯黑之梦魔镜」
	if Duel.IsEnvironment(1050355,PLAYER_ALL,LOCATION_FZONE) then
		-- 获取墓地中可作为融合素材且能被除外的怪兽
		mg2=Duel.GetMatchingGroup(c98570539.filter0,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
	end
	-- 获取额外卡组中可以使用当前素材进行融合召唤的「梦魔镜」融合怪兽集合
	local sg1=Duel.GetMatchingGroup(c98570539.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在使用连锁素材效果时，额外卡组中可融合召唤的「梦魔镜」融合怪兽集合
		sg2=Duel.GetMatchingGroup(c98570539.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式（而非连锁素材效果）进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家选择用于融合召唤该怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			local mat2=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			mat1:Sub(mat2)
			-- 将选定的非墓地融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 将选定的墓地融合素材表侧表示除外
			Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送去墓地/除外同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以表侧表示融合召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 玩家从连锁素材效果提供的素材中选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
