--ゴブリン突撃部隊
-- 效果：
-- ①：这张卡攻击的场合，战斗阶段结束时变成守备表示，直到下次的自己回合的结束时不能把表示形式变更。
function c78658564.initial_effect(c)
	-- ①：这张卡攻击的场合，战斗阶段结束时变成守备表示，直到下次的自己回合的结束时不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c78658564.poscon)
	e1:SetOperation(c78658564.posop)
	c:RegisterEffect(e1)
end
-- 检查这张卡在本回合是否进行过攻击，作为效果发动的条件
function c78658564.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 在战斗阶段结束时，若这张卡是攻击表示则变更为表侧守备表示，并使其直到下次自己回合结束时不能变更表示形式
function c78658564.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡变更为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	-- 直到下次的自己回合的结束时不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,3)
	c:RegisterEffect(e1)
end
