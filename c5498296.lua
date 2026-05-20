--暗黒界の斥候 スカー
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合发动。从卡组把1只4星以下的「暗黑界」怪兽加入手卡。
function c5498296.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地的场合发动。从卡组把1只4星以下的「暗黑界」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5498296,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c5498296.condition)
	e1:SetTarget(c5498296.target)
	e1:SetOperation(c5498296.operation)
	c:RegisterEffect(e1)
end
-- 判断此卡是否在墓地且是被战斗破坏送去墓地
function c5498296.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果发动的靶向与操作信息设置，必发效果直接返回true并设置检索操作信息
function c5498296.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤卡组中等级4以下且卡名含有「暗黑界」的可以加入手牌的怪兽
function c5498296.filter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x6) and c:IsAbleToHand()
end
-- 效果处理：从卡组将1只满足条件的「暗黑界」怪兽加入手牌并给对方确认
function c5498296.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在系统提示栏显示“请选择要加入手牌的卡”的信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c5498296.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
