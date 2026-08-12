--果たし－Ai－
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：对方场上的怪兽的攻击力下降自己场上的卡数量×100。
-- ②：自己的「@火灵天星」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ③：自己的「@火灵天星」怪兽被战斗破坏时，以那怪兽以外的自己墓地1只攻击力2300的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
function c28645123.initial_effect(c)
	-- ①：对方场上的怪兽的攻击力下降自己场上的卡数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前发动。
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ②：自己的「@火灵天星」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c28645123.atkval)
	c:RegisterEffect(e2)
	-- ③：自己的「@火灵天星」怪兽被战斗破坏时，以那怪兽以外的自己墓地1只攻击力2300的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c28645123.actcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 检索满足条件的卡片组并特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(28645123,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,28645123)
	e4:SetCondition(c28645123.spcon)
	e4:SetTarget(c28645123.sptg)
	e4:SetOperation(c28645123.spop)
	c:RegisterEffect(e4)
end
-- 计算攻击力下降值，为场上卡数量乘以-100。
function c28645123.atkval(e)
	-- 获取场上卡数量并乘以-100作为攻击力下降值。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)*-100
end
-- 判断是否为火灵天星怪兽。
function c28645123.actfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x135) and c:IsControler(tp)
end
-- 判断是否为火灵天星怪兽并处于攻击状态。
function c28645123.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击怪兽。
	local d=Duel.GetAttackTarget()
	return (a and c28645123.actfilter(a,tp)) or (d and c28645123.actfilter(d,tp))
end
-- 判断被战斗破坏的怪兽是否为火灵天星族且在怪兽区。
function c28645123.cfilter(c,tp)
	return c:IsPreviousSetCard(0x135) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 判断是否有火灵天星族怪兽被战斗破坏。
function c28645123.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28645123.cfilter,1,nil,tp)
end
-- 筛选墓地中的电子界族且攻击力为2300的怪兽。
function c28645123.spfilter(c,e,tp)
	return c:IsAttack(2300) and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动条件和目标选择逻辑。
function c28645123.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c28645123.spfilter(chkc,e,tp) and not eg:IsContains(chkc) end
	-- 判断是否有足够的召唤位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否有满足条件的墓地怪兽。
		and Duel.IsExistingTarget(c28645123.spfilter,tp,LOCATION_GRAVE,0,1,eg,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为目标。
	local g=Duel.SelectTarget(tp,c28645123.spfilter,tp,LOCATION_GRAVE,0,1,1,eg,e,tp)
	-- 设置效果操作信息，确定特殊召唤的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作。
function c28645123.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
