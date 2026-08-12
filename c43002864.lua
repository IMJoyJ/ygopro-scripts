--レプティレス・ガードナー
-- 效果：
-- 自己场上存在的这张卡被破坏送去墓地时，从自己卡组把1只名字带有「爬虫妖」的怪兽加入手卡。
function c43002864.initial_effect(c)
	-- 诱发必发效果，当此卡因破坏而送去墓地时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43002864,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c43002864.condition)
	e1:SetTarget(c43002864.target)
	e1:SetOperation(c43002864.operation)
	c:RegisterEffect(e1)
end
-- 此卡因破坏而送去墓地且之前在场上，且之前为玩家控制
function c43002864.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 设置效果处理时的操作信息，准备从卡组检索1张怪兽卡加入手牌
function c43002864.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为CATEGORY_TOHAND（回手牌）和CATEGORY_SEARCH（检索）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于筛选卡组中名字带有「爬虫妖」的怪兽
function c43002864.filter(c)
	return c:IsSetCard(0x3c) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理函数，选择满足条件的卡并加入手牌，同时向对手确认该卡
function c43002864.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,c43002864.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手确认被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
