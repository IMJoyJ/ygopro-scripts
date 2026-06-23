--ヒロイック・エンヴォイ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「英豪」怪兽加入手卡。
-- ②：自己基本分是500以下的场合，把墓地的这张卡除外，以自己墓地1张「英豪」卡为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 注册两个效果：①从卡组检索英豪怪兽加入手牌；②墓地发动，支付除外费用，选择墓地一张英豪卡加入手牌
function c45337544.initial_effect(c)
	-- ①：从卡组把1只「英豪」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,45337544)
	e1:SetTarget(c45337544.target)
	e1:SetOperation(c45337544.activate)
	c:RegisterEffect(e1)
	-- ②：自己基本分是500以下的场合，把墓地的这张卡除外，以自己墓地1张「英豪」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,45337544+o)
	e2:SetCondition(c45337544.thcon)
	-- 支付将此卡除外的费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c45337544.thtg)
	e2:SetOperation(c45337544.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断是否为英豪怪兽且能加入手牌
function c45337544.filter(c)
	return c:IsSetCard(0x6f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动时点处理：检查卡组是否存在满足条件的英豪怪兽
function c45337544.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张满足条件的英豪怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c45337544.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果①的处理信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的发动处理：选择并把满足条件的卡加入手牌
function c45337544.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c45337544.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：自己基本分不超过500
function c45337544.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己基本分是否不超过500
	return Duel.GetLP(tp)<=500
end
-- 过滤函数：判断是否为英豪卡且能加入手牌
function c45337544.thfilter(c)
	return c:IsSetCard(0x6f) and c:IsAbleToHand()
end
-- 效果②的发动时点处理：检查墓地是否存在满足条件的英豪卡
function c45337544.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45337544.thfilter(chkc) end
	-- 检查墓地是否存在至少1张满足条件的英豪卡
	if chk==0 then return Duel.IsExistingTarget(c45337544.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择1张满足条件的卡作为对象
	local g=Duel.SelectTarget(tp,c45337544.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置效果②的处理信息：将1张卡从墓地加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的发动处理：将选中的卡加入手牌
function c45337544.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
