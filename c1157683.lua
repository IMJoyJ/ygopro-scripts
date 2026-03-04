--サイバーダーク・インヴェイジョン
-- 效果：
-- ①：1回合1次，可以从以下效果选择1个发动。「电子暗黑侵略」的以下效果1回合各能选择1次。
-- ●以自己场上1只「电子暗黑」效果怪兽为对象才能发动。从自己·对方的墓地选1只龙族·机械族怪兽当作攻击力上升1000的装备卡使用给作为对象的怪兽装备。
-- ●把给机械族怪兽装备的自己场上1张装备卡送去墓地才能发动。选对方场上1张卡破坏。
function c1157683.initial_effect(c)
	-- ①：1回合1次，可以从以下效果选择1个发动。「电子暗黑侵略」的以下效果1回合各能选择1次。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ●以自己场上1只「电子暗黑」效果怪兽为对象才能发动。从自己·对方的墓地选1只龙族·机械族怪兽当作攻击力上升1000的装备卡使用给作为对象的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1157683,0))  --"装备"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c1157683.eqtg)
	e1:SetOperation(c1157683.eqop)
	c:RegisterEffect(e1)
	-- ●把给机械族怪兽装备的自己场上1张装备卡送去墓地才能发动。选对方场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1157683,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(c1157683.descost)
	e2:SetTarget(c1157683.destg)
	e2:SetOperation(c1157683.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在满足条件的「电子暗黑」效果怪兽
function c1157683.eqfilter(c,tp)
	return c:IsSetCard(0x4093) and c:IsFaceup() and c:IsType(TYPE_EFFECT)
		-- 检查场上是否存在满足条件的龙族·机械族怪兽
		and Duel.IsExistingMatchingCard(c1157683.eqfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
end
-- 过滤函数，用于判断墓地是否存在满足条件的龙族·机械族怪兽
function c1157683.eqfilter2(c)
	return c:IsRace(RACE_DRAGON+RACE_MACHINE) and not c:IsForbidden()
end
-- 装备效果的处理函数，用于设置装备效果的目标和条件
function c1157683.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1157683.eqfilter(chkc,tp) end
	-- 检查是否满足发动条件：未发动过此效果且场上存在装备区域
	if chk==0 then return Duel.GetFlagEffect(tp,1157683)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查是否存在满足条件的「电子暗黑」效果怪兽作为目标
		and Duel.IsExistingTarget(c1157683.eqfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 注册标识效果，防止此效果在回合内重复发动
	Duel.RegisterFlagEffect(tp,1157683,RESET_PHASE+PHASE_END,0,1)
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择满足条件的「电子暗黑」效果怪兽作为目标
	Duel.SelectTarget(tp,c1157683.eqfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息，表示将从墓地取出装备卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- 装备效果的执行函数，用于执行装备操作
function c1157683.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在装备区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 提示玩家选择要装备的装备卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		-- 从墓地中选择满足条件的龙族·机械族怪兽作为装备卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1157683.eqfilter2),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
		local ec=g:GetFirst()
		-- 尝试将装备卡装备给目标怪兽，若失败则返回
		if not ec or not Duel.Equip(tp,ec,tc) then return end
		-- 设置装备限制效果，确保装备卡只能装备给特定怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c1157683.eqlimit)
		e1:SetLabelObject(tc)
		ec:RegisterEffect(e1)
		-- 设置装备卡的攻击力提升效果，提升1000点
		local e2=Effect.CreateEffect(ec)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(1000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2)
	end
end
-- 装备限制效果的判断函数，确保装备卡只能装备给指定怪兽
function c1157683.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤函数，用于判断场上是否存在满足条件的装备卡
function c1157683.cfilter(c)
	return c:IsFaceup() and c:GetEquipTarget() and c:GetEquipTarget():IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost()
end
-- 破坏效果的处理函数，用于设置破坏效果的消耗和条件
function c1157683.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：场上存在满足条件的装备卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1157683.cfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的装备卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的装备卡作为消耗
	local g=Duel.SelectMatchingCard(tp,c1157683.cfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选中的装备卡送去墓地作为发动消耗
	Duel.SendtoGrave(g,REASON_COST)
end
-- 破坏效果的处理函数，用于设置破坏效果的目标和条件
function c1157683.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：未发动过此效果
	if chk==0 then return Duel.GetFlagEffect(tp,1157684)==0
		-- 检查是否存在满足条件的对方场上的卡作为目标
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 注册标识效果，防止此效果在回合内重复发动
	Duel.RegisterFlagEffect(tp,1157684,RESET_PHASE+PHASE_END,0,1)
	-- 获取对方场上的所有卡作为可能的目标
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息，表示将要破坏对方场上的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行函数，用于执行破坏操作
function c1157683.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择满足条件的对方场上的卡作为破坏目标
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 显示被选为破坏目标的卡的动画效果
		Duel.HintSelection(g)
		-- 将选中的卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
