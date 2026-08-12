--奇跡の代行者 ジュピター
-- 效果：
-- ①：1回合1次，从自己墓地把1只「代行者」怪兽除外，以自己场上1只天使族·光属性怪兽为对象才能发动。那只自己的天使族·光属性怪兽的攻击力直到回合结束时上升800。
-- ②：1回合1次，从手卡丢弃1只天使族怪兽，以除外的1只自己的天使族·光属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在场上有「天空的圣域」存在的场合才能发动和处理。
function c28573958.initial_effect(c)
	-- 注册此卡具有「代行者」卡名的代码列表
	aux.AddCodeList(c,56433456)
	-- ①：1回合1次，从自己墓地把1只「代行者」怪兽除外，以自己场上1只天使族·光属性怪兽为对象才能发动。那只自己的天使族·光属性怪兽的攻击力直到回合结束时上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28573958,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c28573958.atcost)
	e1:SetTarget(c28573958.attg)
	e1:SetOperation(c28573958.atop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从手卡丢弃1只天使族怪兽，以除外的1只自己的天使族·光属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在场上有「天空的圣域」存在的场合才能发动和处理。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28573958,1))  --"除外怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c28573958.spcon)
	e2:SetCost(c28573958.spcost)
	e2:SetTarget(c28573958.sptg)
	e2:SetOperation(c28573958.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查墓地是否有「代行者」怪兽且可作为除外的代价
function c28573958.cfilter1(c)
	return c:IsSetCard(0x44) and c:IsAbleToRemoveAsCost()
end
-- 效果处理：检查是否有满足条件的墓地「代行者」怪兽，若有则选择并除外
function c28573958.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外「代行者」怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c28573958.cfilter1,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张墓地「代行者」怪兽
	local g=Duel.SelectMatchingCard(tp,c28573958.cfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽除外作为效果的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数：检查场上是否为表侧表示的天使族·光属性怪兽
function c28573958.filter1(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)
end
-- 效果处理：检查是否有满足条件的场上天使族·光属性怪兽，若有则选择作为对象
function c28573958.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28573958.filter1(chkc) end
	-- 检查是否满足选择场上天使族·光属性怪兽的条件
	if chk==0 then return Duel.IsExistingTarget(c28573958.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1张场上天使族·光属性怪兽
	Duel.SelectTarget(tp,c28573958.filter1,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：为选中的怪兽在回合结束时增加800攻击力
function c28573958.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 为选中的怪兽增加800攻击力的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 效果条件：检查场上有「天空的圣域」存在
function c28573958.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上有「天空的圣域」存在
	return Duel.IsEnvironment(56433456)
end
-- 过滤函数：检查手卡是否有天使族怪兽且可作为丢弃的代价
function c28573958.cfilter2(c)
	return c:IsRace(RACE_FAIRY) and c:IsDiscardable()
end
-- 效果处理：检查是否有满足条件的天使族怪兽，若有则选择并丢弃
function c28573958.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃天使族怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c28573958.cfilter2,tp,LOCATION_HAND,0,1,nil) end
	-- 将选中的天使族怪兽丢弃作为效果的代价
	Duel.DiscardHand(tp,c28573958.cfilter2,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：检查除外的怪兽是否为表侧表示的天使族·光属性怪兽且可特殊召唤
function c28573958.filter2(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：检查是否有满足条件的除外天使族·光属性怪兽，若有则选择作为对象
function c28573958.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c28573958.filter2(chkc,e,tp) end
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有满足条件的除外天使族·光属性怪兽
		and Duel.IsExistingTarget(c28573958.filter2,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1张除外天使族·光属性怪兽
	local g=Duel.SelectTarget(tp,c28573958.filter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若场上有「天空的圣域」则将选中的怪兽特殊召唤
function c28573958.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上有「天空的圣域」存在
	if not Duel.IsEnvironment(56433456) then return end
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
