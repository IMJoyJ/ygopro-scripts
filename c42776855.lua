--追走の翼
-- 效果：
-- 以自己场上1只同调怪兽为对象才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，作为对象的怪兽不会被战斗以及对方的效果破坏。
-- ②：作为对象的怪兽和5星以上的对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。作为对象的怪兽的攻击力直到回合结束时上升这个效果破坏的怪兽的原本攻击力数值。
-- ③：作为对象的怪兽从场上离开的场合这张卡破坏。
function c42776855.initial_effect(c)
	-- 以自己场上1只同调怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c42776855.target)
	e1:SetOperation(c42776855.tgop)
	c:RegisterEffect(e1)
	-- 只要这张卡在魔法与陷阱区域存在，作为对象的怪兽不会被战斗以及对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(c42776855.efilter)
	c:RegisterEffect(e4)
	-- 作为对象的怪兽和5星以上的对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。作为对象的怪兽的攻击力直到回合结束时上升这个效果破坏的怪兽的原本攻击力数值。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(42776855,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_START)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c42776855.atkcon)
	e5:SetOperation(c42776855.atkop)
	c:RegisterEffect(e5)
	-- 作为对象的怪兽从场上离开的场合这张卡破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCode(EVENT_LEAVE_FIELD)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCondition(c42776855.descon2)
	e7:SetOperation(c42776855.desop2)
	c:RegisterEffect(e7)
end
-- 筛选场上表侧表示的同调怪兽
function c42776855.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 选择场上1只表侧表示的同调怪兽作为对象
function c42776855.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42776855.filter(chkc) end
	-- 判断是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c42776855.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的同调怪兽作为对象
	Duel.SelectTarget(tp,c42776855.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将选择的怪兽设置为效果对象
function c42776855.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判断效果是否由对方发动
function c42776855.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
-- 判断是否满足发动条件：对象怪兽与5星以上怪兽战斗
function c42776855.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if not tc then return false end
	local bc=tc:GetBattleTarget()
	return tc:IsLocation(LOCATION_MZONE) and bc and bc:IsFaceup() and bc:IsLocation(LOCATION_MZONE) and bc:IsLevelAbove(5)
end
-- 发动效果：破坏对方怪兽并提升对象怪兽攻击力
function c42776855.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if not tc then return false end
	local bc=tc:GetBattleTarget()
	local atk=bc:GetBaseAttack()
	-- 判断对方怪兽是否在战斗阶段且可被破坏
	if bc:IsRelateToBattle() and Duel.Destroy(bc,REASON_EFFECT)~=0 and bc:IsType(TYPE_MONSTER) then
		-- 使对象怪兽的攻击力上升
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判断对象怪兽是否离开场上的条件
function c42776855.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 发动效果：破坏自身
function c42776855.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
