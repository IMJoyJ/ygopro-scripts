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
-- 过滤函数，用于判断是否为表侧表示的「超重武者」怪兽
function c35800511.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 效果处理函数，用于选择目标怪兽并检查是否满足装备条件
function c35800511.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c35800511.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查玩家场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查玩家场上是否存在满足条件的「超重武者」怪兽
		and Duel.IsExistingTarget(c35800511.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c35800511.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 装备效果处理函数，将装备卡装备给目标怪兽并设置装备限制和守备力加成
function c35800511.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查装备条件是否满足，包括是否有足够的魔法陷阱区域、目标怪兽是否为己方、是否为表侧表示、是否与效果相关
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若装备条件不满足，则将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 设置装备对象限制，确保只能装备给「超重武者」怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c35800511.eqlimit)
	c:RegisterEffect(e1)
	-- 设置装备卡效果，使装备怪兽的守备力上升400
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(400)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备对象限制函数，确保只能装备给「超重武者」怪兽
function c35800511.eqlimit(e,c)
	return c:IsSetCard(0x9a)
end
-- 条件函数，判断是否满足发动效果的条件
function c35800511.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家墓地是否存在魔法或陷阱卡
	if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP) then return false end
	-- 获取当前游戏阶段
	local phase=Duel.GetCurrentPhase()
	-- 检查当前阶段是否为伤害步骤且未计算伤害
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取攻击怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽为对方，则获取对方攻击目标
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	-- 返回是否满足发动条件
	return tc and tc:IsSetCard(0x9a) and tc:IsDefensePos() and tc:IsRelateToBattle() and Duel.GetAttackTarget()~=nil
end
-- 费用函数，将装备卡送入墓地作为费用
function c35800511.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将装备卡送入墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果处理函数，将目标怪兽的守备力变为原本的2倍
function c35800511.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(tp) then
		local def=tc:GetBaseDefense()
		-- 设置目标怪兽的守备力为原本的2倍，直到回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(def*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
