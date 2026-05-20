--アブソルーター・ドラゴン
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「弹丸」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把1只「弹丸」怪兽加入手卡。
function c67748760.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「弹丸」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,67748760+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c67748760.sprcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被送去墓地的场合才能发动。从卡组把1只「弹丸」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67748760,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,67748761)
	e2:SetTarget(c67748760.thtg)
	e2:SetOperation(c67748760.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「弹丸」怪兽
function c67748760.sprfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x102)
end
-- 特殊召唤规则的发动条件：自身场上有可用的怪兽区域，且存在表侧表示的「弹丸」怪兽
function c67748760.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的「弹丸」怪兽
		and Duel.IsExistingMatchingCard(c67748760.sprfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡组中的「弹丸」怪兽
function c67748760.thfilter(c)
	return c:IsSetCard(0x102) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备：检查卡组中是否存在可检索的「弹丸」怪兽，并设置操作信息
function c67748760.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查卡组中是否存在满足条件的「弹丸」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67748760.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行：从卡组选择1只「弹丸」怪兽加入手卡并给对方确认
function c67748760.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的「弹丸」怪兽
	local g=Duel.SelectMatchingCard(tp,c67748760.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
