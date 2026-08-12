--天極輝艦－熊斗竜巧
-- 效果：
-- 这个卡名在规则上也当作「北极天熊」卡、「龙辉巧」卡使用。这张卡用「天斗辉巧极」的效果才能特殊召唤。
-- ①：1回合1次，自己场上有其他的效果怪兽特殊召唤的场合才能发动。从卡组把1只「北极天熊」怪兽或者「龙辉巧」怪兽加入手卡。
-- ②：1回合1次，以除外的1只自己的「北极天熊」怪兽或者「龙辉巧」怪兽为对象才能发动。那只怪兽加入手卡。
function c33250142.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用「天斗辉巧极」的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(c33250142.splimit)
	c:RegisterEffect(e0)
	-- 1回合1次，自己场上有其他的效果怪兽特殊召唤的场合才能发动。从卡组把1只「北极天熊」怪兽或者「龙辉巧」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33250142,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c33250142.thcon1)
	e1:SetTarget(c33250142.thtg1)
	e1:SetOperation(c33250142.thop1)
	c:RegisterEffect(e1)
	-- 1回合1次，以除外的1只自己的「北极天熊」怪兽或者「龙辉巧」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33250142,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c33250142.thtg2)
	e2:SetOperation(c33250142.thop2)
	c:RegisterEffect(e2)
end
-- 设置此卡的特殊召唤条件为必须通过「天斗辉巧极」的效果进行特殊召唤。
function c33250142.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(89771220)
end
-- 用于判断场上是否存在其他效果怪兽被特殊召唤的过滤器。
function c33250142.cfilter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsControler(tp)
end
-- 判断是否满足效果发动条件：不是自己特殊召唤且有其他效果怪兽被特殊召唤。
function c33250142.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c33250142.cfilter1,1,nil,tp)
end
-- 用于检索卡组中「北极天熊」或「龙辉巧」的怪兽。
function c33250142.thfilter1(c)
	return c:IsSetCard(0x163,0x154) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果处理时的连锁信息，准备从卡组检索满足条件的怪兽。
function c33250142.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c33250142.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的连锁信息，准备将卡组中的怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理：提示选择并从卡组将符合条件的怪兽加入手牌。
function c33250142.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c33250142.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的怪兽。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 用于判断除外区中是否含有「北极天熊」或「龙辉巧」的怪兽。
function c33250142.thfilter2(c)
	return c33250142.thfilter1(c) and c:IsFaceup()
end
-- 设置效果处理时的连锁信息，准备从除外区选择符合条件的怪兽。
function c33250142.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c33250142.thfilter2(chkc) end
	-- 检查是否满足发动条件：除外区中存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c33250142.thfilter2,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从除外区中选择一张符合条件的怪兽。
	local g=Duel.SelectTarget(tp,c33250142.thfilter2,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理时的连锁信息，准备将除外区的怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果处理：从除外区选择符合条件的怪兽并将其加入手牌。
function c33250142.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
