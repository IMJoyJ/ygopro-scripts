--EMバラクーダ
-- 效果：
-- ←5 【灵摆】 5→
-- ①：1回合1次，自己的「娱乐伙伴」怪兽和对方怪兽进行战斗的伤害计算前才能发动。那只对方怪兽的攻击力下降和那个原本攻击力的相差数值。
-- 【怪兽效果】
-- 「娱乐伙伴 凶猛蔷薇」的怪兽效果1回合只能使用1次。
-- ①：以持有和原本攻击力不同攻击力的1只「娱乐伙伴」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升和那个原本攻击力的相差数值。这个效果在对方回合也能发动。
function c92767273.initial_effect(c)
	-- 添加灵摆怪兽的基本属性（灵摆召唤、灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己的「娱乐伙伴」怪兽和对方怪兽进行战斗的伤害计算前才能发动。那只对方怪兽的攻击力下降和那个原本攻击力的相差数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92767273,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c92767273.atkcon1)
	e1:SetOperation(c92767273.atkop1)
	c:RegisterEffect(e1)
	-- 「娱乐伙伴 凶猛蔷薇」的怪兽效果1回合只能使用1次。①：以持有和原本攻击力不同攻击力的1只「娱乐伙伴」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升和那个原本攻击力的相差数值。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92767273,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,92767273)
	-- 设置效果在伤害步骤中仅在伤害计算前可以发动
	e2:SetCondition(aux.dscon)
	e2:SetTarget(c92767273.atktg2)
	e2:SetOperation(c92767273.atkop2)
	c:RegisterEffect(e2)
end
-- 判定是否为自己的「娱乐伙伴」怪兽与当前攻击力与原本攻击力不同的对方怪兽进行战斗
function c92767273.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 获取被攻击的怪兽
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then bc,tc=tc,bc end
	e:SetLabelObject(bc)
	return bc:IsFaceup() and tc:IsFaceup() and tc:IsSetCard(0x9f) and bc:GetBaseAttack()~=bc:GetAttack()
end
-- 使进行战斗的对方怪兽的攻击力下降其当前攻击力与原本攻击力的差值
function c92767273.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsFaceup() and bc:IsControler(1-tp) then
		local diff=math.abs(bc:GetBaseAttack()-bc:GetAttack())
		-- 那只对方怪兽的攻击力下降和那个原本攻击力的相差数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-diff)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
	end
end
-- 过滤场上表侧表示、属于「娱乐伙伴」且当前攻击力与原本攻击力不同的怪兽
function c92767273.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f) and c:GetBaseAttack()~=c:GetAttack()
end
-- 选择1只持有和原本攻击力不同攻击力的「娱乐伙伴」怪兽作为效果对象
function c92767273.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c92767273.atkfilter(chkc) end
	-- 检查自己场上是否存在符合条件的「娱乐伙伴」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c92767273.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 选择自己场上1只符合条件的「娱乐伙伴」怪兽作为效果对象
	Duel.SelectTarget(tp,c92767273.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 使目标怪兽的攻击力直到回合结束时上升其当前攻击力与原本攻击力的差值
function c92767273.atkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local diff=math.abs(tc:GetBaseAttack()-tc:GetAttack())
		-- 那只怪兽的攻击力直到回合结束时上升和那个原本攻击力的相差数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(diff)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
