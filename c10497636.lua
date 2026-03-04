--ウォークライ・メテオラゴン
-- 效果：
-- ①：这张卡不会被对方的效果破坏。
-- ②：这张卡和对方怪兽进行战斗的攻击宣言时才能发动。这个回合，那只对方怪兽以及原本卡名和那只对方怪兽相同的怪兽的效果无效化。
-- ③：1回合1次，自己的战士族·地属性怪兽进行过战斗的自己·对方的战斗阶段才能发动。自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
function c10497636.initial_effect(c)
	-- 效果原文：①：这张卡不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	-- 规则层面：设置该卡不会被对方效果破坏
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡和对方怪兽进行战斗的攻击宣言时才能发动。这个回合，那只对方怪兽以及原本卡名和那只对方怪兽相同的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10497636,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c10497636.discon)
	e2:SetTarget(c10497636.distg)
	e2:SetOperation(c10497636.disop)
	c:RegisterEffect(e2)
	-- 效果原文：③：1回合1次，自己的战士族·地属性怪兽进行过战斗的自己·对方的战斗阶段才能发动。自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10497636,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetCondition(c10497636.atkcon)
	e3:SetTarget(c10497636.atktg)
	e3:SetOperation(c10497636.atkop)
	c:RegisterEffect(e3)
	if not c10497636.global_check then
		c10497636.global_check=true
		-- 效果原文：（全局效果注册）
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_CONFIRM)
		ge1:SetOperation(c10497636.checkop)
		-- 规则层面：将全局效果注册到玩家0
		Duel.RegisterEffect(ge1,0)
	end
end
-- 规则层面：定义检查怪兽是否为战士族地属性的函数
function c10497636.check(c)
	return c and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 规则层面：定义战斗确认时的处理函数
function c10497636.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前战斗中的两只怪兽
	local c0,c1=Duel.GetBattleMonster(0)
	if c10497636.check(c0) then
		-- 规则层面：为玩家0注册标识效果
		Duel.RegisterFlagEffect(0,10497636,RESET_PHASE+PHASE_END,0,1)
	end
	if c10497636.check(c1) then
		-- 规则层面：为玩家1注册标识效果
		Duel.RegisterFlagEffect(1,10497636,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 规则层面：定义效果发动条件函数
function c10497636.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=c:GetBattleTarget()
	e:SetLabelObject(ac)
	return ac and ac:IsFaceup() and ac:IsControler(1-tp)
end
-- 规则层面：定义效果目标函数
function c10497636.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ac=e:GetLabelObject()
	if chk==0 then return true end
	-- 规则层面：设置操作信息为使目标怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,ac,1,0,0)
end
-- 规则层面：定义效果处理函数
function c10497636.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=e:GetLabelObject()
	if ac:IsFaceup() and ac:IsRelateToBattle() and ac:IsCanBeDisabledByEffect(e) and ac:IsControler(1-tp) then
		-- 效果原文：使目标怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ac:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		ac:RegisterEffect(e2)
		-- 效果原文：使与目标怪兽卡名相同的怪兽效果无效
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e3:SetTarget(c10497636.distg2)
		e3:SetLabelObject(ac)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 规则层面：将效果注册给玩家
		Duel.RegisterEffect(e3,tp)
		-- 效果原文：（持续效果）
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_CHAIN_SOLVING)
		e4:SetCondition(c10497636.discon2)
		e4:SetOperation(c10497636.disop2)
		e4:SetLabelObject(ac)
		e4:SetReset(RESET_PHASE+PHASE_END)
		-- 规则层面：将效果注册给玩家
		Duel.RegisterEffect(e4,tp)
	end
end
-- 规则层面：定义目标怪兽卡名匹配函数
function c10497636.distg2(e,c)
	local ac=e:GetLabelObject()
	return c:IsOriginalCodeRule(ac:GetOriginalCodeRule())
end
-- 规则层面：定义连锁处理条件函数
function c10497636.discon2(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabelObject()
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsOriginalCodeRule(ac:GetOriginalCodeRule())
end
-- 规则层面：定义连锁处理函数
function c10497636.disop2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：使连锁效果无效
	Duel.NegateEffect(ev)
end
-- 规则层面：定义攻击力提升效果发动条件函数
function c10497636.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：检查玩家是否已注册标识效果
	return Duel.GetFlagEffect(tp,10497636)>0
		-- 规则层面：检查当前阶段是否为战斗阶段
		and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 规则层面：定义攻击力提升效果适用的怪兽过滤函数
function c10497636.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15f)
end
-- 规则层面：定义攻击力提升效果目标函数
function c10497636.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10497636.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 规则层面：定义攻击力提升效果处理函数
function c10497636.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面：获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c10497636.atkfilter,tp,LOCATION_MZONE,0,nil)
	-- 规则层面：遍历怪兽组
	for tc in aux.Next(g) do
		-- 效果原文：使场上所有「战吼」怪兽攻击力上升200
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		e1:SetValue(200)
		tc:RegisterEffect(e1)
	end
	if c:IsRelateToEffect(e) then
		-- 效果原文：使这张卡在同1次战斗阶段中最多可以攻击2次
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
