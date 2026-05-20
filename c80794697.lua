--フレイム・バッファロー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：表侧表示的这张卡从场上离开的场合才能发动。从手卡丢弃1只电子界族怪兽，自己从卡组抽2张。
function c80794697.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：表侧表示的这张卡从场上离开的场合才能发动。从手卡丢弃1只电子界族怪兽，自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80794697,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,80794697)
	e1:SetCondition(c80794697.condition)
	e1:SetTarget(c80794697.target)
	e1:SetOperation(c80794697.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡从场上离开前是否为表侧表示
function c80794697.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 过滤手牌中可丢弃的电子界族怪兽
function c80794697.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_CYBERSE) and c:IsDiscardable()
end
-- 效果发动的目标检查，确认手牌有可丢弃的电子界族怪兽且玩家可以抽卡
function c80794697.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可以丢弃的电子界族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c80794697.tgfilter,tp,LOCATION_HAND,0,1,nil)
		-- 检查玩家是否可以抽2张卡
		and Duel.IsPlayerCanDraw(tp,2) end
	-- 设置操作信息，表示此效果包含丢弃1张手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置操作信息，表示此效果包含抽2张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：从手牌丢弃1只电子界族怪兽，并从卡组抽2张卡
function c80794697.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家选择手牌中1只电子界族怪兽丢弃，并确认是否成功丢弃
	if Duel.DiscardHand(tp,c80794697.tgfilter,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
		-- 让玩家从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
