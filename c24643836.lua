--おジャマジック
-- 效果：
-- ①：这张卡从手卡·场上送去墓地的场合发动。从卡组把「扰乱·绿」「扰乱·黄」「扰乱·黑」各1只加入手卡。
function c24643836.initial_effect(c)
	-- 向系统登记本卡文字中记载的卡名：「扰乱·绿」「扰乱·黄」「扰乱·黑」，使相关卡名参照判定能够识别本卡。
	aux.AddCodeList(c,12482652,42941100,79335209)
	-- ①：这张卡从手卡·场上送去墓地的场合发动。从卡组把「扰乱·绿」「扰乱·黄」「扰乱·黑」各1只加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24643836,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c24643836.thcon)
	e1:SetTarget(c24643836.thtg)
	e1:SetOperation(c24643836.thop)
	c:RegisterEffect(e1)
end
-- 发动条件：这张卡的上一位置是手牌或场上，即满足“从手卡·场上送去墓地”的触发条件。
function c24643836.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND)
end
-- 效果发动时的目标判定与操作预告：满足条件则允许发动，并预定从卡组将3张卡加入手牌的操作。
function c24643836.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的操作信息：将卡组中3张卡加入手牌，目标卡数量为3，持有者为tp，检索区域为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,3,tp,LOCATION_DECK)
end
-- 过滤函数：筛选出卡名与指定密码一致的怪兽，且该卡能够加入手牌。
function c24643836.filter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 效果处理：分别从卡组检索「扰乱·绿」「扰乱·黄」「扰乱·黑」各1只，加入手牌并向对方展示。
function c24643836.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在己方卡组中检索1张「扰乱·绿」（密码12482652），若不存在则本次处理不执行。
	local t1=Duel.GetFirstMatchingCard(c24643836.filter,tp,LOCATION_DECK,0,nil,12482652)
	if not t1 then return end
	-- 在己方卡组中检索1张「扰乱·黄」（密码42941100），若不存在则本次处理不执行。
	local t2=Duel.GetFirstMatchingCard(c24643836.filter,tp,LOCATION_DECK,0,nil,42941100)
	if not t2 then return end
	-- 在己方卡组中检索1张「扰乱·黑」（密码79335209），若不存在则本次处理不执行。
	local t3=Duel.GetFirstMatchingCard(c24643836.filter,tp,LOCATION_DECK,0,nil,79335209)
	if not t3 then return end
	local g=Group.FromCards(t1,t2,t3)
	-- 以效果原因将检索到的三张扰乱怪兽加入各自持有者的手牌。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 将加入手牌的这三张卡展示给对手确认。
	Duel.ConfirmCards(1-tp,g)
end
