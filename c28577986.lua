--水精鱗－オーケアビス
-- 效果：
-- 自己的主要阶段时，选择自己场上1只名字带有「水精鳞」的怪兽才能发动。等级合计最多到选择的怪兽的等级以下为止，从卡组把4星以下的名字带有「水精鳞」的怪兽任意数量特殊召唤。那之后，选择的怪兽送去墓地。「水精鳞-深渊水仙女」的效果1回合只能使用1次。
function c28577986.initial_effect(c)
	-- 效果原文内容：自己的主要阶段时，选择自己场上1只名字带有「水精鳞」的怪兽才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(28577986,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,28577986)
	e1:SetTarget(c28577986.target)
	e1:SetOperation(c28577986.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查场上是否存在满足条件的「水精鳞」怪兽，且其等级大于0且正面表示，并且卡组中存在满足条件的可特殊召唤的「水精鳞」怪兽。
function c28577986.cfilter(c,e,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsFaceup() and c:IsSetCard(0x74)
		-- 规则层面作用：检查卡组中是否存在满足等级限制和种族条件的「水精鳞」怪兽。
		and Duel.IsExistingMatchingCard(c28577986.spfilter,tp,LOCATION_DECK,0,1,nil,lv,e,tp)
end
-- 规则层面作用：定义特殊召唤的「水精鳞」怪兽的等级上限和种族条件。
function c28577986.spfilter(c,lv,e,tp)
	if lv>4 then lv=4 end
	return c:IsLevelBelow(lv) and c:IsSetCard(0x74) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果原文内容：选择自己场上1只名字带有「水精鳞」的怪兽才能发动。
function c28577986.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c28577986.cfilter(chkc,e,tp) end
	-- 规则层面作用：检查玩家场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查场上是否存在满足条件的「水精鳞」怪兽。
		and Duel.IsExistingTarget(c28577986.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 规则层面作用：提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 规则层面作用：选择满足条件的「水精鳞」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c28577986.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 规则层面作用：设置效果操作信息，表示将要将目标怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 规则层面作用：设置效果操作信息，表示将要从卡组特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：定义选择特殊召唤怪兽时的等级总和限制条件。
function c28577986.gselect(g,slv)
	return g:GetSum(Card.GetLevel)<=slv
end
-- 效果原文内容：等级合计最多到选择的怪兽的等级以下为止，从卡组把4星以下的名字带有「水精鳞」的怪兽任意数量特殊召唤。那之后，选择的怪兽送去墓地。
function c28577986.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 规则层面作用：获取玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local slv=tc:GetLevel()
	-- 规则层面作用：获取满足等级限制和种族条件的可特殊召唤的「水精鳞」怪兽组。
	local sg=Duel.GetMatchingGroup(c28577986.spfilter,tp,LOCATION_DECK,0,nil,slv,e,tp)
	if sg:GetCount()==0 then return end
	-- 规则层面作用：提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tg=sg:SelectSubGroup(tp,c28577986.gselect,false,1,ft,slv)
	-- 规则层面作用：将满足条件的怪兽组特殊召唤到场上。
	Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	-- 规则层面作用：中断当前效果处理，使后续处理视为不同时处理。
	Duel.BreakEffect()
	-- 规则层面作用：将目标怪兽送去墓地。
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
