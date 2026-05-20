--大融合
-- 效果：
-- ①：从自己的手卡·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果融合召唤的场合，融合素材怪兽必须是3只以上。这个效果特殊召唤的怪兽得到以下效果。
-- ●这张卡不会被效果破坏。
-- ●这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c7614732.initial_effect(c)
	-- ①：从自己的手卡·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果融合召唤的场合，融合素材怪兽必须是3只以上。这个效果特殊召唤的怪兽得到以下效果。●这张卡不会被效果破坏。●这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c7614732.target)
	e1:SetOperation(c7614732.activate)
	c:RegisterEffect(e1)
end
-- 过滤额外卡组中可以进行融合召唤的怪兽
function c7614732.filter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 检查融合素材数量是否满足3只以上的条件
function c7614732.fcheck(tp,sg,fc)
	return sg:GetCount()>=3
end
-- 效果发动的目标确认与合法性检测
function c7614732.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上的融合素材，并过滤掉不受效果影响的卡
		local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
		-- 设定融合素材数量必须在3只以上的额外校验函数
		aux.FGoalCheckAdditional=c7614732.fcheck
		-- 检查额外卡组中是否存在可以使用当前素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(c7614732.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，是否存在可以融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c7614732.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 清除融合素材数量的额外校验函数
		aux.FGoalCheckAdditional=nil
		return res
	end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的执行函数，进行融合素材的选择、送去墓地以及融合召唤
function c7614732.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 获取玩家手卡和场上的融合素材，并过滤掉不受效果影响的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	-- 设定融合素材数量必须在3只以上的额外校验函数
	aux.FGoalCheckAdditional=c7614732.fcheck
	-- 获取额外卡组中可以使用当前素材进行融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(c7614732.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下，可以融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(c7614732.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		local res=false
		-- 判断是否使用常规融合方式（而非连锁素材的效果）进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择满足条件的融合素材（必须是3只以上）
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理不与送去墓地视为同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式正面表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			res=true
		else
			-- 在连锁素材效果下，让玩家选择满足条件的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
			res=true
		end
		if res then
			tc:CompleteProcedure()
			-- ●这张卡不会被效果破坏。
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- ●这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
			local e2=Effect.CreateEffect(tc)
			e2:SetDescription(aux.Stringid(7614732,0))  --"「大融合」效果融合召唤"
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_PIERCE)
			e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
			if not tc:IsType(TYPE_EFFECT) then
				-- 这个效果特殊召唤的怪兽得到以下效果。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_ADD_TYPE)
				e3:SetValue(TYPE_EFFECT)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e3,true)
			end
		end
	end
	-- 清除融合素材数量的额外校验函数
	aux.FGoalCheckAdditional=nil
end
