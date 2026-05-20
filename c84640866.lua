--電網の落とし穴
-- 效果：
-- ①：对方从卡组·墓地把怪兽特殊召唤时才能发动。那些怪兽里侧表示除外。
function c84640866.initial_effect(c)
	-- ①：对方从卡组·墓地把怪兽特殊召唤时才能发动。那些怪兽里侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c84640866.target)
	e1:SetOperation(c84640866.activate)
	c:RegisterEffect(e1)
end
-- 过滤出由对方从卡组或墓地特殊召唤到场上，且可以被里侧表示除外的怪兽
function c84640866.filter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_DECK+LOCATION_GRAVE)
		and c:IsAbleToRemove(tp,POS_FACEDOWN) and c:IsLocation(LOCATION_MZONE)
end
-- 发动时的效果对象确认与合法性检测，判断是否有符合条件的特殊召唤怪兽，并设置操作信息
function c84640866.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(c84640866.filter,nil,tp)
	local ct=g:GetCount()
	if chk==0 then return ct>0 end
	-- 将本次特殊召唤的怪兽组设置为当前连锁的处理对象
	Duel.SetTargetCard(eg)
	-- 设置效果处理的操作信息为：将这些特殊召唤的怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,ct,0,0)
end
-- 效果处理时，筛选出依然在场且符合条件的怪兽，将其里侧表示除外
function c84640866.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c84640866.filter,nil,tp):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将目标怪兽以效果里侧表示除外
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end
