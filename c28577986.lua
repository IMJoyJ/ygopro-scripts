--水精鱗－オーケアビス
-- 效果：
-- 自己的主要阶段时，选择自己场上1只名字带有「水精鳞」的怪兽才能发动。等级合计最多到选择的怪兽的等级以下为止，从卡组把4星以下的名字带有「水精鳞」的怪兽任意数量特殊召唤。那之后，选择的怪兽送去墓地。「水精鳞-深渊水仙女」的效果1回合只能使用1次。
function c28577986.initial_effect(c)
	-- 对应效果原文：自己的主要阶段时，选择自己场上1只名字带有「水精鳞」的怪兽才能发动。等级合计最多到选择的怪兽的等级以下为止，从卡组把4星以下的名字带有「水精鳞」的怪兽任意数量特殊召唤。那之后，选择的怪兽送去墓地。「水精鳞-深渊水仙女」的效果1回合只能使用1次。
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
-- 对象候选的过滤函数：判定怪兽是否满足作为效果对象的条件——表侧表示且名字带有「水精鳞」，并且卡组中存在1张以上以该怪兽等级为上限、可被特殊召唤的水精鳞怪兽，以保证效果能够处理。
function c28577986.cfilter(c,e,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsFaceup() and c:IsSetCard(0x74)
		-- 同时检查卡组中是否存在至少1张等级不超过对象怪兽等级（超过4则按4计）的水精鳞怪兽且能够被特殊召唤，若不存在则不能发动。
		and Duel.IsExistingMatchingCard(c28577986.spfilter,tp,LOCATION_DECK,0,1,nil,lv,e,tp)
end
-- 特召怪兽的过滤函数：卡组中的怪兽必须满足等级在对象怪兽等级以下（对象等级超过4时按4计）、名字带有「水精鳞」、且可以被当前效果特殊召唤。
function c28577986.spfilter(c,lv,e,tp)
	if lv>4 then lv=4 end
	return c:IsLevelBelow(lv) and c:IsSetCard(0x74) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标选择与合法性判定：若在连锁处理中指定对象，则校验该卡是否为自己场上的合法水精鳞怪兽；若为发动时检查，则确认自己场上有合法对象且主要怪兽区有空位。
function c28577986.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c28577986.cfilter(chkc,e,tp) end
	-- 发动条件判定：自己主要怪兽区必须至少有1个可用空格，否则无法从卡组特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己场上必须存在至少1只满足cfilter条件的水精鳞怪兽，可以作为效果对象。
		and Duel.IsExistingTarget(c28577986.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 弹出选择提示：请玩家选择要送去墓地的卡（即对象怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1只满足条件的水精鳞怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c28577986.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果的“送去墓地”部分确定为1张卡（对象怪兽），以便其他卡进行时点响应。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置操作信息：本次效果的“特殊召唤”部分来自卡组，数量不定（至少1只），用于满足星尘龙等卡片的发动条件检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 选卡结束条件：玩家已选择的一组特召怪兽的等级合计不得超过对象怪兽的等级slv，否则需要继续选择或减少数量。
function c28577986.gselect(g,slv)
	return g:GetSum(Card.GetLevel)<=slv
end
-- 效果处理流程：确认对象仍与效果关联且自己有特召空位（若青眼精灵龙效果适用则特召上限为1）；从卡组筛选出所有可特召的水精鳞怪兽，让玩家选择等级合计不超过对象等级的任意数量进行表侧表示特殊召唤；随后中断连锁处理，将对象怪兽送去墓地。
function c28577986.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 计算自己主要怪兽区剩余可用格子数，用于限制本次特殊召唤的数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local slv=tc:GetLevel()
	-- 从卡组中筛选出所有满足spfilter条件（等级不超过对象等级且最多4星、名字带有「水精鳞」、可被特殊召唤）的怪兽，作为待选集合。
	local sg=Duel.GetMatchingGroup(c28577986.spfilter,tp,LOCATION_DECK,0,nil,slv,e,tp)
	if sg:GetCount()==0 then return end
	-- 弹出选择提示：请玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tg=sg:SelectSubGroup(tp,c28577986.gselect,false,1,ft,slv)
	-- 将玩家选定的怪兽以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	-- 中断当前效果，使特殊召唤与随后的送去墓地处理在时点上分离，避免卡时点。
	Duel.BreakEffect()
	-- 将对象怪兽因该效果送去墓地。
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
