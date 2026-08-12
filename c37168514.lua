--ゴルゴニック・ケルベロス
-- 效果：
-- 这张卡召唤成功时，可以让自己场上的全部岩石族怪兽的等级变成3星。
function c37168514.initial_effect(c)
	-- 这张卡召唤成功时，可以让自己场上的全部岩石族怪兽的等级变成3星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37168514,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c37168514.lvtg)
	e1:SetOperation(c37168514.lvop)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的岩石族怪兽且等级不是3星且等级大于等于1星
function c37168514.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ROCK) and not c:IsLevel(3) and c:IsLevelAbove(1)
end
-- 效果发动时的处理函数，检查场上是否存在满足条件的岩石族怪兽
function c37168514.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张满足过滤条件的岩石族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c37168514.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果发动时执行的操作函数，将场上满足条件的岩石族怪兽等级变为3星
function c37168514.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足过滤条件的岩石族怪兽组成一个组
	local g=Duel.GetMatchingGroup(c37168514.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 将等级变化效果应用到目标怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(3)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
