--S－Force グラビティーノ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「治安战警队 引力微子」以外的1张「治安战警队」卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽从场上离开的场合除外。
function c21368442.initial_effect(c)
	-- 效果原文：①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「治安战警队 引力微子」以外的1张「治安战警队」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21368442,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,21368442)
	e1:SetTarget(c21368442.thtg)
	e1:SetOperation(c21368442.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 效果原文：②：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c21368442.rmtg)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「治安战警队」卡（不包括自身）并能加入手牌。
function c21368442.thfilter(c)
	return c:IsSetCard(0x156) and not c:IsCode(21368442) and c:IsAbleToHand()
end
-- 效果处理时的判断函数，检查是否满足发动条件并设置操作信息。
function c21368442.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即卡组中是否存在符合条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c21368442.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行检索并加入手牌的操作。
function c21368442.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌。
	local g=Duel.SelectMatchingCard(tp,c21368442.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看了送入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，用于判断是否为己方「治安战警队」怪兽。
function c21368442.rmfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x156) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 判断目标怪兽是否在己方「治安战警队」怪兽的正对面。
function c21368442.rmtg(e,c)
	local cg=c:GetColumnGroup()
	return cg:IsExists(c21368442.rmfilter,1,nil,e:GetHandlerPlayer())
end
