--矮星竜 プラネター
-- 效果：
-- ①：这张卡召唤的回合的结束阶段才能发动。从卡组把1只光属性或者暗属性的7星怪兽加入手卡。
function c67310848.initial_effect(c)
	-- ①：这张卡召唤的回合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c67310848.sumsuc)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤的回合的结束阶段才能发动。从卡组把1只光属性或者暗属性的7星怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c67310848.thcon)
	e2:SetTarget(c67310848.thtg)
	e2:SetOperation(c67310848.thop)
	c:RegisterEffect(e2)
end
-- 召唤成功时，给自身注册一个在回合结束时重置的标识，用于记录该卡是在本回合召唤的
function c67310848.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(67310848,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end
-- 发动条件：检查自身是否存在召唤成功的标识（即确认是在本回合召唤的）
function c67310848.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(67310848)~=0
end
-- 过滤条件：卡组中等级为7且属性为光或暗的可以加入手牌的怪兽
function c67310848.thfilter(c)
	return c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 效果发动阶段：检查卡组中是否存在符合条件的卡，并设置将卡片加入手牌的操作信息
function c67310848.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，确认卡组中是否存在至少1只满足条件的光·暗属性7星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67310848.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的怪兽加入手牌，并给对方确认
function c67310848.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c67310848.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
