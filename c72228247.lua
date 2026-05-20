--マギアス・パラディオン
-- 效果：
-- 「魔导之圣像骑士」以外的「圣像骑士」怪兽1只
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
-- ②：这张卡所连接区的怪兽不能攻击。
-- ③：这张卡所连接区有效果怪兽特殊召唤的场合才能发动。从卡组把1只「圣像骑士」怪兽加入手卡。
function c72228247.initial_effect(c)
	-- 设置连接召唤的手续，需要1只满足过滤条件的怪兽作为素材
	aux.AddLinkProcedure(c,c72228247.matfilter,1,1)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c72228247.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区的怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c72228247.antg)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡所连接区有效果怪兽特殊召唤的场合才能发动。从卡组把1只「圣像骑士」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(72228247,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,72228247)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c72228247.thcon)
	e3:SetTarget(c72228247.thtg)
	e3:SetOperation(c72228247.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：除「魔导之圣像骑士」以外的「圣像骑士」怪兽
function c72228247.matfilter(c)
	return c:IsLinkSetCard(0x116) and not c:IsLinkCode(72228247)
end
-- 计算攻击力上升值：获取自身所连接区表侧表示怪兽的原本攻击力总和
function c72228247.atkval(e,c)
	local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsFaceup,nil)
	return g:GetSum(Card.GetBaseAttack)
end
-- 限制攻击的目标过滤：自身所连接区的怪兽
function c72228247.antg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 触发条件过滤：在自身所连接区特殊召唤的效果怪兽
function c72228247.cfilter(c,lg)
	return c:IsType(TYPE_EFFECT) and lg:IsContains(c)
end
-- 效果③的发动条件：检查是否有效果怪兽特殊召唤到自身所连接区
function c72228247.thcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(c72228247.cfilter,1,nil,lg)
end
-- 检索卡片的过滤条件：卡组中的「圣像骑士」怪兽
function c72228247.thfilter(c)
	return c:IsSetCard(0x116) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果③的发动准备：检查卡组中是否存在可检索卡，并设置检索的操作信息
function c72228247.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可以加入手牌的「圣像骑士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c72228247.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理：从卡组选择1只「圣像骑士」怪兽加入手牌
function c72228247.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足条件的「圣像骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c72228247.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
