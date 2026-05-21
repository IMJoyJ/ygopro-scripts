--結晶神ティスティナ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。对方场上的怪兽全部变成里侧守备表示。那之后，可以把对方场上的表侧表示卡全部送去墓地。
-- ②：这张卡被对方破坏的场合才能发动。对方场上的怪兽全部变成里侧守备表示。那之后，可以把对方场上的表侧表示卡全部送去墓地。
local s,id=GetID()
-- 注册该卡的效果①和效果②
function s.initial_effect(c)
	-- ①：自己主要阶段才能发动。对方场上的怪兽全部变成里侧守备表示。那之后，可以把对方场上的表侧表示卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏的场合才能发动。对方场上的怪兽全部变成里侧守备表示。那之后，可以把对方场上的表侧表示卡全部送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 检查是否是被对方破坏且破坏前由自己控制
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 效果①和效果②的共同发动准备（Target）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查对方场上是否存在可以变成里侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有可以变成里侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，表示此效果包含改变表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果①和效果②的共同效果处理（Operation）
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，获取对方场上所有可以变成里侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
	-- 若存在满足条件的怪兽，则将它们全部变成里侧守备表示，并检查是否成功改变了至少1张卡的表示形式
	if g:GetCount()>0 and Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)>0 then
		-- 获取对方场上所有表侧表示的卡
		local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
		-- 若对方场上存在表侧表示的卡，则询问玩家是否将其全部送去墓地
		if g1:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把对方场上的表侧表示的卡全部送去墓地？"
			-- 中断当前效果处理，使前后的操作不同时处理（造成错时点）
			Duel.BreakEffect()
			-- 将对方场上的表侧表示卡全部送去墓地
			Duel.SendtoGrave(g1,REASON_EFFECT)
		end
	end
end
