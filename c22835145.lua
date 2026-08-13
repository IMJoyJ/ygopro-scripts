--BF－極北のブリザード
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤成功时，以自己墓地1只4星以下的「黑羽」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c22835145.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的判定值固定为 false，使该卡永远无法满足特殊召唤条件，从而实现“不能特殊召唤”。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时，以自己墓地1只4星以下的「黑羽」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22835145,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c22835145.target)
	e2:SetOperation(c22835145.operation)
	c:RegisterEffect(e2)
end
-- 效果对象的过滤函数：筛选自己墓地中等级4以下、卡名含「黑羽」字段，且能够以表侧守备表示特殊召唤的怪兽。
function c22835145.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x33) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的目标选择处理：验证指定对象是否合法；同时确认发动条件是否满足（自己场上怪兽区有空位，且墓地存在至少1只符合条件的「黑羽」怪兽）。
function c22835145.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c22835145.filter(chkc,e,tp) end
	-- 检查自己场上主要怪兽区是否有可用的空格；若没有空格则效果不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足过滤条件的「黑羽」怪兽，并且该怪兽能成为此效果的对象。
		and Duel.IsExistingTarget(c22835145.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示，以便后续从墓地选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的「黑羽」怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c22835145.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本连锁的操作信息为特殊召唤1只怪兽，便于其他卡的效果（如星尘龙等）进行响应与判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：在结算时若自己场上仍有空位，则取得之前选择的目标怪兽，确认其与效果仍有关联后，将其以表侧守备表示特殊召唤到自己场上。
function c22835145.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次确认自己场上主要怪兽区是否有空位；若无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得本次效果发动时选择的目标怪兽（墓地中的「黑羽」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
