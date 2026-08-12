--エヴォルダー・ケラト
-- 效果：
-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，这张卡的攻击力上升200。那之后，这张卡战斗破坏对方怪兽的场合，可以从自己卡组把1只名字带有「进化虫」的怪兽加入手卡。
function c80651316.initial_effect(c)
	-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，这张卡的攻击力上升200。那之后，这张卡战斗破坏对方怪兽的场合，可以从自己卡组把1只名字带有「进化虫」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置效果发动条件为：用名字带有「进化虫」的怪兽的效果特殊召唤成功时。
	e1:SetCondition(aux.evospcon)
	e1:SetOperation(c80651316.atkop)
	c:RegisterEffect(e1)
end
-- 攻击力上升200，并注册“战斗破坏对方怪兽时可以从卡组检索1只「进化虫」怪兽”的效果。
function c80651316.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这张卡的攻击力上升200
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(200)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	-- 那之后，这张卡战斗破坏对方怪兽的场合，可以从自己卡组把1只名字带有「进化虫」的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80651316,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetTarget(c80651316.schtg)
	e2:SetOperation(c80651316.schop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中名字带有「进化虫」的怪兽卡，且能加入手卡。
function c80651316.sfilter(c)
	return c:IsSetCard(0x304e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备（检查卡组中是否存在符合条件的卡，并设置检索的操作信息）。
function c80651316.schtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只名字带有「进化虫」的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c80651316.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行（从卡组选择1只名字带有「进化虫」的怪兽加入手卡并给对方确认）。
function c80651316.schop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「进化虫」怪兽。
	local g=Duel.SelectMatchingCard(tp,c80651316.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
