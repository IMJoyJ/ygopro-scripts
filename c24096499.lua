--森の聖獣 ヴァレリフォーン
-- 效果：
-- 「森之圣兽 缬草小鹿」的效果1回合只能使用1次。
-- ①：丢弃1张手卡，以「森之圣兽 缬草小鹿」以外的自己墓地1只2星以下的兽族怪兽为对象才能发动。那只怪兽表侧攻击表示或者里侧守备表示特殊召唤。
function c24096499.initial_effect(c)
	-- 效果原文内容：「森之圣兽 缬草小鹿」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24096499,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,24096499)
	e1:SetCost(c24096499.spcost)
	e1:SetTarget(c24096499.sptg)
	e1:SetOperation(c24096499.spop)
	c:RegisterEffect(e1)
end
-- 效果作用：支付1张手卡丢弃作为代价
function c24096499.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家手牌是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 效果作用：令玩家丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果作用：定义可特殊召唤的墓地怪兽筛选条件
function c24096499.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_BEAST) and not c:IsCode(24096499) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 效果作用：设置效果的发动条件与目标选择
function c24096499.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24096499.filter(chkc,e,tp) end
	-- 效果作用：检查玩家场上是否存在可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查玩家墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c24096499.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：向玩家发送选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c24096499.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 效果作用：设置连锁操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用：执行特殊召唤操作并确认对方是否能看到里侧表示的怪兽
function c24096499.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查玩家场上是否还有可用怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：获取当前连锁效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 效果作用：将目标怪兽特殊召唤到场上
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)>0
		and tc:IsFacedown() then
		-- 效果作用：向对方确认特殊召唤的里侧表示怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
