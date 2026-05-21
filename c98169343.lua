--トリックスター・キャロベイン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上的怪兽不存在的场合或者只有「淘气仙星」怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己的「淘气仙星」怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡送去墓地才能发动。那只自己怪兽的攻击力直到回合结束时上升那自身原本攻击力数值。
function c98169343.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合或者只有「淘气仙星」怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98169343,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,98169343)
	e1:SetCondition(c98169343.spcon)
	e1:SetTarget(c98169343.sptg)
	e1:SetOperation(c98169343.spop)
	c:RegisterEffect(e1)
	-- ②：自己的「淘气仙星」怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡送去墓地才能发动。那只自己怪兽的攻击力直到回合结束时上升那自身原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98169343,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1,98169343)
	e2:SetCondition(c98169343.atkcon)
	e2:SetCost(c98169343.atkcost)
	e2:SetOperation(c98169343.atkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：里侧表示怪兽或者非「淘气仙星」怪兽
function c98169343.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xfb)
end
-- 特殊召唤效果的发动条件：自己场上没有怪兽，或者只有表侧表示的「淘气仙星」怪兽
function c98169343.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在不满足条件的怪兽，若不存在则满足发动条件
	return not Duel.IsExistingMatchingCard(c98169343.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的发动准备：检查怪兽区域空位与自身是否可特殊召唤，并设置特殊召唤的操作信息
function c98169343.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示此连锁处理时将特殊召唤1张卡（自身）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：若自身仍存在于手卡，则将自身特殊召唤
function c98169343.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 攻击力上升效果的发动条件：在伤害步骤开始时到伤害计算前，自己的「淘气仙星」怪兽与对方怪兽进行战斗
function c98169343.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 限制只能在伤害步骤且未进行伤害计算时发动
	if ph~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取当前进行攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方的，则将目标怪兽设为被攻击的怪兽（即自己的怪兽）
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	-- 确认进行战斗的自己怪兽是表侧表示的「淘气仙星」怪兽，且对方有战斗对象（即必须是怪兽之间的战斗）
	return tc and tc:IsFaceup() and tc:IsSetCard(0xfb) and tc:IsRelateToBattle() and Duel.GetAttackTarget()~=nil
end
-- 攻击力上升效果的代价：将手卡的这张卡送去墓地
function c98169343.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 攻击力上升效果的处理：使进行战斗的自己怪兽的攻击力直到回合结束时上升其自身原本攻击力的数值
function c98169343.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(tp) then
		local atk=tc:GetBaseAttack()
		-- 那只自己怪兽的攻击力直到回合结束时上升那自身原本攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
