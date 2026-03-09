--超重武者装留ファイヤー・アーマー
-- 效果：
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。装备怪兽的等级变成5星。
-- ②：把这张卡从手卡丢弃，以自己场上1只守备表示的「超重武者」怪兽为对象才能发动。直到回合结束时，那只怪兽的守备力下降800，不会被战斗·效果破坏。这个效果在对方回合也能发动。
function c4786063.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。装备怪兽的等级变成5星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4786063,0))  --"装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c4786063.eqtg)
	e1:SetOperation(c4786063.eqop)
	c:RegisterEffect(e1)
	-- 装备怪兽的等级变成5星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetValue(5)
	c:RegisterEffect(e2)
	-- ②：把这张卡从手卡丢弃，以自己场上1只守备表示的「超重武者」怪兽为对象才能发动。直到回合结束时，那只怪兽的守备力下降800，不会被战斗·效果破坏。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4786063,1))  --"破坏耐性"
	e3:SetCategory(CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetRange(LOCATION_HAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e3:SetCondition(aux.dscon)
	e3:SetCost(c4786063.cost)
	e3:SetTarget(c4786063.target)
	e3:SetOperation(c4786063.operation)
	c:RegisterEffect(e3)
end
-- 筛选场上表侧表示的「超重武者」怪兽作为装备对象。
function c4786063.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 设置装备效果的处理函数，用于判断是否满足装备条件。
function c4786063.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c4786063.eqfilter(chkc) end
	-- 检查玩家场上是否有足够的魔法陷阱区域来装备此卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在符合条件的「超重武者」怪兽作为装备对象。
		and Duel.IsExistingTarget(c4786063.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽作为装备对象。
	Duel.SelectTarget(tp,c4786063.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 处理装备效果的执行逻辑，包括装备卡是否能成功装备到目标怪兽上。
function c4786063.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取当前连锁中被选中的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足，如是否有足够的区域、目标是否为己方、是否表侧表示等。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若装备失败则将装备卡送入墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 执行装备操作，将装备卡装备给目标怪兽。
	Duel.Equip(tp,c,tc)
	-- 设置装备对象限制，确保只有「超重武者」怪兽可以装备此卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c4786063.eqlimit)
	c:RegisterEffect(e1)
end
-- 限制装备对象为「超重武者」怪兽。
function c4786063.eqlimit(e,c)
	return c:IsSetCard(0x9a)
end
-- 处理效果发动时的费用支付，将此卡丢入墓地。
function c4786063.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡从手牌送入墓地作为发动费用。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 筛选场上表侧守备表示的「超重武者」怪兽作为目标。
function c4786063.filter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsSetCard(0x9a)
end
-- 设置效果的目标选择函数，用于选择符合条件的守备表示怪兽。
function c4786063.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c4786063.filter(chkc) end
	-- 检查场上是否存在符合条件的守备表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c4786063.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧守备表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPDEFENSE)  --"请选择表侧守备表示的怪兽"
	-- 选择目标守备表示怪兽。
	Duel.SelectTarget(tp,c4786063.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果发动后的操作，包括降低守备力和赋予破坏耐性。
function c4786063.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选中的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 设置目标怪兽的守备力下降800的效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(-800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 设置目标怪兽不会被战斗破坏的效果。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e3)
	end
end
