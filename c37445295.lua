--シャドール・ファルコン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合，以「影依猎鹰」以外的自己墓地1只「影依」怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
-- ②：这张卡被效果送去墓地的场合才能发动。这张卡里侧守备表示特殊召唤。
function c37445295.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡反转的场合，以「影依猎鹰」以外的自己墓地1只「影依」怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37445295,0))  --"特殊召唤「影依」怪兽"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,37445295)
	e1:SetTarget(c37445295.target)
	e1:SetOperation(c37445295.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡被效果送去墓地的场合才能发动。这张卡里侧守备表示特殊召唤。
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
-- 定义筛选函数：候选卡需为「影依」系列、不是「影依猎鹰」本身，且能够以里侧守备表示特殊召唤。
function c37445295.filter(c,e,tp)
	return c:IsSetCard(0x9d) and not c:IsCode(37445295) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 定义效果①的目标选择函数：若在连锁处理中指定对象，则校验该对象位于自己墓地、由自己控制且符合筛选条件；在发动时还需检查场上是否有空位以及墓地是否存在符合条件的对象。
function c37445295.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37445295.filter(chkc,e,tp) end
	-- 发动时检查自己主要怪兽区域是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时检查自己墓地是否存在至少1只符合筛选条件的「影依」怪兽可以作为对象。
		and Duel.IsExistingTarget(c37445295.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，提示其选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的「影依」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c37445295.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将进行1只怪兽的特殊召唤，目标为已选择的对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果①的处理函数：取得对象怪兽，若其仍与效果关联，则将其以里侧守备表示特殊召唤，并向对方玩家确认。
function c37445295.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以里侧守备表示特殊召唤到自己的主要怪兽区域。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 将特殊召唤成功的对象怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 定义效果②的发动条件：这张卡是被效果（REASON_EFFECT）送去墓地的。
function c37445295.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 定义效果②的发动条件检查：自己主要怪兽区域有空位，且这张卡自身能够以里侧守备表示特殊召唤。
function c37445295.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己主要怪兽区域是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置操作信息：本次效果将特殊召唤这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果②的处理函数：若这张卡仍与效果关联，则将其以里侧守备表示特殊召唤，并向对方玩家确认。
function c37445295.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡与效果的关联，并尝试将其以里侧守备表示特殊召唤；若特殊召唤成功则继续执行后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 将特殊召唤成功的这张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,c)
	end
end
