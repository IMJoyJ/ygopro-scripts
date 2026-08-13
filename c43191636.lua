--竜影魚レイ・ブロント
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当通常召唤使用的再度召唤，这张卡当作效果怪兽使用并得到以下效果。
-- ●这张卡的原本攻击力变成2300。这张卡攻击的场合，战斗阶段结束时变成守备表示。直到下次的自己回合结束时这张卡不能把表示形式改变。
function c43191636.initial_effect(c)
	-- 为这张卡赋予二重怪兽属性，使其在墓地或场上表侧表示时当作通常怪兽使用，并允许通过再度召唤变为效果怪兽状态。
	aux.EnableDualAttribute(c)
	-- 这张卡的原本攻击力变成2300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置该效果的适用条件：仅当此卡处于再度召唤状态（即作为效果怪兽使用）时，原本攻击力变成2300的效果才适用。
	e1:SetCondition(aux.IsDualState)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(2300)
	c:RegisterEffect(e1)
	-- 这张卡攻击的场合，战斗阶段结束时变成守备表示。直到下次的自己回合结束时这张卡不能把表示形式改变。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c43191636.poscon)
	e2:SetOperation(c43191636.posop)
	c:RegisterEffect(e2)
end
-- 该效果的发动条件：此卡处于再度召唤状态，且本回合进行过攻击。
function c43191636.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDualState() and e:GetHandler():GetAttackedCount()>0
end
-- 处理战斗阶段结束时的效果：若此卡是攻击表示则变为表侧守备表示，并为此卡附加直到下次自己回合结束时不能改变表示形式的持续效果。
function c43191636.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡从攻击表示转变为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	-- 直到下次的自己回合结束时这张卡不能把表示形式改变。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,3)
	c:RegisterEffect(e1)
end
