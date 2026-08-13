--シールド・ワーム
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，变成守备表示。再把自己场上表侧表示存在的昆虫族怪兽数量的卡从对方卡组上面送去墓地。
function c15939448.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，变成守备表示。再把自己场上表侧表示存在的昆虫族怪兽数量的卡从对方卡组上面送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15939448,0))  --"卡组送墓"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c15939448.condition)
	e1:SetTarget(c15939448.target)
	e1:SetOperation(c15939448.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 效果发动条件：召唤成功时，效果持有者自身为表侧攻击表示。
function c15939448.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 过滤函数：判定怪兽是否为表侧表示且属于昆虫族，用于统计符合条件的我方怪兽数量。
function c15939448.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 发动时的目标处理：无对象选择，直接返回true；统计我方场上表侧昆虫族怪兽数量，并设置操作信息，预告本次效果会把对方卡组上方相应数量的卡送去墓地。
function c15939448.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 统计我方场上表侧表示且为昆虫族的怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c15939448.filter,tp,LOCATION_MZONE,0,nil)
	-- 设置连锁操作信息：本次效果包含将对方卡组上方ct张卡送去墓地的处理（不取对象，数量ct，对象持有者为对方）。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,ct)
end
-- 效果处理：先尝试把自身变为表侧守备表示，若变更成功则重新统计我方场上表侧昆虫族数量，并将对方卡组上方等量卡送去墓地。
function c15939448.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身仍与效果关联、仍为表侧攻击表示，并执行变成表侧守备表示的操作；若变更成功则继续处理。
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE)~=0 then
		-- 效果处理时重新统计当前我方场上表侧表示且为昆虫族的怪兽数量，以保证送去墓地的张数与实际数量一致。
		local ct=Duel.GetMatchingGroupCount(c15939448.filter,tp,LOCATION_MZONE,0,nil)
		if ct>0 then
			-- 中断当前效果处理，使后续的卡组送墓不视为与变更守备表示同时处理，避免错过相关时点。
			Duel.BreakEffect()
			-- 将对方卡组最上方ct张卡以效果原因送去墓地。
			Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
		end
	end
end
