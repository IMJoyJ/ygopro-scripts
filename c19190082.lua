--戦乙女の戦車
-- 效果：
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只天使族怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
-- ②：装备怪兽的攻击宣言时才能发动。装备怪兽的攻击力上升500。
function c19190082.initial_effect(c)
	-- 为卡片注册联合怪兽机制，包括装备代替破坏、装备限制、装备发动和特殊召唤效果，装备对象需满足filter函数条件
	aux.EnableUnionAttribute(c,c19190082.filter)
	-- ②：装备怪兽的攻击宣言时才能发动。装备怪兽的攻击力上升500。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(19190082,2))
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c19190082.atkcon)
	e5:SetOperation(c19190082.atkop)
	c:RegisterEffect(e5)
end
-- 定义装备卡可装备到的怪兽必须满足的条件：怪兽必须是天使族
function c19190082.filter(c)
	return c:IsRace(RACE_FAIRY)
end
-- 判断是否满足效果发动条件：装备怪兽必须是当前攻击怪兽
function c19190082.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判断装备怪兽是否为当前攻击怪兽
	return ec and Duel.GetAttacker()==ec
end
-- 执行效果操作：为装备怪兽增加500点攻击力
function c19190082.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and c:IsRelateToEffect(e) then
		-- 装备怪兽的攻击力上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
	end
end
