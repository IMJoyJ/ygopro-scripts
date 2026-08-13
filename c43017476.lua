--デューテリオン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段把这张卡从手卡丢弃才能发动。从卡组把1张「结合术」魔法·陷阱卡加入手卡。
-- ②：这张卡召唤·特殊召唤成功的场合，以自己墓地的「氢素龙」「氧素龙」「氘素龙」的其中1只为对象才能发动。那只怪兽特殊召唤。
function c43017476.initial_effect(c)
	-- 登记卡名关联：将本卡（氘素龙 43017476）、氢素龙（22587018）、氧素龙（58071123）登记为这张卡上记载的卡名，用于规则识别效果②可选择的怪兽。
	aux.AddCodeList(c,43017476,22587018,58071123)
	-- ①：自己主要阶段把这张卡从手卡丢弃才能发动。从卡组把1张「结合术」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43017476,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,43017476)
	e1:SetCost(c43017476.cost)
	e1:SetTarget(c43017476.target)
	e1:SetOperation(c43017476.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，以自己墓地的「氢素龙」「氧素龙」「氘素龙」的其中1只为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43017476,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,43017477)
	e2:SetTarget(c43017476.sptg)
	e2:SetOperation(c43017476.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 代价函数：效果发动时以丢弃手卡中的这张卡为代价；chk阶段检查此卡是否可丢弃，执行时将其送去墓地（原因标记为代价+丢弃）。
function c43017476.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡从手卡送去墓地，作为发动效果的代价（REASON_COST）并视为丢弃（REASON_DISCARD）。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 筛选函数：判断卡是否为「结合术」字段（0x100）的魔法·陷阱卡，且能够加入手卡。
function c43017476.filter(c)
	return c:IsSetCard(0x100) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 目标处理函数：检查卡组中是否存在符合条件的「结合术」魔法·陷阱卡，并登记检索回手牌的操作信息。
function c43017476.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认卡组中至少存在1张满足筛选条件的「结合术」魔法·陷阱卡，使效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c43017476.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本效果将执行从卡组把1张卡加入手牌（CATEGORY_TOHAND），具体目标在效果处理时确定，检索方为tp，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：执行检索，从卡组选择1张符合条件的「结合术」魔法·陷阱卡加入手牌，并向对方展示确认。
function c43017476.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从卡组中选择1张满足筛选条件的「结合术」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c43017476.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡送入其持有者的手卡，原因记为效果处理（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家（1-tp）展示刚刚加入手牌的卡，以确认检索内容。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选函数：用于选择墓地的「氢素龙」「氧素龙」「氘素龙」之一，并确认该怪兽可以被当前效果以通常方式特殊召唤（检查召唤条件和苏生限制）。
function c43017476.spfilter(c,e,tp)
	return c:IsCode(22587018,58071123,43017476) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动条件与取对象处理：召唤/特殊召唤成功时，检查自己怪兽区有空位且墓地存在可特殊召唤的目标；随后选择1只符合条件的怪兽作为效果对象。
function c43017476.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c43017476.spfilter(chkc,e,tp) end
	-- 合法性检查：确认自己主要怪兽区域有空位可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 合法性检查：确认墓地存在至少1只满足spfilter且能成为效果对象的「氢素龙」「氧素龙」「氘素龙」。
		and Duel.IsExistingTarget(c43017476.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家tp显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家tp从自己墓地选择1只满足条件的「氢素龙」「氧素龙」「氘素龙」作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c43017476.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本效果将对已选择的卡执行特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：实际执行特殊召唤，将对象怪兽特殊召唤到自己场上表侧攻击表示。
function c43017476.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果处理时对应的对象卡（之前墓地选择的那只怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到tp的怪兽区，以通常效果特殊召唤方式处理，检查召唤条件和苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
