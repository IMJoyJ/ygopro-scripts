--ダイノルフィア・ドメイン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段，把基本分支付一半才能发动。从自己的手卡·卡组·场上把「恐啡肽狂龙」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：自己基本分是2000以下，对方把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。这个回合，对方的效果发生的对自己的效果伤害变成0。
function c26631975.initial_effect(c)
	-- 效果原文内容：①：自己·对方的主要阶段，把基本分支付一半才能发动。从自己的手卡·卡组·场上把「恐啡肽狂龙」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,26631975+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c26631975.condition)
	e1:SetCost(c26631975.cost)
	e1:SetTarget(c26631975.target)
	e1:SetOperation(c26631975.operation)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：自己基本分是2000以下，对方把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。这个回合，对方的效果发生的对自己的效果伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c26631975.cdcon)
	-- 效果作用：将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c26631975.cdop)
	c:RegisterEffect(e2)
end
-- 效果作用：判断是否处于主要阶段1或主要阶段2
function c26631975.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：自己·对方的主要阶段
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果作用：支付一半基本分作为费用
function c26631975.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果原文内容：把基本分支付一半才能发动
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 效果作用：过滤可作为融合素材的怪兽（怪兽卡、可作为融合素材、可送入墓地）
function c26631975.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 效果作用：过滤不受此效果影响的怪兽
function c26631975.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 效果作用：过滤可融合召唤的「恐啡肽狂龙」融合怪兽（融合怪兽、所属卡组、可特殊召唤、符合融合素材条件）
function c26631975.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x173) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果作用：判断是否可以发动此效果（检查是否有符合条件的融合怪兽）
function c26631975.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 效果作用：获取玩家当前可用的融合素材（手卡和场上的怪兽）
		local mg1=Duel.GetFusionMaterial(tp)
		-- 效果作用：获取玩家卡组中符合条件的怪兽（可作为融合素材、可送入墓地）
		local mg2=Duel.GetMatchingGroup(c26631975.filter0,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
		-- 效果作用：检查是否存在符合条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c26631975.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 效果作用：获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 效果作用：检查是否存在通过连锁效果获得的融合素材中符合条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c26631975.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 效果作用：设置连锁操作信息，表示将特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果作用：执行融合召唤操作
function c26631975.operation(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 效果作用：过滤当前可用的融合素材（排除受效果影响的怪兽）
	local mg1=Duel.GetFusionMaterial(tp):Filter(c26631975.filter1,nil,e)
	-- 效果作用：获取玩家卡组中符合条件的怪兽（可作为融合素材、可送入墓地）
	local mg2=Duel.GetMatchingGroup(c26631975.filter0,tp,LOCATION_DECK,0,nil)
	mg1:Merge(mg2)
	-- 效果作用：获取玩家额外卡组中符合条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c26631975.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 效果作用：获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 效果作用：获取通过连锁效果获得的融合怪兽
		sg2=Duel.GetMatchingGroup(c26631975.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 效果作用：提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 效果作用：判断是否使用原融合素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 效果作用：选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 效果作用：将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 效果作用：中断当前效果处理
			Duel.BreakEffect()
			-- 效果作用：将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 效果作用：选择融合召唤所需的融合素材（通过连锁效果）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 效果作用：判断是否满足发动条件（基本分≤2000且为对方发动效果）
function c26631975.cdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：自己基本分是2000以下，对方把魔法·陷阱·怪兽的效果发动时
	return Duel.GetLP(tp)<=2000 and rp==1-tp
end
-- 效果作用：设置效果伤害归零和不造成效果伤害
function c26631975.cdop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：设置效果伤害归零和不造成效果伤害
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c26631975.damval1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：注册效果伤害归零效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：注册不造成效果伤害效果
	Duel.RegisterEffect(e2,tp)
end
-- 效果作用：判断是否为效果伤害且伤害来源为对方
function c26631975.damval1(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetOwnerPlayer() then return 0
	else return val end
end
