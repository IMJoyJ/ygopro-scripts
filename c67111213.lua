--リチュア・アビス
-- 效果：
-- ①：这张卡召唤·反转召唤·特殊召唤成功时才能发动。从卡组把「遗式深渊鲛」以外的1只守备力1000以下的「遗式」怪兽加入手卡。
function c67111213.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功时才能发动。从卡组把「遗式深渊鲛」以外的1只守备力1000以下的「遗式」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67111213,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c67111213.tg)
	e1:SetOperation(c67111213.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「遗式深渊鲛」以外的1只守备力1000以下的「遗式」怪兽
function c67111213.filter(c)
	return c:IsDefenseBelow(1000) and c:IsSetCard(0x3a) and c:IsType(TYPE_MONSTER) and not c:IsCode(67111213) and c:IsAbleToHand()
end
-- 效果①的发动准备，检查卡组中是否存在符合条件的卡并设置操作信息
function c67111213.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c67111213.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果会将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理，从卡组选择1只符合条件的怪兽加入手卡并给对方确认
function c67111213.op(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c67111213.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
