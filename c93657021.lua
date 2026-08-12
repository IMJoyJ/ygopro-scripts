--D-HERO ダスクユートピアガイ
-- 效果：
-- 「命运英雄」融合怪兽＋「命运英雄」怪兽
-- ①：这张卡融合召唤成功的场合才能发动。从自己的手卡·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：1回合1次，以场上1只怪兽为对象才能发动。这个回合，那只怪兽不会被战斗·效果破坏，那只怪兽的战斗发生的双方的战斗伤害变成0。这个效果在对方回合也能发动。
function c93657021.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：需要1只「命运英雄」融合怪兽和1只「命运英雄」怪兽作为融合素材
	aux.AddFusionProcFun2(c,c93657021.matfilter,aux.FilterBoolFunction(Card.IsFusionSetCard,0xc008),true)
	-- ①：这张卡融合召唤成功的场合才能发动。从自己的手卡·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93657021,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c93657021.spcon)
	e1:SetTarget(c93657021.sptg)
	e1:SetOperation(c93657021.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以场上1只怪兽为对象才能发动。这个回合，那只怪兽不会被战斗·效果破坏，那只怪兽的战斗发生的双方的战斗伤害变成0。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93657021,1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(c93657021.indtg)
	e2:SetOperation(c93657021.indop)
	c:RegisterEffect(e2)
end
c93657021.material_setcode=0xc008
-- 融合素材过滤：融合怪兽且是「命运英雄」怪兽
function c93657021.matfilter(c)
	return c:IsFusionType(TYPE_FUSION) and c:IsFusionSetCard(0xc008)
end
-- 效果①的发动条件：这张卡融合召唤成功
function c93657021.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤不受当前效果影响的卡片
function c93657021.spfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的融合怪兽
function c93657021.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果①的发动准备：检查是否存在可融合召唤的怪兽，并设置特殊召唤的操作信息
function c93657021.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材卡片组
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在可以使用当前常规融合素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(c93657021.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果下，额外卡组是否存在可以使用其素材进行融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c93657021.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理：选择1只额外卡组的融合怪兽，将其融合素材送去墓地并进行融合召唤
function c93657021.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材，并过滤掉不受此效果影响的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(c93657021.spfilter1,nil,e)
	-- 获取额外卡组中可以使用当前常规素材融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(c93657021.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下，额外卡组中可以融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(c93657021.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（若不使用连锁素材效果，或玩家选择不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤目标怪兽的常规融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材因效果·素材·融合原因送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送去墓地同时处理
			Duel.BreakEffect()
			-- 将选定的融合怪兽以融合召唤的方式特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家选择用于连锁素材效果融合召唤的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 效果②的发动准备：选择场上1只怪兽作为对象
function c93657021.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择场上1只怪兽作为效果对象
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果②的效果处理：使目标怪兽在这个回合获得不会被战斗·效果破坏以及双方战斗伤害变成0的效果
function c93657021.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的发动对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽不会被战斗...破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		tc:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		tc:RegisterEffect(e4)
	end
end
