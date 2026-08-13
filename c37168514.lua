--ゴルゴニック・ケルベロス
-- 效果：
-- 这张卡召唤成功时，可以让自己场上的全部岩石族怪兽的等级变成3星。
function c37168514.initial_effect(c)
	-- “这张卡召唤成功时，可以让自己场上的全部岩石族怪兽的等级变成3星。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37168514,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c37168514.lvtg)
	e1:SetOperation(c37168514.lvop)
	c:RegisterEffect(e1)
end
-- 过滤条件：选取自己场上表侧表示、种族为岩石族、当前等级不是3且等级在1以上的怪兽，用于后续改变等级。
function c37168514.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ROCK) and not c:IsLevel(3) and c:IsLevelAbove(1)
end
-- 发动检测：作为诱发效果的发动条件，检查自己场上是否存在至少1只满足filter条件的岩石族怪兽，存在时效果才可发动。
function c37168514.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在合法的发动时机（chk==0）检查自己场上是否存在至少1只满足filter条件的岩石族怪兽，若有则返回true。
	if chk==0 then return Duel.IsExistingMatchingCard(c37168514.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：获取所有符合条件的岩石族怪兽，依次为它们附加“等级变为3”的持续效果，并设置该效果在怪兽离开场上等标准时机后自动重置。
function c37168514.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上所有满足filter条件的岩石族怪兽（表侧岩石族、等级不为3且>=1）作为处理对象。
	local g=Duel.GetMatchingGroup(c37168514.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- “等级变成3星”：为每只对象怪兽注册一个单独的单体效果，将等级值固定为3，并在标准重置条件下失效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(3)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
