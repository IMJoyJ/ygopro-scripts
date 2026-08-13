--サブテラーマリス・グライオース
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ③：这张卡反转的场合才能发动。从卡组选1张卡送去墓地。
function c1151281.initial_effect(c)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡反转的场合才能发动。从卡组选1张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1151281,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,1151281)
	e1:SetTarget(c1151281.target)
	e1:SetOperation(c1151281.operation)
	c:RegisterEffect(e1)
	-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1151281,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetCondition(c1151281.spcon)
	e2:SetTarget(c1151281.sptg)
	e2:SetOperation(c1151281.spop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1151281,2))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c1151281.postg)
	e3:SetOperation(c1151281.posop)
	c:RegisterEffect(e3)
end
-- ③效果反转时的发动·处理登记：检查卡组存在可送去墓地的卡，并设置从卡组送墓1张的操作信息。
function c1151281.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：若为发动前检查（chk==0），确认己方卡组存在至少1张能被效果送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次连锁的处理信息：效果类别为“送去墓地”，处理时从己方卡组把1张卡送去墓地（具体卡片在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ③效果的实际处理：从卡组选择1张卡并送去墓地。
function c1151281.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示，提示内容为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组中任意选择1张能被效果送去墓地的卡（处理时选卡，不取对象）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以“效果”为理由送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数：判定一只怪兽是否满足“自己场上的表侧表示怪兽变成里侧表示”：变更前是表侧表示、现在是里侧表示，且控制者为己方。
function c1151281.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown() and c:IsControler(tp)
end
-- ①效果的发动条件：本次表示形式变更的怪兽组中存在符合条件的自己怪兽，且自己场上没有表侧表示怪兽。
function c1151281.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c1151281.cfilter,1,nil,tp)
		-- 补充判定：自己场上不存在任何表侧表示怪兽。
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动合法性检查：自己主要怪兽区有空位、自己场上没有表侧表示怪兽，且这张卡在手牌能被正常特殊召唤。
function c1151281.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上不存在表侧表示怪兽。
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁的特殊召唤操作信息：将要把这张卡（效果持有者）特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：确认这张卡仍与效果关联后，将其从手牌以表侧守备表示特殊召唤。
function c1151281.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧守备表示特殊召唤到己方场上（按正常召唤条件与苏生限制检查）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动条件与使用次数登记：此卡可变为里侧守备表示且本回合尚未使用过同名②效果；发动时在本卡上登记同名效果使用标志，并设置变更表示形式的操作信息。
function c1151281.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(1151281)==0 end
	c:RegisterFlagEffect(1151281,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 登记本次效果将改变这张卡表示形式的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- ②效果的处理：若这张卡仍与效果关联且为表侧表示，就将其变为里侧守备表示。
function c1151281.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡的表示形式变更为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
