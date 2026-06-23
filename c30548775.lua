--ブランチ
-- 效果：
-- 融合怪兽在场上被破坏送去墓地时，可以把自己墓地存在的那只融合怪兽进行融合时所使用过的1只融合素材怪兽特殊召唤。
function c30548775.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发选发效果，用于在融合怪兽被破坏送去墓地时发动，将自己墓地的融合素材怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30548775,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c30548775.condition)
	e2:SetTarget(c30548775.target)
	e2:SetOperation(c30548775.operation)
	c:RegisterEffect(e2)
end
-- 筛选条件：怪兽从场上被破坏送去墓地，且为融合怪兽，且是融合召唤方式出场的。
function c30548775.filter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:IsType(TYPE_FUSION)
		and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 判断是否满足发动条件：连锁中存在满足filter条件的怪兽（即场上被破坏的融合怪兽）。
function c30548775.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30548775.filter,1,nil)
end
-- 筛选条件：怪兽的破坏原因为融合，且其破坏来源卡在连锁中出现过，且可以被特殊召唤。
function c30548775.spfilter(c,eg,e,tp)
	return c:IsReason(REASON_FUSION) and eg:IsContains(c:GetReasonCard()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标：选择自己墓地满足条件的1只怪兽作为特殊召唤对象。
function c30548775.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c30548775.spfilter(chkc,eg,e,tp) end
	-- 检查是否满足发动条件：玩家场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足发动条件：玩家墓地是否存在满足条件的怪兽。
		and Duel.IsExistingTarget(c30548775.spfilter,tp,LOCATION_GRAVE,0,1,nil,eg,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽作为效果目标。
	local g=Duel.SelectTarget(tp,c30548775.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,eg,e,tp)
	-- 设置效果处理信息：确定将要特殊召唤的怪兽数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将选择的怪兽特殊召唤到场上。
function c30548775.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
