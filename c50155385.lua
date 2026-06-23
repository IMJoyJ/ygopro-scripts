--スピリチューアル・ウィスパー
-- 效果：
-- ①：这张卡1回合只有1次不会被战斗破坏。
-- ②：这张卡灵摆召唤成功时才能发动。从卡组把1只仪式怪兽或者1张仪式魔法卡加入手卡。
function c50155385.initial_effect(c)
	-- ①：这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c50155385.valcon)
	c:RegisterEffect(e1)
	-- ②：这张卡灵摆召唤成功时才能发动。从卡组把1只仪式怪兽或者1张仪式魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50155385,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c50155385.thcon)
	e2:SetTarget(c50155385.thtg)
	e2:SetOperation(c50155385.thop)
	c:RegisterEffect(e2)
end
-- 该效果仅在因战斗破坏时生效
function c50155385.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 确保此卡是通过灵摆召唤方式特殊召唤成功的
function c50155385.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 过滤函数，用于筛选可以加入手牌的仪式怪兽
function c50155385.filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
-- 设置连锁操作信息，表示将从卡组检索一张仪式怪兽加入手牌
function c50155385.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在满足条件的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c50155385.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索一张仪式怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动时的卡牌选择与执行逻辑
function c50155385.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 根据过滤条件从卡组中选择一张仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c50155385.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的仪式怪兽送入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
