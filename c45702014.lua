--エレメントセイバー・モーレフ
-- 效果：
-- ①：1回合1次，从手卡把1只「元素灵剑士」怪兽送去墓地，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
function c45702014.initial_effect(c)
	-- ①：1回合1次，从手卡把1只「元素灵剑士」怪兽送去墓地，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45702014,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c45702014.setcost)
	e1:SetTarget(c45702014.settg)
	e1:SetOperation(c45702014.setop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45702014,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(c45702014.atttg)
	e2:SetOperation(c45702014.attop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检查手卡或卡组中是否存在满足条件的「元素灵剑士」怪兽（必须是怪兽卡且能作为cost送去墓地）
function c45702014.costfilter(c)
	return c:IsSetCard(0x400d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 处理效果的cost，检查玩家手卡或卡组中是否存在满足条件的「元素灵剑士」怪兽，若存在则选择一张送去墓地
function c45702014.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否受到效果影响（61557074），若受影响则允许从卡组选择cost
	local fe=Duel.IsPlayerAffectedByEffect(tp,61557074)
	local loc=LOCATION_HAND
	if fe then loc=LOCATION_HAND+LOCATION_DECK end
	-- 检查是否满足cost条件，即是否存在至少1张满足costfilter的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c45702014.costfilter,tp,loc,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足costfilter的1张卡
	local tc=Duel.SelectMatchingCard(tp,c45702014.costfilter,tp,loc,0,1,1,nil):GetFirst()
	if tc:IsLocation(LOCATION_DECK) then
		-- 若选择的卡来自卡组，则提示对方玩家该卡被使用
		Duel.Hint(HINT_CARD,0,61557074)
		fe:UseCountLimit(tp)
	end
	-- 将选中的卡送去墓地作为cost
	Duel.SendtoGrave(tc,REASON_COST)
end
-- 过滤函数，用于检查场上是否存在可以改变表示形式的表侧表示怪兽
function c45702014.setfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 设置效果的目标，选择场上1只可以改变表示形式的表侧表示怪兽
function c45702014.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c45702014.setfilter(chkc) end
	-- 检查是否存在满足setfilter的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c45702014.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上1只可以改变表示形式的表侧表示怪兽
	local g=Duel.SelectTarget(tp,c45702014.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息，表示要改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 处理效果的发动，将目标怪兽变为里侧守备表示
function c45702014.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 设置效果的目标，选择要宣言的属性
function c45702014.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言一个属性
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
	e:SetLabel(att)
	-- 设置效果操作信息，表示要将此卡从墓地移出
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 处理效果的发动，将此卡在墓地期间变为宣言的属性
function c45702014.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 创建一个临时效果，使此卡在结束阶段时恢复原属性
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
