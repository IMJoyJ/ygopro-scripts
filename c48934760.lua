--終焉の地
-- 效果：
-- ①：对方对怪兽的特殊召唤成功时才能发动。从卡组选1张场地魔法卡发动。
function c48934760.initial_effect(c)
	-- 创建效果，类型为发动效果，触发时点为对方怪兽特殊召唤成功，条件为对方有怪兽被特殊召唤，目标为选择场地魔法卡，效果处理为将选中的场地魔法卡放置到场上
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c48934760.condition)
	e1:SetTarget(c48934760.target)
	e1:SetOperation(c48934760.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查怪兽是否为对方玩家召唤或特殊召唤的
function c48934760.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 条件函数：判断是否有对方玩家召唤或特殊召唤的怪兽
function c48934760.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c48934760.cfilter,1,nil,tp)
end
-- 过滤函数：检查卡牌是否为场地魔法类型且可以发动
function c48934760.filter(c,tp)
	return c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 目标函数：检查我方卡组是否存在满足条件的场地魔法卡
function c48934760.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若未选择，则检查我方卡组是否存在满足条件的场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c48934760.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 效果处理函数：提示选择场地魔法卡，选择后将该卡放置到场上并触发其发动效果
function c48934760.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示“请选择要发动的场地魔法卡”
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(48934760,0))  --"请选择要发动的场地魔法卡"
	-- 从我方卡组中选择一张满足条件的场地魔法卡
	local tc=Duel.SelectMatchingCard(tp,c48934760.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取我方场上的场地魔法卡
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 将场上原有的场地魔法卡送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使后续处理不同时进行
			Duel.BreakEffect()
		end
		-- 将选中的场地魔法卡放置到我方场地区域
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发该场地魔法卡的发动时点
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
