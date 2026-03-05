--五月豹
-- 效果：
-- ①：手卡只有这1张卡的场合才能发动。这张卡特殊召唤。
-- ②：这张卡的①的效果特殊召唤的场合发动。这张卡的攻击力直到对方回合结束时变成2500。
-- ③：这张卡和对方怪兽进行战斗的场合，那次战斗发生的对对方的战斗伤害由自己代受。
-- ④：这张卡的战斗让自己受到伤害的场合发动。这张卡的攻击力变成0。那之后，自己基本分是2000以下的场合，这张卡的攻击力变成5000。
local s,id,o=GetID()
-- 创建并注册四个效果，分别对应卡片的①②③④效果
function s.initial_effect(c)
	-- ①：手卡只有这1张卡的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果特殊召唤的场合发动。这张卡的攻击力直到对方回合结束时变成2500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变攻击力"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡和对方怪兽进行战斗的场合，那次战斗发生的对对方的战斗伤害由自己代受。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.rfcon)
	c:RegisterEffect(e3)
	-- ④：这张卡的战斗让自己受到伤害的场合发动。这张卡的攻击力变成0。那之后，自己基本分是2000以下的场合，这张卡的攻击力变成5000。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"攻击力变成5000"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(s.atkcon2)
	e4:SetOperation(s.atkop2)
	c:RegisterEffect(e4)
end
-- 判断手卡是否只有这张卡且场上存在召唤区域
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断手卡是否只有这张卡
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==1
		-- 判断场上是否存在召唤区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 设置特殊召唤的处理目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为通过①效果特殊召唤
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 设置攻击力变为2500
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsAttack(2500) then
		-- 将攻击力设置为2500并设置重置条件
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(2500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
	end
end
-- 判断是否参与战斗
function s.rfcon(e)
	-- 判断是否参与战斗
	return Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil or Duel.GetAttackTarget()==e:GetHandler()
end
-- 判断是否为己方受到战斗伤害
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 处理战斗伤害后的攻击力变化
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsAttack(0) then
		-- 将攻击力设置为0并设置重置条件
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 判断是否在基本分低于等于2000时触发效果
		if c:IsAttack(0) and Duel.GetLP(tp)<=2000 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将攻击力设置为5000并设置重置条件
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_ATTACK_FINAL)
			e2:SetValue(5000)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e2)
		end
	end
end
