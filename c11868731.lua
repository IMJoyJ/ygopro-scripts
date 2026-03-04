--マドルチェ・マジョレーヌ
-- 效果：
-- ①：这张卡召唤·反转召唤时才能发动。从卡组把1只「魔偶甜点」怪兽加入手卡。
-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
function c11868731.initial_effect(c)
	-- 效果原文内容：②：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11868731,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c11868731.retcon)
	e1:SetTarget(c11868731.rettg)
	e1:SetOperation(c11868731.retop)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：这张卡召唤·反转召唤时才能发动。从卡组把1只「魔偶甜点」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11868731,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c11868731.shtg)
	e2:SetOperation(c11868731.shop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 规则层面作用：判断该效果是否满足发动条件，即卡片因破坏被送入墓地且为对方破坏。
function c11868731.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 规则层面作用：设置效果处理时的目标信息，用于确定将卡片送回卡组。
function c11868731.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置操作信息，表明此效果会将目标卡片送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 规则层面作用：定义效果发动后的处理函数，用于执行将卡片送回卡组的操作。
function c11868731.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 规则层面作用：实际执行将卡片送回卡组并洗牌的操作。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 规则层面作用：定义过滤函数，用于筛选卡组中满足条件的「魔偶甜点」怪兽。
function c11868731.filter(c)
	return c:IsSetCard(0x71) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 规则层面作用：设置检索效果的目标函数，检查卡组中是否存在符合条件的卡片。
function c11868731.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查卡组中是否存在至少一张符合条件的「魔偶甜点」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c11868731.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面作用：设置操作信息，表明此效果会将一张卡从卡组加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：定义检索效果的处理函数，用于选择并发送符合条件的卡片到手牌。
function c11868731.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：向玩家发送提示信息，提示其选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 规则层面作用：从卡组中选择一张符合条件的卡片作为处理对象。
	local g=Duel.SelectMatchingCard(tp,c11868731.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的卡片发送到玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面作用：向对方玩家展示所选中的卡片内容。
		Duel.ConfirmCards(1-tp,g)
	end
end
