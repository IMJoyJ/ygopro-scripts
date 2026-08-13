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
	-- 那个回合的结束阶段时1次，可以从卡组把1张名字带有「武神」的魔法·陷阱卡加入手卡。
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
	-- 此外，这张卡在场上表侧表示存在，从自己手卡有名字带有「武神」的怪兽被送去自己墓地的场合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c53678698.regcon)
	e3:SetOperation(c53678698.regop)
	c:RegisterEffect(e3)
end
-- 判定送入墓地的怪兽是否满足：之前由自己控制、之前存在于我方主要怪兽区、是名字带有「武神」的兽战士族怪兽且被破坏送去墓地，用于特招效果的触发条件。
function c53678698.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR) and c:IsReason(REASON_DESTROY)
end
-- 检查本次送入墓地的怪兽群中是否存在至少1只满足上述条件的「武神」兽战士族怪兽，若存在则特招效果满足发动条件。
function c53678698.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53678698.cfilter,1,nil,tp)
end
-- 发动时判定：自己主要怪兽区有空位且此卡（手牌中的这张卡）能够被特殊召唤，才能发动特招效果。
function c53678698.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本连锁的操作信息，声明将特殊召唤这张卡，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特招效果处理：获取效果持有卡，若该卡仍与效果保持关联（未因离场等原因失去联系），则执行特殊召唤。
function c53678698.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 检索效果发动条件：检测这张卡是否带有53678698标记，即本回合是否发生过符合条件的手牌「武神」怪兽送入自己墓地。
function c53678698.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(53678698)>0
end
-- 定义检索对象：卡组中名字带有「武神」的魔法·陷阱卡，且能够被加入手卡。
function c53678698.filter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 检索效果发动时判定：检查卡组是否存在至少1张符合条件的「武神」魔陷，并设置操作信息。
function c53678698.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「武神」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c53678698.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，声明效果处理时将从卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：提示选择，从卡组选1张「武神」魔法·陷阱卡加入手卡并向对方展示。
function c53678698.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示消息，引导玩家进行卡组选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中筛选并选择1张符合条件的「武神」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c53678698.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，送入手卡的原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判定送入墓地的卡是否满足：当前控制者和之前控制者都是自己、之前在手牌、是名字带有「武神」的怪兽，用于确认“从自己手卡有名字带有「武神」的怪兽被送去自己墓地”。
function c53678698.rfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_HAND)
		and c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER)
end
-- 检查本次送入墓地的卡中是否存在至少1张满足上述手牌「武神」怪兽送墓条件的卡，若存在则触发登记标记。
function c53678698.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53678698.rfilter,1,nil,tp)
end
-- 为这张卡注册53678698标记，持续到结束阶段或离场等标准重置时机，用于结束阶段检索效果的发动资格记录。
function c53678698.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(53678698,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
