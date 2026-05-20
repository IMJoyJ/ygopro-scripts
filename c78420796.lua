--ダイノルフィア・フレンジー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方主要阶段，把基本分支付一半才能发动。「恐啡肽狂龙」融合怪兽卡决定的融合素材怪兽从卡组以及额外卡组各1只送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：自己基本分是2000以下，对方把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。这个回合，对方的效果发生的对自己的效果伤害变成0。
function c78420796.initial_effect(c)
	-- ①：对方主要阶段，把基本分支付一半才能发动。「恐啡肽狂龙」融合怪兽卡决定的融合素材怪兽从卡组以及额外卡组各1只送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,78420796+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c78420796.condition)
	e1:SetCost(c78420796.cost)
	e1:SetTarget(c78420796.target)
	e1:SetOperation(c78420796.operation)
	c:RegisterEffect(e1)
	-- ②：自己基本分是2000以下，对方把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。这个回合，对方的效果发生的对自己的效果伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c78420796.cdcon)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c78420796.cdop)
	c:RegisterEffect(e2)
end
-- 限制在对方的主要阶段才能发动
function c78420796.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合的主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()==1-tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 支付一半基本分作为发动的代价
function c78420796.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 玩家支付当前基本分一半的数值
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 过滤可以作为融合素材且能送去墓地的怪兽卡
function c78420796.filter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 过滤额外卡组中可以进行融合召唤的「恐啡肽狂龙」融合怪兽
function c78420796.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x173) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合素材检查函数，用于验证素材是否分别来自卡组和额外卡组
function c78420796.fcheck(tp,sg,fc)
	-- 检查选取的2张融合素材是否分别存在于卡组和额外卡组
	return aux.gfcheck(sg,Card.IsLocation,LOCATION_DECK,LOCATION_EXTRA)
end
-- 限制融合素材的数量最多为2张
function c78420796.gcheck(sg)
	return #sg<=2
end
-- 检查是否存在可融合召唤的怪兽，并设置送去墓地和特殊召唤的操作信息
function c78420796.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取卡组及额外卡组中所有满足条件的融合素材怪兽
		local mg1=Duel.GetMatchingGroup(c78420796.filter1,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
		-- 设定融合素材位置的额外检查函数（卡组和额外卡组各1张）
		aux.FGoalCheckAdditional=c78420796.fcheck
		-- 设定融合素材数量的额外检查函数（最多2张）
		aux.GCheckAdditional=c78420796.gcheck
		-- 检查额外卡组是否存在可以使用上述素材进行融合召唤的「恐啡肽狂龙」融合怪兽
		local res=Duel.IsExistingMatchingCard(c78420796.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在连锁素材效果存在时，检查是否能使用其提供的素材进行融合召唤
				res=Duel.IsExistingMatchingCard(c78420796.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 清除融合素材位置的额外检查函数
		aux.FGoalCheckAdditional=nil
		-- 清除融合素材数量的额外检查函数
		aux.GCheckAdditional=nil
		return res
	end
	-- 设置将卡组和额外卡组各1张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK+LOCATION_EXTRA)
	-- 设置从额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行融合召唤效果，将素材送去墓地并特殊召唤融合怪兽
function c78420796.operation(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取卡组及额外卡组中所有满足条件的融合素材怪兽
	local mg1=Duel.GetMatchingGroup(c78420796.filter1,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
	-- 设定融合素材位置的额外检查函数（卡组和额外卡组各1张）
	aux.FGoalCheckAdditional=c78420796.fcheck
	-- 设定融合素材数量的额外检查函数（最多2张）
	aux.GCheckAdditional=c78420796.gcheck
	-- 筛选出当前素材可以融合召唤的「恐啡肽狂龙」融合怪兽组
	local sg1=Duel.GetMatchingGroup(c78420796.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 筛选出使用连锁素材效果可以融合召唤的「恐啡肽狂龙」融合怪兽组
		sg2=Duel.GetMatchingGroup(c78420796.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡自身的效果进行融合召唤（若不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从卡组和额外卡组中选择该融合怪兽所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材作为融合素材因效果送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤不与送去墓地同时处理
			Duel.BreakEffect()
			-- 将选定的融合怪兽从额外卡组进行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材效果提供的素材组选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清除融合素材位置的额外检查函数
	aux.FGoalCheckAdditional=nil
	-- 清除融合素材数量的额外检查函数
	aux.GCheckAdditional=nil
end
-- 检查是否满足墓地效果的发动条件（自己基本分2000以下且对方发动效果）
function c78420796.cdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己基本分是否在2000以下，且当前发动效果的玩家为对方
	return Duel.GetLP(tp)<=2000 and rp==1-tp
end
-- 注册使本回合对方效果造成的伤害变成0的效果
function c78420796.cdop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方的效果发生的对自己的效果伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c78420796.damval1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册将效果伤害变为0的玩家效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册免疫效果伤害的玩家效果
	Duel.RegisterEffect(e2,tp)
end
-- 伤害计算过滤函数，若伤害来源为对方的效果，则将伤害数值修改为0
function c78420796.damval1(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetOwnerPlayer() then return 0
	else return val end
end
