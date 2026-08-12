--地雷星トドロキ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把手卡1只其他怪兽送去墓地，从手卡特殊召唤。这个方法特殊召唤的这张卡的攻击力下降500。
-- ②：自己·对方的战斗阶段支付500基本分才能发动。从自己的手卡·场上把战士族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c30118701.initial_effect(c)
	-- ①：这张卡可以把手卡1只其他怪兽送去墓地，从手卡特殊召唤。这个方法特殊召唤的这张卡的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30118701,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,30118701+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c30118701.hspcon)
	e1:SetTarget(c30118701.hsptg)
	e1:SetOperation(c30118701.hspop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的战斗阶段支付500基本分才能发动。从自己的手卡·场上把战士族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30118701,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,30118702)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCondition(c30118701.spcon)
	e2:SetCost(c30118701.spcost)
	e2:SetTarget(c30118701.sptg)
	e2:SetOperation(c30118701.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否满足条件的怪兽（可送去墓地作为特殊召唤的代价）
function c30118701.hspcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 判断特殊召唤条件是否满足：场上是否有空位且手卡是否有可送去墓地的怪兽
function c30118701.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断手卡特殊召唤时，场上是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在满足条件的怪兽（可作为特殊召唤的代价）
		and Duel.IsExistingMatchingCard(c30118701.hspcfilter,tp,LOCATION_HAND,0,1,c)
end
-- 设置特殊召唤时的选择目标：选择要送去墓地的怪兽
function c30118701.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的怪兽组（用于选择送去墓地的怪兽）
	local g=Duel.GetMatchingGroup(c30118701.hspcfilter,tp,LOCATION_HAND,0,c)
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤后的处理：将选择的怪兽送去墓地，并给自身攻击力下降500的效果
function c30118701.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽送去墓地（作为特殊召唤的代价）
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	-- 给自身攻击力下降500的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 判断是否处于战斗阶段
function c30118701.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段在战斗阶段开始到战斗阶段结束之间
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
-- 支付500基本分的处理
function c30118701.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 过滤函数，用于判断怪兽是否免疫效果
function c30118701.spfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于判断是否为战士族融合怪兽且可特殊召唤
function c30118701.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_WARRIOR) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 设置融合召唤效果的目标处理：检查是否存在满足条件的融合怪兽
function c30118701.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c30118701.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足条件的融合怪兽（通过连锁效果获取的融合素材）
				res=Duel.IsExistingMatchingCard(c30118701.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置融合召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行融合召唤效果：选择融合怪兽并进行融合召唤
function c30118701.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 过滤融合素材中不免疫效果的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c30118701.spfilter1,nil,e)
	-- 获取满足条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c30118701.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足条件的融合怪兽组（通过连锁效果获取的融合素材）
		sg2=Duel.GetMatchingGroup(c30118701.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送去墓地（作为融合召唤的代价）
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 将融合怪兽从额外卡组特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合召唤所需的融合素材（通过连锁效果）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
