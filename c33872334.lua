--フェニックス・ギア・ブレード
-- 效果：
-- 战士族怪兽或炎属性怪兽才能装备。这个卡名的③的效果1回合只能使用1次。
-- ①：装备怪兽的攻击力上升300。
-- ②：装备怪兽攻击的伤害步骤结束时，把这张卡送去墓地才能发动。这次战斗阶段中，自己的战士族怪兽以及炎属性怪兽各可以作2次攻击。
-- ③：这张卡为让怪兽的效果发动，被送去墓地的场合或者被除外的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 创建并注册这张卡的全部效果：装备魔法发动、装备对象限制、攻击力上升300、②伤害步骤结束时送墓发动附加攻击次数、③作为怪兽效果发动代价送墓/除外时加入手卡。
function s.initial_effect(c)
	-- 战士族怪兽或炎属性怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 战士族怪兽或炎属性怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlim)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- ②：装备怪兽攻击的伤害步骤结束时，把这张卡送去墓地才能发动。这次战斗阶段中，自己的战士族怪兽以及炎属性怪兽各可以作2次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.dacon)
	e4:SetCost(s.dacost)
	e4:SetOperation(s.daop)
	c:RegisterEffect(e4)
	-- ③：这张卡为让怪兽的效果发动，被送去墓地的场合或者被除外的场合才能发动。这张卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,id)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(s.thcon)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e6)
end
-- 装备对象过滤函数：要求怪兽表侧表示且满足装备限制（战士族或炎属性），用于选择可装备对象。
function s.filter(c)
	return c:IsFaceup() and s.eqlim(nil,c)
end
-- 发动时的目标选择处理：检查是否存在合法对象，若存在则让玩家选择一只符合条件的表侧怪兽作为装备对象，并设置装备操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 发动合法判定：确认双方主要怪兽区存在至少1只满足过滤条件且能成为装备对象的表侧怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家发送选择提示，提示其选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方主要怪兽区选择1只符合条件的表侧怪兽作为这张卡的装备对象，并登记为连锁对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁效果将进行装备处理，处理对象为这张卡自身，数量1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：获取装备卡自身和选择的目标，在双方仍有效且目标表侧时，把这张卡装备给目标怪兽。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中第一个对象，即选择要装备的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认装备卡和目标怪兽都仍与效果相关、目标仍表侧，满足则将装备卡装备给目标怪兽。
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then Duel.Equip(tp,c,tc) end
end
-- 装备限制判定：怪兽是战士族或炎属性时允许装备，对应“战士族怪兽或炎属性怪兽才能装备”。
function s.eqlim(e,c)
	return c:IsRace(RACE_WARRIOR) or c:IsAttribute(ATTRIBUTE_FIRE)
end
-- ②效果的发动条件：这张卡的装备怪兽进行攻击，并且在伤害步骤结束时仍处于与战斗相关的状态。
function s.dacon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	-- 判定当前攻击的怪兽正是这张卡的装备怪兽，且该怪兽仍与战斗相关，满足时②效果可以发动。
	return Duel.GetAttacker()==tc and tc:IsRelateToBattle()
end
-- ②效果的发动代价：检查这张卡能否作为代价送墓，能则支付代价将其送入墓地。
function s.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 把这张卡送去墓地，作为②效果发动的代价。
	Duel.SendtoGrave(c,REASON_COST)
end
-- ②效果处理：给本方场上的战士族怪兽和炎属性怪兽附加1次额外攻击次数，效果持续到本次战斗阶段结束。
function s.daop(e,tp,eg,ep,ev,re,r,rp)
	-- ②：这次战斗阶段中，自己的战士族怪兽以及炎属性怪兽各可以作2次攻击。③：这张卡为让怪兽的效果发动，被送去墓地的场合或者被除外的场合才能发动。这张卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.datg)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE)
	e1:SetValue(1)
	-- 将额外攻击效果注册到场上，作用于本方玩家，使其场上的战士族/炎属性怪兽在本战斗阶段获得额外攻击次数。
	Duel.RegisterEffect(e1,tp)
end
-- 额外攻击效果的适用对象过滤：本方场上的战士族或炎属性怪兽。
function s.datg(e,c)
	return c:IsRace(RACE_WARRIOR) or c:IsAttribute(ATTRIBUTE_FIRE)
end
-- ③效果的发动条件：这张卡作为怪兽效果发动的代价被送去墓地，且那个效果是已发动的怪兽效果。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- ③效果发动时的目标处理：检查这张卡能否加入手卡，能则设置回手操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置操作信息：本连锁将把这张卡加入手卡，处理对象为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- ③效果处理：若这张卡仍与效果相关，则将其加入持有者的手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡没有被移走等仍与效果相关，若是则将其加入持有者手卡（回手原因为效果）。
	if c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end
end
