--EM小判竜
-- 效果：
-- ←5 【灵摆】 5→
-- ①：1回合1次，以从额外卡组特殊召唤的自己场上1只龙族怪兽为对象才能发动。这个回合，那只自己怪兽和对方怪兽进行战斗的场合，那只对方怪兽在伤害计算后除外。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，这张卡以外的自己场上的龙族怪兽攻击力上升500，不会被效果破坏。
function c9000988.initial_effect(c)
	-- 启用灵摆怪兽属性（注册灵摆召唤及灵摆卡的发动等基本规则）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以从额外卡组特殊召唤的自己场上1只龙族怪兽为对象才能发动。这个回合，那只自己怪兽和对方怪兽进行战斗的场合，那只对方怪兽在伤害计算后除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9000988,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c9000988.condition)
	e1:SetTarget(c9000988.target)
	e1:SetOperation(c9000988.operation)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，这张卡以外的自己场上的龙族怪兽攻击力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c9000988.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 灵摆效果发动条件判定
function c9000988.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否能进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 过滤条件：表侧表示且是龙族且从额外卡组特殊召唤的怪兽
function c9000988.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 灵摆效果发动时的目标选择与合法性检查
function c9000988.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c9000988.filter(chkc) end
	-- 判定场上是否存在满足条件的龙族怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c9000988.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只从额外卡组特殊召唤的龙族怪兽作为效果对象
	Duel.SelectTarget(tp,c9000988.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 灵摆效果的执行：为目标怪兽注册战斗后除外对方怪兽的效果
function c9000988.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只自己怪兽和对方怪兽进行战斗的场合，那只对方怪兽在伤害计算后除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLED)
		e1:SetOwnerPlayer(tp)
		e1:SetCondition(c9000988.rmcon)
		e1:SetOperation(c9000988.rmop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
-- 除外效果的发动条件判定：对象怪兽与对方怪兽进行战斗
function c9000988.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tp==e:GetOwnerPlayer() and tc and tc:IsControler(1-tp)
end
-- 除外效果的执行：将进行战斗的对方怪兽除外
function c9000988.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	-- 将进行战斗的对方怪兽表侧表示除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
-- 怪兽效果作用对象过滤：这张卡以外的自己场上的龙族怪兽
function c9000988.atktg(e,c)
	return c:IsRace(RACE_DRAGON) and c~=e:GetHandler()
end
