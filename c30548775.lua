--ブランチ
-- 效果：
-- 融合怪兽在场上被破坏送去墓地时，可以把自己墓地存在的那只融合怪兽进行融合时所使用过的1只融合素材怪兽特殊召唤。
function c30548775.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 融合怪兽在场上被破坏送去墓地时，可以把自己墓地存在的那只融合怪兽进行融合时所使用过的1只融合素材怪兽特殊召唤。
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
-- 过滤函数：判定进入墓地的怪兽是否满足“从场上被破坏送去墓地、是融合怪兽且以融合召唤方式召唤过”，用于确定触发条件发生时是否有符合条件的融合怪兽。
function c30548775.filter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:IsType(TYPE_FUSION)
		and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 触发条件：本效果只在对方或自己场上的融合怪兽被破坏并送去墓地时才能发动，即事件组中存在至少1张满足filter条件的融合怪兽。
function c30548775.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30548775.filter,1,nil)
end
-- 筛选素材：候选卡必须是因为那次融合召唤而被送去墓地的融合素材（原因含有REASON_FUSION，且其导致进墓地的融合怪兽正是事件组中的那只），并且该候选卡可以被当前效果特殊召唤。
function c30548775.spfilter(c,eg,e,tp)
	return c:IsReason(REASON_FUSION) and eg:IsContains(c:GetReasonCard()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 取对象效果的目标处理：选择对象时，对象必须是我方墓地、满足spfilter的卡；发动时（chk==0）则检查我方怪兽区有空位且墓地存在1张可特殊召唤的融合素材。
function c30548775.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c30548775.spfilter(chkc,eg,e,tp) end
	-- 发动条件之一：我方主要怪兽区必须存在空位，以容纳后续特殊召唤的素材。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：我方墓地必须存在至少1张满足spfilter的融合素材怪兽，作为可选择的特殊召唤对象。
		and Duel.IsExistingTarget(c30548775.spfilter,tp,LOCATION_GRAVE,0,1,nil,eg,e,tp) end
	-- 显示选择提示：在玩家选择特殊召唤的卡之前，弹出“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 取对象：让玩家从我方墓地选择1张满足spfilter条件的融合素材怪兽，作为本效果发动时的对象卡（同时建立与效果的关联）。
	local g=Duel.SelectTarget(tp,c30548775.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,eg,e,tp)
	-- 登记操作信息：声明本连锁处理将进行1只怪兽的特殊召唤，对象为已选素材，供其他卡的效果（如星尘龙、王家长眠之谷）进行发动检测或应对。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：从我方墓地特殊召唤所选的融合素材怪兽；若对象卡已因其他效果离场或不再与本效果关联，则不处理。
function c30548775.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的那个对象卡（本效果只选1张，所以用GetFirstTarget获取）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标素材以表侧表示特殊召唤到己方场上（sumtype=0表示视为效果特殊召唤，不检查召唤条件，不限制苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
