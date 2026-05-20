--ボタニティ・ガール
-- 效果：
-- 这张卡从场上送去墓地时，可以从自己卡组把1只守备力1000以下的植物族怪兽加入手卡。
function c84824601.initial_effect(c)
	-- 这张卡从场上送去墓地时，可以从自己卡组把1只守备力1000以下的植物族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84824601,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c84824601.condition)
	e1:SetTarget(c84824601.target)
	e1:SetOperation(c84824601.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：检查这张卡之前的位置是否在场上（即满足从场上送去墓地的条件）
function c84824601.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果的目标与发动合法性检测：检查卡组中是否存在可检索的怪兽，并向系统宣告将卡片加入手卡的操作信息
function c84824601.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检测自己卡组是否存在至少1只守备力1000以下且可以加入手卡的植物族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84824601.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息，宣告该效果包含将卡组的1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：守备力在1000以下、种族为植物族且可以加入手卡的怪兽
function c84824601.filter(c)
	return c:IsDefenseBelow(1000) and c:IsRace(RACE_PLANT) and c:IsAbleToHand()
end
-- 效果处理：从卡组中选择1只满足条件的植物族怪兽加入手卡，并向对方展示确认
function c84824601.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家提示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c84824601.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
