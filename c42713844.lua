--サブテラーマリス・リグリアード
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ③：这张卡反转的场合，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
function c42713844.initial_effect(c)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡反转的场合，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42713844,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,42713844)
	e1:SetTarget(c42713844.rmtg)
	e1:SetOperation(c42713844.rmop)
	c:RegisterEffect(e1)
	-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42713844,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetCondition(c42713844.spcon)
	e2:SetTarget(c42713844.sptg)
	e2:SetOperation(c42713844.spop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42713844,2))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c42713844.postg)
	e3:SetOperation(c42713844.posop)
	c:RegisterEffect(e3)
end
-- ③效果的发动时处理：从对方场上选择1只可除外的怪兽作为对象，并设置除外操作信息。
function c42713844.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 效果发动合法性检查：对方场上是否存在1只可以被除外的怪兽（作为取对象的前提）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作者显示“请选择要除外的卡”的提示信息，用于选择对象的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 令操作者从对方场上选择1只可除外的怪兽，并将其登记为这张卡发动效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将当前连锁的操作信息设置为“除外1张卡”，对象为已选择的怪兽，供后续处理及其他卡的效果参考。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ③效果的处理：取出效果对象，若该对象仍与效果相关联，则将其以表侧表示除外。
function c42713844.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示除外（这是③效果的除外处理）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判定怪兽是否满足“由表侧表示变成里侧表示”且是自己场上的怪兽，用于①效果的触发条件。
function c42713844.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown() and c:IsControler(tp)
end
-- ①效果的发动条件：本次表示形式变更的卡中，存在自己场上从表侧变成里侧的怪兽，并且自己场上没有表侧表示怪兽。
function c42713844.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c42713844.cfilter,1,nil,tp)
		-- 自己场上不存在表侧表示怪兽（①效果的追加条件）。
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果发动合法性检查：自己主要怪兽区有空位、自己场上没有表侧表示怪兽，且这张卡能够以表侧守备表示特殊召唤。
function c42713844.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区，用于从手卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 自己场上没有表侧表示怪兽（①效果的必须条件）。
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 将当前连锁的操作信息设置为“特殊召唤1只怪兽”，对象为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：若这张卡仍与效果关联，则将其以表侧守备表示特殊召唤。
function c42713844.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧守备表示特殊召唤到自己的主要怪兽区。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动条件与处理准备：本卡可以变为里侧守备表示且本回合尚未使用过②效果（用标志限制1回合1次），满足后登记这个回合的使用标志，并设置表示形式变更的操作信息。
function c42713844.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(42713844)==0 end
	c:RegisterFlagEffect(42713844,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置当前连锁的操作信息为“改变表示形式”，对象为本卡。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- ②效果的处理：若这张卡仍与效果关联且为表侧表示，则将其变为里侧守备表示。
function c42713844.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡的表示形式变为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
