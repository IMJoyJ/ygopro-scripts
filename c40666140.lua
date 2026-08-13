--極星霊リョースアールヴ
-- 效果：
-- 这张卡召唤成功时，选择这张卡以外的自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽的等级以下的1只名字带有「极星」的怪兽从手卡特殊召唤。
function c40666140.initial_effect(c)
	-- 这张卡召唤成功时，选择这张卡以外的自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽的等级以下的1只名字带有「极星」的怪兽从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40666140,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c40666140.sptg)
	e1:SetOperation(c40666140.spop)
	c:RegisterEffect(e1)
end
-- 定义取对象的过滤函数：候选对象必须是表侧表示、等级大于0，且手牌中存在至少1只名字带有「极星」、等级不高于该对象等级并可以被特殊召唤的怪兽。
function c40666140.filter(c,e,tp)
	local lv=c:GetLevel()
	-- 检查该怪兽是否表侧表示且等级大于0，同时手牌中存在符合条件的「极星」怪兽可供特殊召唤。
	return c:IsFaceup() and lv>0 and Duel.IsExistingMatchingCard(c40666140.filter2,tp,LOCATION_HAND,0,1,nil,lv,e,tp)
end
-- 定义手牌中可特殊召唤的「极星」怪兽的过滤条件：必须名字带有「极星」、等级不高于指定等级，且满足特殊召唤条件。
function c40666140.filter2(c,lv,e,tp)
	return c:IsSetCard(0x42) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性判定：如果正在确认对象，则检查该对象是否位于自己场上且满足filter条件；如果是发动时检查，则需满足主要怪兽区有空位且存在合法对象。
function c40666140.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40666140.filter(chkc,e,tp) end
	-- 发动条件之一：自己主要怪兽区必须至少存在1个空位，以供后续特殊召唤使用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己场上必须存在至少1只满足filter条件（表侧表示、等级>0且手牌有可特殊召唤的「极星」怪兽）的怪兽，可以作为取对象目标。
		and Duel.IsExistingTarget(c40666140.filter,tp,LOCATION_MZONE,0,1,e:GetHandler(),e,tp) end
	-- 向玩家发送选择提示，要求其从场上选择1张表侧表示怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己主要怪兽区选择1只满足filter条件的怪兽作为效果对象，并通过SelectTarget将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c40666140.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),e,tp)
	-- 设置操作信息，表明本次效果将从手牌特殊召唤1只怪兽（数量为1，位置为手牌，属于特殊召唤类别）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时：若自己主要怪兽区没有空位则直接终止；获取对象并确认其仍与效果相关且表侧表示；然后让玩家从手牌中选择1只满足条件的「极星」怪兽，以表侧表示特殊召唤到自己的主要怪兽区。
function c40666140.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时检查：如果自己主要怪兽区没有空余区域，则无法特殊召唤，整个效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取出发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 向玩家发送选择提示，要求其从手牌中选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中筛选并选择1只名字带有「极星」、等级不高于对象怪兽等级且满足特殊召唤条件的怪兽。
	local sg=Duel.SelectMatchingCard(tp,c40666140.filter2,tp,LOCATION_HAND,0,1,1,nil,tc:GetLevel(),e,tp)
	if sg:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的主要怪兽区，不检查召唤条件与苏生限制（因为是效果处理时的特殊召唤）。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
