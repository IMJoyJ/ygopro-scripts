--トリック・デーモン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被效果送去墓地的场合或者被战斗破坏送去墓地的场合才能发动。从卡组把「诡计恶魔」以外的1张「恶魔」卡加入手卡。
function c66540884.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡被效果送去墓地的场合或者被战斗破坏送去墓地的场合才能发动。从卡组把「诡计恶魔」以外的1张「恶魔」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66540884,0))  --"检索"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,66540884)
	e1:SetCondition(c66540884.thcon)
	e1:SetTarget(c66540884.thtg)
	e1:SetOperation(c66540884.thop)
	c:RegisterEffect(e1)
end
-- 判断此卡是否因效果或战斗破坏送去墓地，作为效果发动的条件
function c66540884.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) or c:IsReason(REASON_BATTLE)
end
-- 过滤卡组中除「诡计恶魔」以外的「恶魔」卡片
function c66540884.thfilter(c)
	return c:IsSetCard(0x45) and not c:IsCode(66540884) and c:IsAbleToHand()
end
-- 效果发动的目标处理，检查卡组中是否存在符合条件的卡并设置操作信息
function c66540884.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1张符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c66540884.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果会从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组选择1张符合条件的卡加入手卡并向对方展示
function c66540884.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端弹出提示，要求玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张除「诡计恶魔」以外的「恶魔」卡
	local g=Duel.SelectMatchingCard(tp,c66540884.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
