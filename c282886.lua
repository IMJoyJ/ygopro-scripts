--水精鱗－アビスノーズ
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，把手卡1只水属性怪兽丢弃去墓地才能发动。从卡组把1只名字带有「水精鳞」的怪兽表侧守备表示特殊召唤。「水精鳞-深渊象鼻鱼兵」的效果1回合只能使用1次。
function c282886.initial_effect(c)
	-- 创建一个诱发选发效果，用于处理战斗破坏对方怪兽时的特殊召唤效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(282886,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCountLimit(1,282886)
	-- 设置该效果的发动条件为：自己怪兽与对方怪兽战斗并破坏对方怪兽送去墓地
	e1:SetCondition(aux.bdogcon)
	e1:SetCost(c282886.spcost)
	e1:SetTarget(c282886.sptg)
	e1:SetOperation(c282886.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断手牌中是否存在满足条件的水属性怪兽（可丢弃）
function c282886.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 效果的发动费用：丢弃手牌中1只水属性怪兽
function c282886.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1只水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c282886.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手牌中1只水属性怪兽的操作
	Duel.DiscardHand(tp,c282886.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于从卡组中检索名字带有「水精鳞」的怪兽
function c282886.filter(c,e,tp)
	return c:IsSetCard(0x74) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果的目标为从卡组特殊召唤1只名字带有「水精鳞」的怪兽
function c282886.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只名字带有「水精鳞」的怪兽
		and Duel.IsExistingMatchingCard(c282886.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果的发动处理，从卡组选择1只名字带有「水精鳞」的怪兽特殊召唤
function c282886.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只名字带有「水精鳞」的怪兽
	local g=Duel.SelectMatchingCard(tp,c282886.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
