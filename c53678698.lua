--武神－ミカヅチ
-- 效果：
-- 自己场上的名字带有「武神」的兽战士族怪兽被战斗或者卡的效果破坏送去墓地时，这张卡可以从手卡特殊召唤。此外，这张卡在场上表侧表示存在，从自己手卡有名字带有「武神」的怪兽被送去自己墓地的场合，那个回合的结束阶段时1次，可以从卡组把1张名字带有「武神」的魔法·陷阱卡加入手卡。「武神-御雷」在自己场上只能有1只表侧表示存在。
function c53678698.initial_effect(c)
	c:SetUniqueOnField(1,0,53678698)
	-- 自己场上的名字带有「武神」的兽战士族怪兽被战斗或者卡的效果破坏送去墓地时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53678698,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c53678698.spcon)
	e1:SetTarget(c53678698.sptg)
	e1:SetOperation(c53678698.spop)
	c:RegisterEffect(e1)
	-- 此外，这张卡在场上表侧表示存在，从自己手卡有名字带有「武神」的怪兽被送去自己墓地的场合，那个回合的结束阶段时1次，可以从卡组把1张名字带有「武神」的魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53678698,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c53678698.thcon)
	e2:SetTarget(c53678698.thtg)
	e2:SetOperation(c53678698.thop)
	c:RegisterEffect(e2)
	-- 「武神-御雷」在自己场上只能有1只表侧表示存在。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c53678698.regcon)
	e3:SetOperation(c53678698.regop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断被破坏的怪兽是否为名字带有「武神」的兽战士族怪兽且为战斗或卡的效果破坏。
function c53678698.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR) and c:IsReason(REASON_DESTROY)
end
-- 触发条件，判断是否有满足cfilter条件的怪兽被破坏送入墓地。
function c53678698.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53678698.cfilter,1,nil,tp)
end
-- 特殊召唤的发动时点处理，检查是否有足够的怪兽区域和是否可以特殊召唤。
function c53678698.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，将卡片特殊召唤到场上。
function c53678698.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作，将卡片以正面表示形式特殊召唤到场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 检索效果的触发条件，判断是否在该回合有手卡怪兽被送入墓地。
function c53678698.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(53678698)>0
end
-- 过滤函数，用于检索卡组中名字带有「武神」的魔法或陷阱卡。
function c53678698.filter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 检索效果的发动时点处理，检查卡组中是否存在满足条件的卡。
function c53678698.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的魔法或陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c53678698.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，选择并加入手牌。
function c53678698.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,c53678698.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，用于判断被送入墓地的卡是否为名字带有「武神」的怪兽且来自手卡。
function c53678698.rfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_HAND)
		and c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER)
end
-- 注册效果的触发条件，判断是否有名字带有「武神」的怪兽从手卡送入墓地。
function c53678698.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53678698.rfilter,1,nil,tp)
end
-- 注册效果的处理函数，为该回合注册一个标记，用于后续检索效果的触发。
function c53678698.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(53678698,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
