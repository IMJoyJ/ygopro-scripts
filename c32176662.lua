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
-- 过滤函数，用于筛选攻击表示且可以改变表示形式的怪兽
function c32176662.filter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- 效果的target函数，检查对方场上是否存在攻击表示的怪兽，若存在则设置操作信息
function c32176662.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只攻击表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c32176662.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有攻击表示且可以改变表示形式的怪兽组
	local g=Duel.GetMatchingGroup(c32176662.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息为改变表示形式，目标为获取到的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果的operation函数，将符合条件的怪兽全部变为守备表示
function c32176662.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有攻击表示且可以改变表示形式的怪兽组
	local g=Duel.GetMatchingGroup(c32176662.filter,tp,0,LOCATION_MZONE,nil)
	-- 将怪兽组全部改变为表侧守备表示
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
end
