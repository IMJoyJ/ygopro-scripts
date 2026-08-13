--超重武者装留バスター・ガントレット
-- 效果：
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作守备力上升400的装备卡使用给那只自己怪兽装备。
-- ②：自己墓地没有魔法·陷阱卡存在的场合，自己的守备表示的「超重武者」怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡送去墓地才能发动。那只进行战斗的自己怪兽的守备力直到回合结束时变成原本守备力的2倍。
function c35800511.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作守备力上升400的装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c35800511.eqtg)
	e1:SetOperation(c35800511.eqop)
	c:RegisterEffect(e1)
	-- ②：自己墓地没有魔法·陷阱卡存在的场合，自己的守备表示的「超重武者」怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡送去墓地才能发动。那只进行战斗的自己怪兽的守备力直到回合结束时变成原本守备力的2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCondition(c35800511.condition)
	e2:SetCost(c35800511.cost)
	e2:SetOperation(c35800511.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡必须表侧表示且字段为「超重武者」。
function c35800511.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- ①效果的发动目标选择函数：检查是否有表侧「超重武者」怪兽可以作为装备对象，且对象不是这张卡自身；指定目标后供后续处理使用。
function c35800511.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c35800511.filter(chkc) and chkc~=e:GetHandler() end
	-- 发动条件检查：自己魔陷区必须存在空位，否则无法进行装备。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件检查：自己场上存在1只满足过滤条件的表侧「超重武者」怪兽，且该怪兽不是这张卡（可作为装备对象）。
		and Duel.IsExistingTarget(c35800511.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向操作玩家发出HINTMSG_EQUIP提示，显示“请选择要装备的卡”的装备选择信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1只表侧「超重武者」怪兽作为装备对象，并将该怪兽设为发动时指定的对象。
	Duel.SelectTarget(tp,c35800511.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- ①效果处理：若这张卡/对象状态合法，则将这张卡装备给对象怪兽，并给这张卡附加装备对象限制和使其守备力上升400的装备效果；否则这张卡因效果送去墓地。
function c35800511.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 取出发动时选择的装备对象怪兽（Duel.GetFirstTarget获取当前连锁的对象）。
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷区空位是否充足、对象是否仍由自己控制且表侧表示、以及是否与当前效果关联；任一不满足则不能继续装备。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 因魔陷区无空位或对象不合法，这张卡以效果原因被送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给对象怪兽（Duel.Equip执行装备动作）。
	Duel.Equip(tp,c,tc)
	-- 从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c35800511.eqlimit)
	c:RegisterEffect(e1)
	-- 守备力上升400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(400)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制：装备怪兽必须是「超重武者」字段的怪兽。
function c35800511.eqlimit(e,c)
	return c:IsSetCard(0x9a)
end
-- ②效果的发动条件判断：自己墓地没有魔法·陷阱卡；当前处于伤害步骤开始后伤害计算前的时点；存在自己场上守备表示「超重武者」怪兽与对方怪兽进行战斗。
function c35800511.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己墓地存在任意魔法·陷阱卡，则不满足“自己墓地没有魔法·陷阱卡存在”的发动条件。
	if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP) then return false end
	-- 取得当前阶段（用于确认是否处于伤害步骤）。
	local phase=Duel.GetCurrentPhase()
	-- 确认当前处于伤害步骤并且尚未进行伤害计算（即从伤害步骤开始到伤害计算前）；否则不能发动。
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 取得攻击怪兽（战斗中的攻击怪兽）。
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方怪兽，则将判断对象改为被攻击的怪兽（即自己怪兽）。
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	-- 判断战斗对象是自己守备表示的「超重武者」怪兽、与战斗相关且攻击目标存在，满足条件则将该怪兽作为效果对象保存。
	return tc and tc:IsSetCard(0x9a) and tc:IsDefensePos() and tc:IsRelateToBattle() and Duel.GetAttackTarget()~=nil
end
-- ②效果的代价：选择将手卡的这张卡送去墓地作为发动代价。
function c35800511.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将手卡的这张卡以代价（REASON_COST）送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ②效果处理：将对象怪兽的守备力设置为其原本守备力的2倍，直到回合结束时适用。
function c35800511.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(tp) then
		local def=tc:GetBaseDefense()
		-- 那只进行战斗的自己怪兽的守备力直到回合结束时变成原本守备力的2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(def*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
