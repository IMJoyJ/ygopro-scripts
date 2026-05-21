--ドタキャン
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。自己场上的怪兽全部变成守备表示。这张卡的发动后，直到回合结束时被战斗·效果破坏的自己场上的表侧表示的「娱乐伙伴」怪兽不去墓地回到持有者手卡。
function c95254840.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。自己场上的怪兽全部变成守备表示。这张卡的发动后，直到回合结束时被战斗·效果破坏的自己场上的表侧表示的「娱乐伙伴」怪兽不去墓地回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c95254840.condition)
	e1:SetTarget(c95254840.target)
	e1:SetOperation(c95254840.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件：对方怪兽的攻击宣言时
function c95254840.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前攻击怪兽的控制者是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤条件：自己场上表侧攻击表示且可以改变表示形式的怪兽
function c95254840.filter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- 定义效果发动的目标检查
function c95254840.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可以改变表示形式的攻击表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c95254840.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 定义效果处理：将自己场上的怪兽变成守备表示，并注册后续的破坏回手卡效果
function c95254840.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有可以改变表示形式的攻击表示怪兽
	local g=Duel.GetMatchingGroup(c95254840.filter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 将这些怪兽全部变成表侧守备表示
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时被战斗·效果破坏的自己场上的表侧表示的「娱乐伙伴」怪兽不去墓地回到持有者手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c95254840.rmtg)
		e1:SetValue(LOCATION_HAND)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 向全局注册该玩家的场上效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤条件：因战斗或效果破坏的「娱乐伙伴」怪兽
function c95254840.rmtg(e,c)
	return c:IsSetCard(0x9f) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
