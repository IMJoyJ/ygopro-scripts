--ヒロイック・エンヴォイ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「英豪」怪兽加入手卡。
-- ②：自己基本分是500以下的场合，把墓地的这张卡除外，以自己墓地1张「英豪」卡为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 初始化效果：注册这张卡的两个效果：①效果为魔法卡发动，自由时点从卡组检索「英豪」怪兽；②效果为墓地起动效果，以除外自身为代价回收墓地「英豪」卡。
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
	-- 设置②效果的发动COST：把墓地里的这张卡自身除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c45337544.thtg)
	e2:SetOperation(c45337544.thop)
	c:RegisterEffect(e2)
end
-- ①效果的检索过滤条件：必须是「英豪」怪兽，且能够加入手牌。
function c45337544.filter(c)
	return c:IsSetCard(0x6f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的目标检测与操作信息：检查卡组是否存在满足过滤条件的「英豪」怪兽，若满足则设置从卡组将1张卡加入手牌的处理信息。
function c45337544.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认卡组中至少存在1只符合检索条件的「英豪」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c45337544.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁要执行『从卡组把卡加入手牌』的操作信息，供其他卡进行响应判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：玩家从卡组选择1只符合条件的「英豪」怪兽加入手牌，并向对方确认。
function c45337544.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要加入手牌的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组中选出1只满足过滤条件的「英豪」怪兽。
	local g=Duel.SelectMatchingCard(tp,c45337544.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件判定：自己当前基本分在500以下。
function c45337544.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己基本分是否不大于500。
	return Duel.GetLP(tp)<=500
end
-- ②效果的对象过滤条件：该卡是「英豪」卡，且能够加入手牌。
function c45337544.thfilter(c)
	return c:IsSetCard(0x6f) and c:IsAbleToHand()
end
-- ②效果的目标选择与操作信息：以自己墓地1张「英豪」卡为对象（不能选择将要除外的这张卡自身），并设置回手牌的处理信息。
function c45337544.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45337544.thfilter(chkc) end
	-- 在效果发动合法性检查时，确认自己墓地存在至少1张除发动效果的这张卡以外、可加入手牌的「英豪」卡。
	if chk==0 then return Duel.IsExistingTarget(c45337544.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家显示“请选择要加入手牌的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己墓地1张符合条件的「英豪」卡作为效果对象，并自动登记为对象。
	local g=Duel.SelectTarget(tp,c45337544.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置本次连锁要执行『将对象卡加入手牌』的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：将作为对象的墓地「英豪」卡加入手牌。
function c45337544.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
