--光の導き
-- 效果：
-- ①：自己场上没有其他的「光之引导」存在，自己墓地有「青眼」怪兽3只以上存在的场合，以那之内的1只为对象才能把这张卡发动。那只怪兽效果无效特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽除外。
-- ②：装备怪兽以外的自己怪兽不能攻击，自己墓地有「青眼」怪兽存在的场合，装备怪兽在同1次的战斗阶段中可以作出最多有那个数量的攻击。
function c50371210.initial_effect(c)
	-- ①：自己场上没有其他的「光之引导」存在，自己墓地有「青眼」怪兽3只以上存在的场合，以那之内的1只为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c50371210.target)
	e1:SetOperation(c50371210.operation)
	c:RegisterEffect(e1)
	-- ②：装备怪兽以外的自己怪兽不能攻击，自己墓地有「青眼」怪兽存在的场合，装备怪兽在同1次的战斗阶段中可以作出最多有那个数量的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(c50371210.val)
	c:RegisterEffect(e2)
	-- 这张卡从场上离开时那只怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c50371210.rmop)
	c:RegisterEffect(e3)
	-- 装备怪兽以外的自己怪兽不能攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(c50371210.ftarget)
	c:RegisterEffect(e4)
end
-- 检索满足条件的「光之引导」怪兽卡片组
function c50371210.spfilter(c,e,tp)
	return c:IsSetCard(0xdd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检索满足条件的「青眼」怪兽卡片组
function c50371210.gvfilter(c)
	return c:IsSetCard(0xdd)
end
-- 检索满足条件的「光之引导」卡片组
function c50371210.cfilter(c)
	return c:IsFaceup() and c:IsCode(50371210)
end
-- 判断是否满足发动条件：自己场上没有其他的「光之引导」存在，自己墓地有「青眼」怪兽3只以上存在的场合，以那之内的1只为对象才能把这张卡发动。
function c50371210.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50371210.spfilter(chkc,e,tp) end
	-- 判断自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在至少1张满足条件的「光之引导」怪兽
		and Duel.IsExistingTarget(c50371210.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 判断自己墓地是否存在至少3张「青眼」怪兽
		and Duel.IsExistingMatchingCard(c50371210.gvfilter,tp,LOCATION_GRAVE,0,3,nil)
		-- 判断自己场上是否没有其他「光之引导」存在
		and not Duel.IsExistingMatchingCard(c50371210.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只「光之引导」怪兽作为目标
	local g=Duel.SelectTarget(tp,c50371210.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将目标怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息：将此卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 限制目标怪兽只能被此卡装备
function c50371210.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 执行效果处理：将目标怪兽特殊召唤并装备此卡，同时使目标怪兽效果无效
function c50371210.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 尝试特殊召唤目标怪兽
		if not Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then return end
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 设置目标怪兽只能被此卡装备的效果
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c50371210.eqlimit)
		c:RegisterEffect(e1)
		-- 使目标怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e3)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 执行离场时的效果：将装备的怪兽除外
function c50371210.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	if tc then
		-- 将目标怪兽除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 设置不能攻击的判定条件：装备怪兽以外的自己怪兽不能攻击
function c50371210.ftarget(e,c)
	return e:GetHandler():GetEquipTarget()~=c
end
-- 计算自己墓地「青眼」怪兽数量并返回可额外攻击次数
function c50371210.val(e,c)
	-- 统计自己墓地「青眼」怪兽的数量
	local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,0xdd)
	return math.max(0,ct-1)
end
