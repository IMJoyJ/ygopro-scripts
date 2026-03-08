--サブテラーマリス・リグリアード
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ③：这张卡反转的场合，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
function c42713844.initial_effect(c)
	-- ③：这张卡反转的场合，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
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
-- 选择对方场上1只可以除外的怪兽作为对象
function c42713844.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 检查对方场上是否存在可以除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只可以除外的怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，确定将要除外的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 将选中的怪兽除外
function c42713844.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断是否为表侧表示变为里侧表示的怪兽
function c42713844.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown() and c:IsControler(tp)
end
-- 判断是否满足①效果的发动条件
function c42713844.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c42713844.cfilter,1,nil,tp)
		-- 检查自己场上是否没有表侧表示的怪兽
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
-- 检查是否满足①效果的发动条件
function c42713844.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否没有表侧表示的怪兽
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置效果处理信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 将自己从手卡特殊召唤到场上
function c42713844.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自己从手卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置②效果的处理信息
function c42713844.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(42713844)==0 end
	c:RegisterFlagEffect(42713844,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置效果处理信息，确定将要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 将自己变成里侧守备表示
function c42713844.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自己变成里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
