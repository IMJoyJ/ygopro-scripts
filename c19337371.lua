--ヒステリック・サイン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：作为这张卡的发动时的效果处理，从自己的卡组·墓地把1张「万华镜-华丽的分身-」加入手卡。
-- ②：这张卡从手卡·场上送去墓地的回合的结束阶段发动。从卡组把最多3张「鹰身」卡加入手卡（同名卡最多1张）。
function c19337371.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，从自己的卡组·墓地把1张「万华镜-华丽的分身-」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19337371)
	e1:SetTarget(c19337371.target)
	e1:SetOperation(c19337371.activate)
	c:RegisterEffect(e1)
	-- 这张卡从手卡·场上送去墓地的回合的结束阶段发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c19337371.regcon)
	e2:SetOperation(c19337371.regop)
	c:RegisterEffect(e2)
	-- 从卡组把最多3张「鹰身」卡加入手卡（同名卡最多1张）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19337371,0))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1,19337371)
	e3:SetCondition(c19337371.thcon)
	e3:SetTarget(c19337371.thtg)
	e3:SetOperation(c19337371.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于检索满足条件的「万华镜-华丽的分身-」卡片
function c19337371.filter(c)
	return c:IsCode(90219263) and c:IsAbleToHand()
end
-- 效果处理时检查是否满足条件，即在自己卡组或墓地存在「万华镜-华丽的分身-」
function c19337371.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的「万华镜-华丽的分身-」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c19337371.filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组或墓地检索1张「万华镜-华丽的分身-」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 发动效果时执行的操作，选择并检索「万华镜-华丽的分身-」
function c19337371.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1张「万华镜-华丽的分身-」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19337371.filter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断此卡是否从手牌或场上送去墓地
function c19337371.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 注册标记，用于记录此卡已从手牌或场上送去墓地
function c19337371.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(19337371,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数，用于检索满足条件的「鹰身」卡
function c19337371.thfilter(c)
	return c:IsSetCard(0x64) and c:IsAbleToHand()
end
-- 判断此卡是否已注册标记，即是否已从手牌或场上送去墓地
function c19337371.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(19337371)>0
end
-- 设置操作信息，表示将从卡组检索「鹰身」卡
function c19337371.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将从卡组检索「鹰身」卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 发动效果时执行的操作，选择并检索「鹰身」卡
function c19337371.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有满足条件的「鹰身」卡
	local g=Duel.GetMatchingGroup(c19337371.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从满足条件的「鹰身」卡中选择最多3张不同卡名的卡
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,1,3)
	-- 将选中的「鹰身」卡加入手牌
	Duel.SendtoHand(g1,nil,REASON_EFFECT)
	-- 向对方确认加入手牌的「鹰身」卡
	Duel.ConfirmCards(1-tp,g1)
end
