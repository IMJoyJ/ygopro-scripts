--EMバラード
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，自己的「娱乐伙伴」怪兽和对方的表侧表示怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽的攻击力下降600。
-- 【怪兽效果】
-- ①：自己的「娱乐伙伴」怪兽攻击的伤害计算后，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力下降那只「娱乐伙伴」怪兽的攻击力数值。
function c66768175.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己的「娱乐伙伴」怪兽和对方的表侧表示怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽的攻击力下降600。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c66768175.atkcon1)
	e1:SetOperation(c66768175.atkop1)
	c:RegisterEffect(e1)
	-- ①：自己的「娱乐伙伴」怪兽攻击的伤害计算后，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力下降那只「娱乐伙伴」怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c66768175.atkcon2)
	e2:SetTarget(c66768175.atktg2)
	e2:SetOperation(c66768175.atkop2)
	c:RegisterEffect(e2)
end
-- 判定是否满足自己的「娱乐伙伴」怪兽与对方表侧表示怪兽进行战斗的伤害步骤开始时这一条件，并记录对方怪兽
function c66768175.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 获取被攻击的怪兽
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then bc,tc=tc,bc end
	e:SetLabelObject(bc)
	return bc:IsFaceup() and tc:IsFaceup() and tc:IsSetCard(0x9f)
end
-- 执行灵摆效果，使进行战斗的对方表侧表示怪兽攻击力下降600
function c66768175.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsFaceup() and bc:IsControler(1-tp) then
		-- 那只对方怪兽的攻击力下降600。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
	end
end
-- 判定是否满足自己的「娱乐伙伴」怪兽进行攻击的伤害计算后这一条件
function c66768175.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽
	local a=Duel.GetAttacker()
	return a:IsControler(tp) and a:IsSetCard(0x9f)
end
-- 进行怪兽效果的对象选择与合法性检查
function c66768175.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 在效果发动时，检查对方场上是否存在可选为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 执行怪兽效果，使作为对象的对方怪兽攻击力下降进行攻击的「娱乐伙伴」怪兽的攻击力数值
function c66768175.atkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if a:IsFaceup() and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=math.max(0,a:GetAttack())
		-- 那只对方怪兽的攻击力下降那只「娱乐伙伴」怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
