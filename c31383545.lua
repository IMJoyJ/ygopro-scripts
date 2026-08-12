--XX－セイバー ダークソウル
-- 效果：
-- ①：这张卡从自己场上送去墓地的回合的结束阶段才能发动。从卡组把1只「X-剑士」怪兽加入手卡。
function c31383545.initial_effect(c)
	-- ①：这张卡从自己场上送去墓地的回合的结束阶段才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c31383545.regop)
	c:RegisterEffect(e1)
end
-- 当此卡因自身送去墓地时，将效果注册到墓地
function c31383545.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- 从卡组把1只「X-剑士」怪兽加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(31383545,0))  --"卡组检索"
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c31383545.thtg)
		e1:SetOperation(c31383545.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数，用于筛选「X-剑士」怪兽
function c31383545.filter(c)
	return c:IsSetCard(0x100d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果处理时的检索操作信息
function c31383545.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c31383545.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果
function c31383545.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c31383545.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
