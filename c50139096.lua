--破滅の天使ルイン
-- 效果：
-- 「世界不灭」降临。
-- ①：这张卡的卡名只要在手卡·场上存在当作「破灭之女神 露茵」使用。
-- ②：这张卡仪式召唤成功的场合发动。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ③：这张卡被送去墓地的场合，以自己场上1只仪式怪兽为对象才能发动。只要那只怪兽在自己场上表侧表示存在，在自己的仪式怪兽的攻击宣言时对方不能把卡的效果发动。
function c50139096.initial_effect(c)
	c:EnableReviveLimit()
	-- ②：这张卡仪式召唤成功的场合发动。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(aux.Stringid(50139096,0))
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c50139096.atkcon)
	e1:SetOperation(c50139096.atkop)
	c:RegisterEffect(e1)
	-- ③：这张卡被送去墓地的场合，以自己场上1只仪式怪兽为对象才能发动。只要那只怪兽在自己场上表侧表示存在，在自己的仪式怪兽的攻击宣言时对方不能把卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50139096,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(c50139096.target)
	e2:SetOperation(c50139096.operation)
	c:RegisterEffect(e2)
	-- 效果作用：使此卡在手牌和场上的时候视为「破灭之女神 露茵」使用
	aux.EnableChangeCode(c,46427957,LOCATION_MZONE+LOCATION_HAND)
end
-- 效果条件：判断此卡是否为仪式召唤成功
function c50139096.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果处理：若此卡在场上，则使其在本回合内可以额外攻击一次
function c50139096.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 效果作用：使此卡在同1次的战斗阶段中最多2次可以向怪兽攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数：筛选场上表侧表示的仪式怪兽
function c50139096.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL)
end
-- 选择目标：选择自己场上的1只表侧表示的仪式怪兽作为对象
function c50139096.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50139096.filter(chkc) end
	-- 条件判断：确认自己场上是否存在符合条件的仪式怪兽
	if chk==0 then return Duel.IsExistingTarget(c50139096.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示信息：提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择卡片：从自己场上选择一只表侧表示的仪式怪兽作为目标
	Duel.SelectTarget(tp,c50139096.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：若目标怪兽存在且表侧表示，则注册一个在攻击宣言时禁止对方发动卡的效果的持续效果
function c50139096.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标：获取当前连锁中被选中的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 效果作用：当自己的仪式怪兽进行攻击宣言时，禁止对方发动卡的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(c50139096.actcon)
		e1:SetOperation(c50139096.actop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(50139096,2))  --"「破灭之天使 露茵」效果适用中"
	end
end
-- 条件判断：确认攻击方是否为己方的仪式怪兽
function c50139096.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击者：获取当前正在攻击的卡片
	local ac=Duel.GetAttacker()
	return ac and ac:IsControler(tp) and ac:IsType(TYPE_RITUAL)
end
-- 效果处理：禁止对方在攻击宣言时发动卡的效果
function c50139096.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：禁止对方在攻击宣言时发动卡的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册效果：将该效果注册到全局环境中，使对方无法发动卡的效果
	Duel.RegisterEffect(e1,tp)
end
