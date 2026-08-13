--森の聖獣 ヴァレリフォーン
-- 效果：
-- 「森之圣兽 缬草小鹿」的效果1回合只能使用1次。
-- ①：丢弃1张手卡，以「森之圣兽 缬草小鹿」以外的自己墓地1只2星以下的兽族怪兽为对象才能发动。那只怪兽表侧攻击表示或者里侧守备表示特殊召唤。
function c24096499.initial_effect(c)
	-- 「森之圣兽 缬草小鹿」的效果1回合只能使用1次。①：丢弃1张手卡，以「森之圣兽 缬草小鹿」以外的自己墓地1只2星以下的兽族怪兽为对象才能发动。那只怪兽表侧攻击表示或者里侧守备表示特殊召唤。
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
-- 发动代价处理函数：先检查手牌是否有可丢弃的卡，然后从手牌选择1张丢弃作为代价。
function c24096499.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认自己手牌中存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手牌挑选1张卡以代价+丢弃的理由丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 对象筛选条件：该卡为2星以下、兽族、卡名不是「森之圣兽 缬草小鹿」，且能够以表侧攻击表示或里侧守备表示进行特殊召唤。
function c24096499.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_BEAST) and not c:IsCode(24096499) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 取对象及发动合法判定：若指定对象，则验证其位于自己墓地且满足条件；若无对象，则确认自己场上留有可用怪兽区且墓地存在满足条件的对象。
function c24096499.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24096499.filter(chkc,e,tp) end
	-- 确认自己主要怪兽区还有空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地存在满足条件且可以作为效果对象的怪兽。
		and Duel.IsExistingTarget(c24096499.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向发动玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动玩家从自己墓地的符合条件的怪兽中选择1只，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c24096499.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次效果处理的信息：将选中的对象怪兽用于特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：若场上仍有可用怪兽区，则取回对象怪兽进行特殊召唤；若以里侧守备表示特殊召唤成功，则向对方确认该怪兽。
function c24096499.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查主要怪兽区是否有空格，若无空格则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得本次效果选择的怪兽对象。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与该效果关联后，将其以表侧攻击表示或里侧守备表示特殊召唤；若特殊召唤成功且对象为里侧守备表示，则继续执行后续确认。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)>0
		and tc:IsFacedown() then
		-- 向对手玩家展示被里侧守备表示特殊召唤的怪兽，以确认其信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
