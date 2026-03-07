--シャドール・ファルコン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合，以「影依猎鹰」以外的自己墓地1只「影依」怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
-- ②：这张卡被效果送去墓地的场合才能发动。这张卡里侧守备表示特殊召唤。
function c37445295.initial_effect(c)
	-- ①：这张卡反转的场合，以「影依猎鹰」以外的自己墓地1只「影依」怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37445295,0))  --"特殊召唤「影依」怪兽"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,37445295)
	e1:SetTarget(c37445295.target)
	e1:SetOperation(c37445295.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。这张卡里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37445295,1))  --"特殊召唤这张卡"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,37445295)
	e2:SetCondition(c37445295.spcon)
	e2:SetTarget(c37445295.sptg)
	e2:SetOperation(c37445295.spop)
	c:RegisterEffect(e2)
	c37445295.shadoll_flip_effect=e1
end
-- 过滤满足条件的「影依」怪兽，排除自身，且可以特殊召唤
function c37445295.filter(c,e,tp)
	return c:IsSetCard(0x9d) and not c:IsCode(37445295) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 判断是否满足发动条件，检查场上是否有空位并确认墓地是否存在符合条件的怪兽
function c37445295.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37445295.filter(chkc,e,tp) end
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c37445295.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c37445295.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果，将目标怪兽特殊召唤并确认对方可见
function c37445295.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以里侧守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方确认特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 判断是否因效果送入墓地
function c37445295.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 判断是否满足发动条件，检查场上是否有空位并确认自身可以特殊召唤
function c37445295.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置操作信息，确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行效果，将自身以里侧守备表示特殊召唤并确认对方可见
function c37445295.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否可以特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 向对方确认特殊召唤的卡
		Duel.ConfirmCards(1-tp,c)
	end
end
