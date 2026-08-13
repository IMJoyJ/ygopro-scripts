--光の導き
-- 效果：
-- ①：自己场上没有其他的「光之引导」存在，自己墓地有「青眼」怪兽3只以上存在的场合，以那之内的1只为对象才能把这张卡发动。那只怪兽效果无效特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽除外。
-- ②：装备怪兽以外的自己怪兽不能攻击，自己墓地有「青眼」怪兽存在的场合，装备怪兽在同1次的战斗阶段中可以作出最多有那个数量的攻击。
function c50371210.initial_effect(c)
	-- ①：自己场上没有其他的「光之引导」存在，自己墓地有「青眼」怪兽3只以上存在的场合，以那之内的1只为对象才能把这张卡发动。那只怪兽效果无效特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c50371210.target)
	e1:SetOperation(c50371210.operation)
	c:RegisterEffect(e1)
	-- ②：自己墓地有「青眼」怪兽存在的场合，装备怪兽在同1次的战斗阶段中可以作出最多有那个数量的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(c50371210.val)
	c:RegisterEffect(e2)
	-- ①：这张卡从场上离开时那只怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c50371210.rmop)
	c:RegisterEffect(e3)
	-- ②：装备怪兽以外的自己怪兽不能攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(c50371210.ftarget)
	c:RegisterEffect(e4)
end
-- 过滤出墓地中属于「青眼」系列且可以被当前效果特殊召唤的怪兽，作为可选择的特召对象。
function c50371210.spfilter(c,e,tp)
	return c:IsSetCard(0xdd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤墓地中所有「青眼」系列的卡，用于统计墓地青眼怪兽的数量。
function c50371210.gvfilter(c)
	return c:IsSetCard(0xdd)
end
-- 检查场上是否存在表侧表示的另一张「光之引导」（卡号50371210），用于排除自己场上已有同名卡的情况。
function c50371210.cfilter(c)
	return c:IsFaceup() and c:IsCode(50371210)
end
-- 发动条件判定与取对象：确认自己怪兽区有空位、墓地有可特殊召唤的青眼怪兽且青眼怪兽数量≥3、场上没有其他表侧「光之引导」；满足后从墓地选择1只青眼怪兽作为对象。
function c50371210.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50371210.spfilter(chkc,e,tp) end
	-- 确认自己主要怪兽区有空余格子，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认墓地存在至少1只可作为效果对象的「青眼」怪兽（满足可特殊召唤条件）。
		and Duel.IsExistingTarget(c50371210.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 确认自己墓地存在至少3只「青眼」怪兽，满足发动所需的墓地数量条件。
		and Duel.IsExistingMatchingCard(c50371210.gvfilter,tp,LOCATION_GRAVE,0,3,nil)
		-- 确认场上不存在其他表侧表示的「光之引导」（排除自身这张卡）。
		and not Duel.IsExistingMatchingCard(c50371210.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 弹出选择提示，让玩家从候选中选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地的「青眼」怪兽中选择1只作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c50371210.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向系统登记本次效果包含特殊召唤的操作信息（对象为所选的青眼怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 向系统登记本次效果包含装备的操作信息（装备卡为这张「光之引导」自身）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制判定：此装备魔法卡只能装备给其所有者（光之引导自身），防止装备到其他怪兽身上。
function c50371210.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理：若发动卡和对象仍然关联，则将对象「青眼」怪兽特殊召唤，把此卡装备给它，使其效果无效，并设定装备限制。
function c50371210.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示进行特殊召唤（分步处理中的召唤步骤，若失败则中断处理）。
		if not Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then return end
		-- 把「光之引导」这张卡装备给已特殊召唤成功的对象怪兽。
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c50371210.eqlimit)
		c:RegisterEffect(e1)
		-- 那只怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e3)
		-- 结束特殊召唤的分步处理，完成整个特殊召唤流程。
		Duel.SpecialSummonComplete()
	end
end
-- 当「光之引导」离场时，取得其装备的怪兽，并将该怪兽除外。
function c50371210.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	if tc then
		-- 将对象怪兽以表侧表示除外，除外原因为效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判定怪兽是否为装备怪兽：仅装备怪兽以外的自己怪兽才会被“不能攻击”效果限制。
function c50371210.ftarget(e,c)
	return e:GetHandler():GetEquipTarget()~=c
end
-- 计算装备怪兽可获得的额外攻击次数：总攻击次数等于自己墓地「青眼」怪兽数量，额外攻击次数需再减1。
function c50371210.val(e,c)
	-- 统计自己墓地中「青眼」系列卡的数量，作为装备怪兽可攻击次数的依据。
	local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,0xdd)
	return math.max(0,ct-1)
end
