--果たし－Ai－
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：对方场上的怪兽的攻击力下降自己场上的卡数量×100。
-- ②：自己的「@火灵天星」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ③：自己的「@火灵天星」怪兽被战斗破坏时，以那怪兽以外的自己墓地1只攻击力2300的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
function c28645123.initial_effect(c)
	-- 这张卡发动（作为魔法/陷阱卡发动的基础效果，不对应效果原文中的独立语句）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置伤害步骤发动条件：仅当在伤害步骤且尚未进行伤害计算时此卡才能发动（配合EFFECT_FLAG_DAMAGE_STEP允许在伤害步骤发动）
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ①：对方场上的怪兽的攻击力下降自己场上的卡数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c28645123.atkval)
	c:RegisterEffect(e2)
	-- ②：自己的「@火灵天星」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c28645123.actcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：自己的「@火灵天星」怪兽被战斗破坏时，以那怪兽以外的自己墓地1只攻击力2300的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 定义攻击力变化值的计算函数：以自己场上卡牌总数乘以-100作为攻击力的增减值（负值即为下降）。
function c28645123.atkval(e)
	-- 统计自己场上的卡牌数量（怪兽区与魔陷区合计）并乘以-100，返回给EFFECT_UPDATE_ATTACK作为攻击力下降量。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)*-100
end
-- 过滤函数：判定战斗怪兽是否为表侧表示的「@火灵天星」怪兽且控制者为tp。
function c28645123.actfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x135) and c:IsControler(tp)
end
-- ②效果的发动条件：当前战斗的攻击方或攻击目标中存在我方场上的表侧表示「@火灵天星」怪兽。
function c28645123.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取当前战斗阶段中的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗阶段中的攻击对象怪兽（直接攻击时为nil）。
	local d=Duel.GetAttackTarget()
	return (a and c28645123.actfilter(a,tp)) or (d and c28645123.actfilter(d,tp))
end
-- 过滤函数：判定被战斗破坏的怪兽在战斗前是否为我方场上的「@火灵天星」怪兽（此前位于我方怪兽区域且控制者为我方）。
function c28645123.cfilter(c,tp)
	return c:IsPreviousSetCard(0x135) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- ③效果的发动条件：在被战斗破坏送入墓地的怪兽组eg中，存在至少1只符合条件的自己「@火灵天星」怪兽。
function c28645123.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28645123.cfilter,1,nil,tp)
end
-- 对象过滤函数：选择墓地中攻击力2300、电子界族且能够被特殊召唤的怪兽作为对象。
function c28645123.spfilter(c,e,tp)
	return c:IsAttack(2300) and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的取对象处理：检查自己怪兽区有空位且墓地存在满足条件的电子界族怪兽，然后让玩家选择1只（排除本次被战斗破坏的怪兽）作为对象。
function c28645123.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c28645123.spfilter(chkc,e,tp) and not eg:IsContains(chkc) end
	-- 发动合法性检查：自己主要怪兽区是否有空位可用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在满足spfilter条件的电子界族怪兽可作为取对象目标（排除被破坏组eg）。
		and Duel.IsExistingTarget(c28645123.spfilter,tp,LOCATION_GRAVE,0,1,eg,e,tp) end
	-- 向选择玩家发送提示消息，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让tp从自己墓地选择1只符合条件的电子界族怪兽作为特殊召唤对象（排除eg中被战斗破坏的怪兽），并标记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c28645123.spfilter,tp,LOCATION_GRAVE,0,1,1,eg,e,tp)
	-- 设置操作信息：本次效果处理将进行1只怪兽的特殊召唤，对象为已选定的g。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果处理：取出选择的对象，若仍与该效果相关则将其特殊召唤；否则不处理。
function c28645123.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的第一张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
