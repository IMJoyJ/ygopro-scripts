--EMシルバー・クロウ
-- 效果：
-- ←5 【灵摆】 5→
-- ①：自己场上的「娱乐伙伴」怪兽的攻击力上升300。
-- 【怪兽效果】
-- ①：这张卡的攻击宣言时发动。自己场上的「娱乐伙伴」怪兽的攻击力直到战斗阶段结束时上升300。
function c26270847.initial_effect(c)
	-- 为这张卡启用灵摆怪兽属性，使其可以作为灵摆怪兽进行灵摆召唤，并能在灵摆区域发动灵摆卡。
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的「娱乐伙伴」怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c26270847.atktg)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击宣言时发动。自己场上的「娱乐伙伴」怪兽的攻击力直到战斗阶段结束时上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26270847,0))  --"攻击上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetTarget(c26270847.target)
	e3:SetOperation(c26270847.operation)
	c:RegisterEffect(e3)
end
-- 灵摆攻击力上升效果的适用对象筛选：判断卡片是否持有「娱乐伙伴」字段（setname=0x9f），用于确定哪些「娱乐伙伴」怪兽获得攻击力上升。
function c26270847.atktg(e,c)
	return c:IsSetCard(0x9f)
end
-- 效果处理时的过滤条件：选择自己场上表侧表示且持有「娱乐伙伴」字段的怪兽，作为后续攻击力上升的适用对象。
function c26270847.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- e3的发动条件检测函数：在攻击宣言触发时，检查自己场上是否存在至少1只表侧表示且持有「娱乐伙伴」字段的怪兽，若存在则效果可以发动。
function c26270847.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性判定（chk==0）时，通过Duel.IsExistingMatchingCard确认自己场上存在符合条件的怪兽，以此作为效果可发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c26270847.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：取得自己场上所有表侧表示且持有「娱乐伙伴」字段的怪兽，为每只怪兽单独赋予一个攻击力+300的永续效果，该效果持续到战斗阶段结束，且不会被无效化。
function c26270847.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示且持有「娱乐伙伴」字段的怪兽，存入组g，作为之后逐个附加攻击力上升效果的对象集合。
	local g=Duel.GetMatchingGroup(c26270847.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的「娱乐伙伴」怪兽的攻击力直到战斗阶段结束时上升300。
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
