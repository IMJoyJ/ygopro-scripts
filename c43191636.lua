--竜影魚レイ・ブロント
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当通常召唤使用的再度召唤，这张卡当作效果怪兽使用并得到以下效果。
-- ●这张卡的原本攻击力变成2300。这张卡攻击的场合，战斗阶段结束时变成守备表示。直到下次的自己回合结束时这张卡不能把表示形式改变。
function c43191636.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- 这张卡的原本攻击力变成2300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 效果适用条件为该卡处于再度召唤状态
	e1:SetCondition(aux.IsDualState)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(2300)
	c:RegisterEffect(e1)
	-- 战斗阶段结束时，这张卡攻击的场合，战斗阶段结束时变成守备表示。直到下次的自己回合结束时这张卡不能把表示形式改变
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c43191636.poscon)
	e2:SetOperation(c43191636.posop)
	c:RegisterEffect(e2)
end
-- 判断是否为再度召唤状态且本回合有进行过攻击
function c43191636.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDualState() and e:GetHandler():GetAttackedCount()>0
end
-- 若为攻击表示则变更为守备表示，并设置在接下来的三个阶段结束前不能改变表示形式
function c43191636.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将目标怪兽变为守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	-- 直到下次的自己回合结束时这张卡不能把表示形式改变
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,3)
	c:RegisterEffect(e1)
end
