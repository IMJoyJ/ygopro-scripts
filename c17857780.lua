--EMチアモール
-- 效果：
-- ←5 【灵摆】 5→
-- ①：自己场上的灵摆怪兽的攻击力上升300。
-- 【怪兽效果】
-- 「娱乐伙伴 啦啦队鼹鼠」的怪兽效果1回合只能使用1次。
-- ①：自己主要阶段以持有和原本攻击力不同攻击力的1只怪兽为对象才能发动。那只怪兽的攻击力数值的以下效果适用。
-- ●那只怪兽的攻击力比原本攻击力高的场合，那只怪兽的攻击力上升1000。
-- ●那只怪兽的攻击力比原本攻击力低的场合，那只怪兽的攻击力下降1000。
function c17857780.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的灵摆怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c17857780.atktg)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- ①：自己主要阶段以持有和原本攻击力不同攻击力的1只怪兽为对象才能发动。那只怪兽的攻击力数值的以下效果适用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17857780,0))  --"攻守变化"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,17857780)
	e3:SetTarget(c17857780.target)
	e3:SetOperation(c17857780.operation)
	c:RegisterEffect(e3)
end
-- 判断目标是否为灵摆怪兽，用于筛选符合条件的灵摆怪兽
function c17857780.atktg(e,c)
	return c:IsType(TYPE_PENDULUM)
end
-- 判断目标是否为表侧表示且攻击力与原本攻击力不同，用于筛选符合条件的怪兽
function c17857780.filter(c)
	return c:IsFaceup() and not c:IsAttack(c:GetBaseAttack())
end
-- 设置效果的目标为满足条件的怪兽，用于选择目标怪兽
function c17857780.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c17857780.filter(chkc) end
	-- 检查是否有满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c17857780.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c17857780.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 执行效果操作，根据目标怪兽攻击力与原本攻击力的差异调整其攻击力
function c17857780.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		local batk=tc:GetBaseAttack()
		if atk==batk then return end
		-- 根据目标怪兽攻击力与原本攻击力的差异，为其添加攻击力变化效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		if atk>batk then
			e1:SetValue(1000)
		else
			e1:SetValue(-1000)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
