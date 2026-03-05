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
-- 过滤函数，检查自己墓地是否存在满足条件的龙族怪兽（可作为除外的代价）
function c13513663.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的处理：检索满足条件的龙族怪兽并除外作为代价
function c13513663.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1张满足条件的龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c13513663.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择满足条件的1张龙族怪兽从墓地除外
	local rg=Duel.SelectMatchingCard(tp,c13513663.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以正面表示形式除外作为发动代价
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 效果发动时选择对象：选择自己场上1只表侧表示怪兽作为对象
function c13513663.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查自己场上是否存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择自己场上1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使目标怪兽的攻击力上升700点直到回合结束
function c13513663.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽的攻击力上升700点直到回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判断此卡是否从场上以正面表示形式送去墓地
function c13513663.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 过滤函数，检查目标是否为龙族且可特殊召唤
function c13513663.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理：检索满足条件的除外龙族怪兽并选择作为对象
function c13513663.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c13513663.spfilter(chkc,e,tp) end
	-- 检查玩家场上是否有可用空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己除外区是否存在至少1只满足条件的龙族怪兽
		and Duel.IsExistingTarget(c13513663.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家提示“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的1只除外龙族怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c13513663.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：确定特殊召唤的卡和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选中的除外龙族怪兽特殊召唤到场上
function c13513663.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
