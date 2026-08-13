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
	-- 作为对象的怪兽不会被战斗破坏。
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
	-- ②：作为对象的怪兽和5星以上的对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。作为对象的怪兽的攻击力直到回合结束时上升这个效果破坏的怪兽的原本攻击力数值。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(42776855,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_START)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c42776855.atkcon)
	e5:SetOperation(c42776855.atkop)
	c:RegisterEffect(e5)
	-- ③：作为对象的怪兽从场上离开的场合这张卡破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCode(EVENT_LEAVE_FIELD)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCondition(c42776855.descon2)
	e7:SetOperation(c42776855.desop2)
	c:RegisterEffect(e7)
end
-- 筛选条件：表侧表示且为同调怪兽。
function c42776855.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 发动时选择自己场上1只表侧表示的同调怪兽作为对象：先检查合法性，再让玩家选择。
function c42776855.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42776855.filter(chkc) end
	-- 效果发动合法性检查：自己场上是否存在至少1只表侧表示的同调怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c42776855.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示，要求从表侧表示的卡中选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只符合条件的怪兽并设置为效果对象。
	Duel.SelectTarget(tp,c42776855.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 发动成功后，若卡和对象仍关联且对象表侧表示，则用SetCardTarget将该对象登记为持续对象，以便后续①②③效果持续追踪。
function c42776855.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这张卡发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 效果破坏免疫判定：当试图破坏的效果来自对方玩家（发动者与卡的控制者不同）时返回true，即不因对方效果被破坏。
function c42776855.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
-- ②发动条件：对象怪兽仍在怪兽区，且与对方1只表侧表示、等级5以上的怪兽进行战斗（伤害步骤开始时）。
function c42776855.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if not tc then return false end
	local bc=tc:GetBattleTarget()
	return tc:IsLocation(LOCATION_MZONE) and bc and bc:IsFaceup() and bc:IsLocation(LOCATION_MZONE) and bc:IsLevelAbove(5)
end
-- ②效果处理：破坏战斗的对方怪兽；若破坏成功，则以该怪兽的原本攻击力数值上升对象怪兽攻击力直到回合结束。
function c42776855.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if not tc then return false end
	local bc=tc:GetBattleTarget()
	local atk=bc:GetBaseAttack()
	-- 若战斗的对方怪兽仍与战斗相关、且被效果成功破坏、且为怪兽卡，则执行攻击力上升。
	if bc:IsRelateToBattle() and Duel.Destroy(bc,REASON_EFFECT)~=0 and bc:IsType(TYPE_MONSTER) then
		-- 作为对象的怪兽的攻击力直到回合结束时上升这个效果破坏的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ③条件：作为对象的怪兽从场上离开（出现在离场事件组中）。
function c42776855.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- ③处理：将这张卡自身破坏。
function c42776855.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将这张卡（追赶之翼）破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
