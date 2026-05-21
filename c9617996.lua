--レグレクス・パラディオン
-- 效果：
-- 包含「圣像骑士」怪兽的效果怪兽2只
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
-- ②：这张卡所连接区的怪兽不能攻击。
-- ③：这张卡所连接区有效果怪兽特殊召唤的场合才能发动。从卡组把1张「圣像骑士」魔法·陷阱卡加入手卡。
function c9617996.initial_effect(c)
	-- 设置连接召唤手续：效果怪兽2只，且必须包含「圣像骑士」怪兽（由lcheck函数判定）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2,c9617996.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c9617996.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区的怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c9617996.antg)
	c:RegisterEffect(e2)
	-- ③：这张卡所连接区有效果怪兽特殊召唤的场合才能发动。从卡组把1张「圣像骑士」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9617996,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,9617996)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c9617996.thcon)
	e3:SetTarget(c9617996.thtg)
	e3:SetOperation(c9617996.thop)
	c:RegisterEffect(e3)
end
-- 连接召唤素材的额外过滤条件：素材组中必须存在至少1张「圣像骑士」卡片。
function c9617996.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x116)
end
-- 计算此卡所连接区所有表侧表示怪兽的原本攻击力总和。
function c9617996.atkval(e,c)
	local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsFaceup,nil)
	return g:GetSum(Card.GetBaseAttack)
end
-- 过滤出此卡所连接区的怪兽作为不能攻击效果的对象。
function c9617996.antg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 过滤出属于效果怪兽且存在于此卡所连接区的卡片。
function c9617996.cfilter(c,lg)
	return c:IsType(TYPE_EFFECT) and lg:IsContains(c)
end
-- 触发条件判定：检查特殊召唤成功的怪兽中是否存在此卡所连接区的效果怪兽。
function c9617996.thcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(c9617996.cfilter,1,nil,lg)
end
-- 过滤出卡组中可以加入手牌的「圣像骑士」魔法·陷阱卡。
function c9617996.thfilter(c)
	return c:IsSetCard(0x116) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果3的发动准备：检查卡组中是否存在可检索的卡，并设置将卡加入手牌的操作信息。
function c9617996.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「圣像骑士」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c9617996.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果3的效果处理：从卡组选择1张「圣像骑士」魔法·陷阱卡加入手牌并给对方确认。
function c9617996.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「圣像骑士」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c9617996.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
