--フリップ・フローズン
-- 效果：
-- ①：这张卡被送去墓地的场合才能发动。对方场上的攻击表示怪兽全部变成守备表示。
function c32176662.initial_effect(c)
	-- ①：这张卡被送去墓地的场合才能发动。对方场上的攻击表示怪兽全部变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c32176662.postg)
	e1:SetOperation(c32176662.posop)
	c:RegisterEffect(e1)
end
-- 筛选函数：判断怪兽是否为攻击表示且能够被效果改变表示形式，即对方场上符合条件的攻击表示怪兽。
function c32176662.filter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- 效果的目标函数：发动前确认对方场上有至少1只满足条件的攻击表示怪兽；发动时取得这些怪兽的集合，并设置后续变更表示形式的操作信息。
function c32176662.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：若为合法性检查，则确认对方场上主要怪兽区是否存在至少1只满足filter条件的攻击表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c32176662.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上全部满足条件（攻击表示且可改变表示形式）的怪兽并组成集合。
	local g=Duel.GetMatchingGroup(c32176662.filter,tp,0,LOCATION_MZONE,nil)
	-- 将当前连锁的处理信息设为改变表示形式，目标为上述集合，数量为集合内卡数，用于给其他效果提供联动判定依据。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理函数：在效果结算时重新获取对方场上满足条件的攻击表示怪兽集合，并将其全部转变为表侧守备表示。
function c32176662.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上当前所有满足条件（攻击表示且可改变表示形式）的怪兽集合，以确保处理时机准确。
	local g=Duel.GetMatchingGroup(c32176662.filter,tp,0,LOCATION_MZONE,nil)
	-- 将集合中的所有怪兽统一变更为表侧守备表示。
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
end
