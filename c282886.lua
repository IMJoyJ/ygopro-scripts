--水精鱗－アビスノーズ
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，把手卡1只水属性怪兽丢弃去墓地才能发动。从卡组把1只名字带有「水精鳞」的怪兽表侧守备表示特殊召唤。「水精鳞-深渊象鼻鱼兵」的效果1回合只能使用1次。
function c282886.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽送去墓地时，把手卡1只水属性怪兽丢弃去墓地才能发动。从卡组把1只名字带有「水精鳞」的怪兽表侧守备表示特殊召唤。「水精鳞-深渊象鼻鱼兵」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(282886,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCountLimit(1,282886)
	-- 设置效果的发动条件：此卡与对方怪兽战斗并将其战斗破坏送去墓地时。
	e1:SetCondition(aux.bdogcon)
	e1:SetCost(c282886.spcost)
	e1:SetTarget(c282886.sptg)
	e1:SetOperation(c282886.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择手卡中水属性且可以作为代价丢弃去墓地的怪兽。
function c282886.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 发动代价函数：先检查手卡中是否有可丢弃的水属性怪兽，若有则选择1张丢弃去墓地作为代价。
function c282886.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认手卡存在至少1张满足水属性且可丢弃条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c282886.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手卡丢弃1只水属性怪兽去墓地作为发动代价。
	Duel.DiscardHand(tp,c282886.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤的过滤函数：选择卡组中名字带有「水精鳞」且可以表侧守备表示特殊召唤的怪兽。
function c282886.filter(c,e,tp)
	return c:IsSetCard(0x74) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动目标：确认自己主要怪兽区有空位，且卡组中存在满足特殊召唤条件的「水精鳞」怪兽。
function c282886.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在1只满足「水精鳞」字段且可特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c282886.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：若自己场上仍有空格，则从卡组选择1只「水精鳞」怪兽，以表侧守备表示特殊召唤到自己场上。
function c282886.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查主要怪兽区是否有空位，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「水精鳞」怪兽。
	local g=Duel.SelectMatchingCard(tp,c282886.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
