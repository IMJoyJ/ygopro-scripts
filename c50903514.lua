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
	-- 设置②效果的发动代价：将墓地的这张卡除外（作为发动COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c50903514.sptg)
	e2:SetOperation(c50903514.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：当前阶段处于战斗阶段（PHASE_BATTLE_START 至 PHASE_BATTLE 之间），且满足伤害步骤中仅能在伤害计算前发动的限制（aux.dscon）。
function c50903514.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段并存入局部变量 ph，用于后续判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	-- 返回 true 的条件：当前阶段是战斗阶段（从开始步骤到结束步骤），并且 aux.dscon 通过（即不是伤害计算后），保证可以在战斗阶段任意时点或伤害计算前发动。
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- ①效果的对象筛选函数：选择表侧表示且种族为战士族的怪兽，作为攻击力上升的对象（同时要求不是发动者本身，由调用处排除）。
function c50903514.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- ①效果的发动目标选择：在对方回合或自己回合的战斗阶段，从自己场上选择这张卡以外1只表侧表示战士族怪兽为对象；同时要求这张卡的当前攻击力在600以上，以保证下降600后不会变为负数。
function c50903514.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50903514.filter(chkc) end
	if chk==0 then return e:GetHandler():IsAttackAbove(600)
		-- 检查自己场上是否存在满足 filter 条件且不是这张卡本身的表侧战士族怪兽（数量至少1），用于判断能否发动。
		and Duel.IsExistingTarget(c50903514.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 给玩家 tp 显示选择提示消息，提示内容为“请选择表侧表示的卡”，用于后续选择对象的 UI 引导。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家 tp 从自己场上选择1只满足 filter 条件且不是这张卡的怪兽作为效果对象，并将选择结果登记为当前连锁的对象。
	Duel.SelectTarget(tp,c50903514.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- ①效果处理：获取效果发动者和对象；若发动者变成里侧或与效果失去联系、攻击力不足600，或对象变成里侧/失去联系，则效果不处理；否则发动者攻击力下降600，对象攻击力上升600。
function c50903514.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取①效果选择的那个对象怪兽（即攻击力要上升的怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:GetAttack()<600
		or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 这张卡的攻击力下降600。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-600)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	-- 作为对象的怪兽的攻击力上升600。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(600)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
end
-- ②效果的发动条件判定：这张卡被对方破坏并送去墓地，且破坏前在场上并归自己控制。
function c50903514.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- ②效果的对象的筛选条件：墓地中的战士族·炎属性怪兽，并且可以被当前效果特殊召唤（满足苏生限制等）。
function c50903514.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标选择：在满足自己主要怪兽区有空位的前提下，选择自己墓地1只战士族·炎属性怪兽为对象；选择后设置特殊召唤的操作信息。
function c50903514.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50903514.spfilter(chkc,e,tp) end
	-- 发动时检查自己主要怪兽区是否有空位，用于确保特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足 spfilter 条件的战士族·炎属性怪兽作为可选择的特殊召唤对象。
		and Duel.IsExistingTarget(c50903514.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 给玩家 tp 显示选择提示消息，提示内容为“请选择要特殊召唤的卡”，用于后续选择对象的 UI 引导。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家 tp 从自己墓地选择1只满足条件的战士族·炎属性怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c50903514.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置当前连锁的操作信息，声明本效果将进行1只怪兽的特殊召唤（供其他卡/效果连锁判定时参考）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：获取对象怪兽，若对象仍与效果关联且满足战士族·炎属性，则将其表侧攻击表示特殊召唤到自己的主要怪兽区。
function c50903514.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的那只墓地中的战士族·炎属性怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_WARRIOR) and tc:IsAttribute(ATTRIBUTE_FIRE) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己的场上（不检查召唤条件、不限制苏生限制，因为已在选择时验证过）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
