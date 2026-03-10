--蒼炎の剣士
-- 效果：
-- ①：1回合1次，自己·对方的战斗阶段，以这张卡以外的自己场上1只战士族怪兽为对象才能发动。这张卡的攻击力下降600，作为对象的怪兽的攻击力上升600。
-- ②：场上的这张卡被对方破坏送去墓地时，把墓地的这张卡除外，以自己墓地1只战士族·炎属性怪兽为对象才能发动。那只战士族·炎属性怪兽特殊召唤。
function c50903514.initial_effect(c)
	-- ①：1回合1次，自己·对方的战斗阶段，以这张卡以外的自己场上1只战士族怪兽为对象才能发动。这张卡的攻击力下降600，作为对象的怪兽的攻击力上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50903514,0))  --"攻守变化"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c50903514.condition)
	e1:SetTarget(c50903514.target)
	e1:SetOperation(c50903514.operation)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被对方破坏送去墓地时，把墓地的这张卡除外，以自己墓地1只战士族·炎属性怪兽为对象才能发动。那只战士族·炎属性怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50903514,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c50903514.spcon)
	-- 将这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c50903514.sptg)
	e2:SetOperation(c50903514.spop)
	c:RegisterEffect(e2)
end
-- 效果发动时机判断：当前阶段为战斗阶段开始到战斗阶段结束之间，并且不在伤害步骤中
function c50903514.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 返回值为true表示当前阶段在战斗阶段且未进入伤害步骤
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤条件：场上表侧表示的战士族怪兽
function c50903514.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 效果目标选择：选择自己场上的1只战士族怪兽作为对象
function c50903514.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50903514.filter(chkc) end
	if chk==0 then return e:GetHandler():IsAttackAbove(600)
		-- 满足条件：自身攻击力至少为600点，并且场上存在符合条件的目标怪兽
		and Duel.IsExistingTarget(c50903514.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c50903514.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 效果处理：将自身攻击力下降600，目标怪兽攻击力上升600
function c50903514.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:GetAttack()<600
		or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 使自身攻击力下降600
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-600)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	-- 使目标怪兽攻击力上升600
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(600)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
end
-- 效果发动条件：该卡被对方破坏并送入墓地，且之前在自己的场上控制过
function c50903514.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 过滤条件：墓地中可特殊召唤的战士族·炎属性怪兽
function c50903514.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标选择：从自己墓地中选择1只战士族·炎属性怪兽作为对象
function c50903514.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50903514.spfilter(chkc,e,tp) end
	-- 满足条件：己方场上存在空位，并且墓地存在符合条件的目标怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 满足条件：己方场上存在空位，并且墓地存在符合条件的目标怪兽
		and Duel.IsExistingTarget(c50903514.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c50903514.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置操作信息，告知连锁将要处理特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选定的怪兽特殊召唤到场上
function c50903514.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_WARRIOR) and tc:IsAttribute(ATTRIBUTE_FIRE) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
