--竜魂の城
-- 效果：
-- ①：「龙魂之城」在自己场上只能有1张表侧表示存在。
-- ②：1回合1次，从自己墓地把1只龙族怪兽除外，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升700。
-- ③：表侧表示的这张卡从场上送去墓地时，以除外的1只自己的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
function c13513663.initial_effect(c)
	c:SetUniqueOnField(1,0,13513663)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从自己墓地把1只龙族怪兽除外，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升700。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13513663,0))  --"攻击上升"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1)
	e2:SetCost(c13513663.cost)
	e2:SetTarget(c13513663.target)
	e2:SetOperation(c13513663.operation)
	c:RegisterEffect(e2)
	-- ③：表侧表示的这张卡从场上送去墓地时，以除外的1只自己的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13513663,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c13513663.spcon)
	e3:SetTarget(c13513663.sptg)
	e3:SetOperation(c13513663.spop)
	c:RegisterEffect(e3)
end
-- 定义②效果代价的过滤函数：筛选自己墓地里满足龙族且可以作为代价除外的怪兽卡。
function c13513663.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToRemoveAsCost()
end
-- ②效果的代价处理：发动前检查墓地是否存在符合条件的龙族怪兽；发动时由玩家从墓地选择1只龙族怪兽除外作为代价。
function c13513663.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点（chk==0）检查自己墓地是否存在至少1只满足过滤条件的龙族怪兽，以此判断是否可以支付代价发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c13513663.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向发动玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让发动玩家从自己墓地选择1只满足过滤条件的龙族怪兽，作为将要除外的代价卡。
	local rg=Duel.SelectMatchingCard(tp,c13513663.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的龙族怪兽以表侧表示除外，完成效果的发动代价。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- ②效果的取对象处理：进行发动时选择自己场上1只表侧表示怪兽为对象；若为连锁中的对象合法性确认，则检查该卡是否为己方场上表侧表示怪兽。
function c13513663.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动时点检查自己场上是否存在至少1只表侧表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动玩家显示“请选择效果的对象”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让发动玩家选择自己场上1只表侧表示怪兽，并将其登记为这张卡效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：获取对象怪兽，若对象仍存在于场上、与效果关联且为表侧表示，则为其附加攻击力上升700的持续效果。
function c13513663.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这张卡发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时上升700。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ③效果的发动条件：这张卡从场上表侧表示状态被送去墓地。
function c13513663.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 定义③效果对象的过滤条件：选择除外区中表侧表示、种族为龙族且能够被特殊召唤的自己的怪兽。
function c13513663.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的取对象处理：需要自己主要怪兽区有空位，并从除外区的自己的龙族怪兽中选择1只作为特殊召唤对象；同时处理对象合法性确认。
function c13513663.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c13513663.spfilter(chkc,e,tp) end
	-- 在发动时点检查自己主要怪兽区是否存在可用空格，确保有特殊召唤的位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查除外区是否存在至少1只满足过滤条件且可以作为对象的自己的龙族怪兽。
		and Duel.IsExistingTarget(c13513663.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向发动玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动玩家从除外区选择1只满足过滤条件的自己的龙族怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c13513663.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 向系统登记本次效果含有特殊召唤操作，并指定要特殊召唤的卡组为已选择的对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果处理时：获取对象怪兽，若对象仍与效果关联，则将其以表侧表示特殊召唤到自己的主要怪兽区。
function c13513663.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取③效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到发动玩家的场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
