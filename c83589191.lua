--ライフハック
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成和对方基本分数值相同，这个回合对方受到的全部伤害变成一半。
-- ②：自己主要阶段把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成和自己基本分数值相同，这个回合对方受到的全部伤害变成一半。
function c83589191.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成和对方基本分数值相同，这个回合对方受到的全部伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83589191,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,83589191)
	-- 设置效果在伤害步骤中伤害计算前以外的时机才能发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c83589191.target)
	e1:SetOperation(c83589191.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成和自己基本分数值相同，这个回合对方受到的全部伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83589191,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,83589191+1)
	-- 把墓地的这张卡除外作为效果发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c83589191.atktg)
	e2:SetOperation(c83589191.atkop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示且攻击力不等于指定玩家基本分数值的怪兽
function c83589191.filter(c,tp)
	-- 判断怪兽是否表侧表示且攻击力不等于指定玩家的基本分
	return c:IsFaceup() and not c:IsAttack(Duel.GetLP(tp))
end
-- 效果①的发动准备与对象选择
function c83589191.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c83589191.filter(chkc,1-tp) end
	-- 判断场上是否存在可以作为效果①对象的怪兽（攻击力不等于对方基本分）
	if chk==0 then return Duel.IsExistingTarget(c83589191.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,1-tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,c83589191.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,1-tp)
end
-- 效果①的处理函数
function c83589191.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER)
		-- 判断对象怪兽是否不受该效果影响且攻击力不等于对方基本分
		and not tc:IsImmuneToEffect(e) and not tc:IsAttack(Duel.GetLP(1-tp)) then
		-- 那只怪兽的攻击力直到回合结束时变成和对方基本分数值相同
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		-- 设置攻击力变化数值为对方当前的生命值
		e1:SetValue(Duel.GetLP(1-tp))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个回合对方受到的全部伤害变成一半。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CHANGE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(0,1)
		e2:SetValue(c83589191.damval)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 向全局环境注册该回合对方受到的全部伤害变成一半的效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 效果②的发动准备与对象选择
function c83589191.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c83589191.filter(chkc,tp) end
	-- 判断场上是否存在可以作为效果②对象的怪兽（攻击力不等于自己基本分）
	if chk==0 then return Duel.IsExistingTarget(c83589191.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,c83589191.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
end
-- 效果②的处理函数
function c83589191.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果②选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER)
		-- 判断对象怪兽是否不受该效果影响且攻击力不等于自己基本分
		and not tc:IsImmuneToEffect(e) and not tc:IsAttack(Duel.GetLP(tp)) then
		-- 那只怪兽的攻击力直到回合结束时变成和自己基本分数值相同
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		-- 设置攻击力变化数值为自己当前的生命值
		e1:SetValue(Duel.GetLP(tp))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个回合对方受到的全部伤害变成一半。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CHANGE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(0,1)
		e2:SetValue(c83589191.damval)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 向全局环境注册该回合对方受到的全部伤害变成一半的效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 计算减半伤害的辅助函数
function c83589191.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end
