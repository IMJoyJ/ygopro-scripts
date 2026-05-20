--天融星カイキ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，支付500基本分才能发动。从自己的手卡·场上把战士族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：对方回合，持有和原本攻击力不同攻击力的5星以上的战士族怪兽在自己场上存在的场合才能发动。这张卡从墓地特殊召唤。
function c60822251.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合，支付500基本分才能发动。从自己的手卡·场上把战士族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60822251,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,60822251)
	e1:SetCondition(c60822251.fuscon)
	e1:SetCost(c60822251.fuscost)
	e1:SetTarget(c60822251.fustg)
	e1:SetOperation(c60822251.fusop)
	c:RegisterEffect(e1)
	-- ②：对方回合，持有和原本攻击力不同攻击力的5星以上的战士族怪兽在自己场上存在的场合才能发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60822251,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,60822252)
	e2:SetCondition(c60822251.spcon)
	e2:SetTarget(c60822251.sptg)
	e2:SetOperation(c60822251.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：不在伤害步骤
function c60822251.fuscon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL
end
-- ①效果的Cost：支付500基本分
function c60822251.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 过滤函数：不受效果影响的卡片过滤
function c60822251.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：额外卡组中可以融合召唤的战士族融合怪兽
function c60822251.filter2(c,e,tp,m,f)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_WARRIOR) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,tp)
end
-- ①效果的发动准备：检查是否存在可融合召唤的怪兽并设置操作信息
function c60822251.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家手卡和场上的可用融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在可以使用当前素材融合召唤的战士族融合怪兽
		local res=Duel.IsExistingMatchingCard(c60822251.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil)
		if not res then
			-- 获取连锁素材效果（如连锁物质）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材效果时是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c60822251.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的处理：进行融合召唤
function c60822251.fusop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取不受此效果影响以外的可用融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c60822251.filter1,nil,e)
	-- 获取可以使用当前素材融合召唤的战士族融合怪兽组
	local sg1=Duel.GetMatchingGroup(c60822251.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在使用连锁素材效果时可融合召唤的战士族融合怪兽组
		sg2=Duel.GetMatchingGroup(c60822251.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,tp)
			tc:SetMaterial(mat1)
			-- 将融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断效果处理，使后续的特殊召唤不与送墓同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家选择连锁素材效果决定的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,tp)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤函数：自己场上表侧表示、5星以上、持有和原本攻击力不同攻击力的战士族怪兽
function c60822251.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)and c:IsLevelAbove(5) and not c:IsAttack(c:GetBaseAttack())
end
-- ②效果的发动条件：对方回合，且自己场上存在符合条件的怪兽
function c60822251.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合，且自己场上有怪兽存在
	return Duel.GetTurnPlayer()~=tp and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查自己场上是否存在持有和原本攻击力不同攻击力的5星以上战士族怪兽
		and Duel.IsExistingMatchingCard(c60822251.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的发动准备：检查怪兽区域空位及自身是否能特殊召唤
function c60822251.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：将墓地的这张卡特殊召唤
function c60822251.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
