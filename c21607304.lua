--サブテラーマリス・ボルティニア
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ③：这张卡反转的场合，以对方场上1只里侧表示怪兽为对象才能发动。那只怪兽的控制权直到下次的自己结束阶段得到。
function c21607304.initial_effect(c)
	-- “这个卡名的③的效果1回合只能使用1次。③：这张卡反转的场合，以对方场上1只里侧表示怪兽为对象才能发动。那只怪兽的控制权直到下次的自己结束阶段得到。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21607304,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,21607304)
	e1:SetTarget(c21607304.target)
	e1:SetOperation(c21607304.operation)
	c:RegisterEffect(e1)
	-- “①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21607304,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetCondition(c21607304.spcon)
	e2:SetTarget(c21607304.sptg)
	e2:SetOperation(c21607304.spop)
	c:RegisterEffect(e2)
	-- “②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。”
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21607304,2))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c21607304.postg)
	e3:SetOperation(c21607304.posop)
	c:RegisterEffect(e3)
end
-- ③效果选择对象的过滤条件：对象必须是里侧表示怪兽，且其控制权可以被改变。
function c21607304.filter(c)
	return c:IsFacedown() and c:IsControlerCanBeChanged()
end
-- ③效果的发动目标函数：检查对方场上是否存在可选的里侧表示怪兽，有则选择1只作为对象，并登记改变控制权的操作信息。
function c21607304.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c21607304.filter(chkc) end
	-- ③效果发动时点检查：对方怪兽区是否存在至少1只可被选择且满足filter条件的里侧表示怪兽，有才能发动。
	if chk==0 then return Duel.IsExistingTarget(c21607304.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，内容为“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让当前玩家从对方怪兽区选择1只满足filter条件的里侧表示怪兽作为效果对象，并自动将其登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c21607304.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的处理信息：将改变控制权的对象设为刚刚选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- ③效果处理函数开头：取得对象怪兽，并根据当前回合与阶段计算控制权归还所需的结束阶段次数。
function c21607304.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得③效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local tct=1
	-- 如果当前不是自己的回合，则需要经过两次结束阶段才到下次自己的结束阶段，因此归还次数设为2。
	if Duel.GetTurnPlayer()~=tp then tct=2
	-- 如果当前正处于自己的结束阶段，则将归还次数设为3，以让控制权持续到下次自己的结束阶段。
	elseif Duel.GetCurrentPhase()==PHASE_END then tct=3 end
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽的控制权转移给自己，并设定在结束阶段经过tct次后归还给原控制者。
		Duel.GetControl(tc,tp,PHASE_END,tct)
	end
end
-- ①效果触发的辅助过滤：判定事件中的怪兽是否从表侧表示变成了里侧表示，且控制权属于自己。
function c21607304.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown() and c:IsControler(tp)
end
-- ①效果的发动条件：本回合有自己场上的表侧表示怪兽变成里侧表示，且自己场上没有表侧表示怪兽存在。
function c21607304.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21607304.cfilter,1,nil,tp)
		-- 同时要求自己场上没有表侧表示怪兽存在。
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动时点判定：自己主要怪兽区有空位、自己场上无表侧表示怪兽，且这张卡可以以表侧守备表示从手卡特殊召唤。
function c21607304.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ①效果发动时点检查：自己主要怪兽区存在可使用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己场上不存在表侧表示怪兽。
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置本连锁的处理信息：将这张卡从手卡特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其以表侧守备表示特殊召唤到自己场上。
function c21607304.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧守备表示特殊召唤到己方场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果发动条件检查：这张卡可以变成里侧守备表示且本回合未使用过②效果；通过后登记1回合1次的标记，并设置变为里侧守备表示的操作信息。
function c21607304.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(21607304)==0 end
	c:RegisterFlagEffect(21607304,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置本连锁的处理信息：将这张卡的位置变更为里侧守备表示，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- ②效果处理：若这张卡仍在场上且表侧表示，则将其变成里侧守备表示。
function c21607304.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡的表示形式变成里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
