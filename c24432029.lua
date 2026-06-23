--ジェネクス・ブラスト
-- 效果：
-- ①：这张卡特殊召唤时才能发动。从卡组把1只暗属性「次世代」怪兽加入手卡。
function c24432029.initial_effect(c)
	-- ①：这张卡特殊召唤时才能发动。从卡组把1只暗属性「次世代」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24432029,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c24432029.target)
	e1:SetOperation(c24432029.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选卡组中满足条件的卡片：属于次世代卡组、暗属性且可以加入手牌的怪兽。
function c24432029.filter(c)
	return c:IsSetCard(0x2) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 效果的发动条件判断与操作信息设置，检查卡组中是否存在满足条件的卡片并设置操作信息。
function c24432029.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断在不发动效果的情况下是否满足条件，即卡组中是否存在符合条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c24432029.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要处理的卡片类别为回手牌和检索卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，执行检索并加入手牌的操作。
function c24432029.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c24432029.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片以效果原因送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
