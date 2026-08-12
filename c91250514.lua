--タン・ツイスター
-- 效果：
-- 上级召唤的这张卡从场上送去墓地时，从自己卡组抽2张卡。这个效果发动的场合，这张卡从游戏中除外。
function c91250514.initial_effect(c)
	-- 上级召唤的这张卡从场上送去墓地时，从自己卡组抽2张卡。这个效果发动的场合，这张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91250514,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c91250514.condition)
	e1:SetTarget(c91250514.target)
	e1:SetOperation(c91250514.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：这张卡是否从场上送去墓地，且是否为上级召唤状态
function c91250514.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果发动的目标确认：必发效果直接通过，并设置抽卡和除外自身的操作信息
function c91250514.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从卡组抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置操作信息：将墓地的这张卡（自身）除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 效果处理：执行抽卡，并在中断效果后将自身除外
function c91250514.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家因效果从卡组抽2张卡
	Duel.Draw(tp,2,REASON_EFFECT)
	-- 中断当前效果，使后续的除外处理与抽卡不视为同时进行
	Duel.BreakEffect()
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示除外
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
	end
end
