--魔犬オクトロス
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡从场上送去墓地的场合发动。从卡组把1只恶魔族·8星怪兽加入手卡。
function c58616392.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡从场上送去墓地的场合发动。从卡组把1只恶魔族·8星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,58616392)
	e1:SetCondition(c58616392.condition)
	e1:SetTarget(c58616392.target)
	e1:SetOperation(c58616392.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否是从场上送去墓地
function c58616392.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果发动的目标处理，设置将卡组的卡加入手卡的操作信息
function c58616392.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤卡组中属于恶魔族、8星且可以加入手卡的怪兽
function c58616392.filter(c)
	return c:IsRace(RACE_FIEND) and c:IsLevel(8) and c:IsAbleToHand()
end
-- 效果处理的执行，从卡组将1只恶魔族·8星怪兽加入手卡
function c58616392.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c58616392.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
