--幻惑の眼
-- 效果：
-- ①：自己场上有幻想魔族或魔法师族的怪兽存在的场合，可以从以下效果选择1个发动。
-- ●这个回合中，自己的幻想魔族·魔法师族怪兽不会被战斗破坏。
-- ●对方回合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
-- ●对方怪兽的攻击宣言时，以攻击怪兽以外的对方场上1只表侧表示怪兽为对象才能发动。攻击对象转移为那只怪兽进行伤害计算。
local s,id,o=GetID()
-- 注册卡牌的初始效果，设置为发动时点的自由连锁效果
function s.initial_effect(c)
	-- ①：自己场上有幻想魔族或魔法师族的怪兽存在的场合，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否有幻想魔族或魔法师族的表侧表示怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER)
end
-- 判断条件函数，检查自己场上是否存在幻想魔族或魔法师族的怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的卡片组，检查自己场上是否存在至少1张幻想魔族或魔法师族的表侧表示怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示且可以改变控制权
function s.tfilter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 效果处理的目标选择函数，根据选择的效果类型设置不同的目标选择逻辑
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击怪兽
	local a=Duel.GetAttacker()
	if chkc then
		local f={false,s.tfilter(chkc),chkc:IsFaceup() and chkc~=a}
		return f[e:GetLabel()] and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
	end
	if chk==0 then return true end
	-- 判断当前回合玩家是否为对方
	local b2=Duel.GetTurnPlayer()==1-tp
		-- 检查对方场上是否存在至少1只可以改变控制权的表侧表示怪兽
		and Duel.IsExistingTarget(s.tfilter,tp,0,LOCATION_MZONE,1,nil)
	-- 判断当前回合玩家是否为对方
	local b3=Duel.GetTurnPlayer()==1-tp
		-- 检查当前是否为攻击宣言时点
		and Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE)
		-- 检查对方场上是否存在至少1只表侧表示怪兽作为攻击对象
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,a)
	local op=aux.SelectFromOptions(tp,{true,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)},{b3,aux.Stringid(id,3)})  --"不会被战斗破坏/得到控制权/攻击对象转移"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
		e:SetProperty(0)
	elseif op==2 then
		e:SetCategory(CATEGORY_CONTROL)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 选择对方场上1只表侧表示怪兽作为控制权变更的目标
		local g=Duel.SelectTarget(tp,s.tfilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置连锁操作信息，记录将要改变控制权的怪兽
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择对方场上1只表侧表示怪兽作为攻击对象转移的目标
		Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,a)
	end
end
-- 效果处理的执行函数，根据选择的效果类型调用不同的处理函数
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		s.protect(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.control(e,tp,eg,ep,ev,re,r,rp)
	elseif op==3 then
		s.tattack(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 设置永续效果，使自己的幻想魔族或魔法师族怪兽不会被战斗破坏
function s.protect(e,tp,eg,ep,ev,re,r,rp)
	-- ●这个回合中，自己的幻想魔族·魔法师族怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果的目标范围为所有主要怪兽区的幻想魔族或魔法师族怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ILLUSION+RACE_SPELLCASTER))
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 将效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
end
-- 控制权变更效果的处理函数，使目标怪兽的控制权转移给发动者
function s.control(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽存在且与效果相关，则将其控制权转移给发动者直到结束阶段
	if tc and tc:IsRelateToEffect(e) then Duel.GetControl(tc,tp,PHASE_END,1) end
end
-- 攻击对象转移效果的处理函数，使攻击怪兽的攻击对象转移为指定怪兽并进行伤害计算
function s.tattack(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and a:IsAttackable() and not a:IsImmuneToEffect(e) then
		-- 令攻击怪兽与目标怪兽进行战斗伤害计算
		Duel.CalculateDamage(a,tc)
	end
end
