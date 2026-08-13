--終焉の地
-- 效果：
-- ①：对方对怪兽的特殊召唤成功时才能发动。从卡组选1张场地魔法卡发动。
function c48934760.initial_effect(c)
	-- ①：对方对怪兽的特殊召唤成功时才能发动。从卡组选1张场地魔法卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c48934760.condition)
	e1:SetTarget(c48934760.target)
	e1:SetOperation(c48934760.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：已特殊召唤的怪兽的召唤玩家是否为对方玩家（即本次特殊召唤是否由对方进行）。
function c48934760.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 发动条件：特殊召唤成功的怪兽群中存在至少1只满足对方召唤的怪兽。
function c48934760.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c48934760.cfilter,1,nil,tp)
end
-- 从卡组中选出的卡必须满足：是场地魔法卡，且该场地魔法卡的发动效果可以在当前情况下由自己发动。
function c48934760.filter(c,tp)
	return c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 发动时点检查（chk==0）：确认卡组中存在1张符合上述条件的场地魔法卡，作为效果发动的合法性条件。
function c48934760.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：从卡组中检索是否存在1张可发动的场地魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c48934760.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 效果处理：自己从卡组选择1张场地魔法卡，若场上已有场地魔法卡则将其按规则送去墓地，然后将选择的场地魔法卡放置到自己的场地区并发动。
function c48934760.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示自己选择要发动的场地魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(48934760,0))  --"请选择要发动的场地魔法卡"
	-- 从自己卡组中筛选并选择1张满足条件的场地魔法卡。
	local tc=Duel.SelectMatchingCard(tp,c48934760.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取自己场地区域现有的场地魔法卡（若有）。
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 将原有场地魔法卡按规则送入墓地。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使后续发动新场地魔法卡的处理视为不同时进行，避免错时点。
			Duel.BreakEffect()
		end
		-- 将选择的场地魔法卡移动到自己的场地区域，以表侧表示放置并适用其效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发被放置的场地魔法卡的发动时点（将其作为新的连锁发动），以完成该场地魔法卡的发动手续。
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
