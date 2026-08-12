--EMシルバー・クロウ
-- 效果：
-- ←5 【灵摆】 5→
-- ①：自己场上的「娱乐伙伴」怪兽的攻击力上升300。
-- 【怪兽效果】
-- ①：这张卡的攻击宣言时发动。自己场上的「娱乐伙伴」怪兽的攻击力直到战斗阶段结束时上升300。
function c26270847.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- 自己场上的「娱乐伙伴」怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c26270847.atktg)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 这张卡的攻击宣言时发动。自己场上的「娱乐伙伴」怪兽的攻击力直到战斗阶段结束时上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26270847,0))  --"攻击上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetTarget(c26270847.target)
	e3:SetOperation(c26270847.operation)
	c:RegisterEffect(e3)
end
-- 判断目标怪兽是否为「娱乐伙伴」系列怪兽
function c26270847.atktg(e,c)
	return c:IsSetCard(0x9f)
end
-- 过滤出场上表侧表示的「娱乐伙伴」系列怪兽
function c26270847.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 检查场上是否存在至少1只表侧表示的「娱乐伙伴」系列怪兽
function c26270847.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若场上存在至少1只表侧表示的「娱乐伙伴」系列怪兽则发动效果
	if chk==0 then return Duel.IsExistingMatchingCard(c26270847.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 将场上所有表侧表示的「娱乐伙伴」系列怪兽攻击力上升300
function c26270847.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示的「娱乐伙伴」系列怪兽组成group
	local g=Duel.GetMatchingGroup(c26270847.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 给目标怪兽添加攻击力上升300的效果，持续到战斗阶段结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
