--アマゾネスの急襲
-- 效果：
-- ①：1回合1次，自己·对方的战斗阶段才能发动。从手卡把1只「亚马逊」怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力直到回合结束时上升500。
-- ②：自己的「亚马逊」怪兽和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽除外。
-- ③：场上的这张卡被破坏送去墓地的场合，以自己墓地1只「亚马逊」怪兽为对象才能发动。那只怪兽特殊召唤。
function c83407038.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己·对方的战斗阶段才能发动。从手卡把1只「亚马逊」怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力直到回合结束时上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83407038,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCondition(c83407038.condition)
	e2:SetTarget(c83407038.target)
	e2:SetOperation(c83407038.operation)
	c:RegisterEffect(e2)
	-- ②：自己的「亚马逊」怪兽和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83407038,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c83407038.rmcon)
	e3:SetTarget(c83407038.rmtg)
	e3:SetOperation(c83407038.rmop)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡被破坏送去墓地的场合，以自己墓地1只「亚马逊」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(83407038,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c83407038.spcon)
	e4:SetTarget(c83407038.sptg)
	e4:SetOperation(c83407038.spop)
	c:RegisterEffect(e4)
end
-- 判断当前是否为自己或对方的战斗阶段
function c83407038.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- 过滤手卡中可以特殊召唤的「亚马逊」怪兽
function c83407038.filter(c,e,tp)
	return c:IsSetCard(0x4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查怪兽区域是否有空位，以及手卡中是否存在可以特殊召唤的「亚马逊」怪兽
function c83407038.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，判断自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且判断手卡中是否存在至少1只满足条件的「亚马逊」怪兽
		and Duel.IsExistingMatchingCard(c83407038.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行从手卡特殊召唤1只「亚马逊」怪兽，并使其攻击力直到回合结束时上升500的处理
function c83407038.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此时自己场上没有可用的怪兽区域空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「亚马逊」怪兽
	local tc=Duel.SelectMatchingCard(tp,c83407038.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	-- 若成功选择怪兽，则将其以表侧表示特殊召唤（分解步骤）
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的攻击力直到回合结束时上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 检查怪兽是否由自己控制且为「亚马逊」怪兽
function c83407038.check(c,tp)
	return c and c:IsControler(tp) and c:IsSetCard(0x4)
end
-- 检查此卡在场上是否处于有效状态
function c83407038.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 检查是否有进行战斗的怪兽，并判断其中一方是否为自己的「亚马逊」怪兽，然后将对方怪兽设为效果对象
function c83407038.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，判断是否存在攻击对象（即发生了怪兽之间的战斗）
	if chk==0 then return Duel.GetAttackTarget()~=nil
		-- 并且判断攻击怪兽或攻击对象中至少有一方是自己的「亚马逊」怪兽
		and (c83407038.check(Duel.GetAttacker(),tp) or c83407038.check(Duel.GetAttackTarget(),tp)) end
	-- 如果攻击怪兽是自己的「亚马逊」怪兽
	if c83407038.check(Duel.GetAttacker(),tp) then
		-- 则将作为攻击对象的对方怪兽设为效果对象
		Duel.SetTargetCard(Duel.GetAttackTarget())
	else
		-- 否则将作为攻击怪兽的对方怪兽设为效果对象
		Duel.SetTargetCard(Duel.GetAttacker())
	end
end
-- 执行将进行战斗的对方怪兽除外的处理
function c83407038.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的效果对象（即要除外的对方怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 检查此卡是否在场上被破坏并送去墓地
function c83407038.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤自己墓地中可以特殊召唤的「亚马逊」怪兽
function c83407038.spfilter(c,e,tp)
	return c:IsSetCard(0x4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查怪兽区域空位，并选择自己墓地中的1只「亚马逊」怪兽作为效果对象
function c83407038.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c83407038.spfilter(chkc,e,tp) end
	-- 在发动检查时，判断自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且判断自己墓地中是否存在至少1只可以特殊召唤的「亚马逊」怪兽
		and Duel.IsExistingTarget(c83407038.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只满足条件的「亚马逊」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c83407038.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理的操作信息为：特殊召唤选中的墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行将墓地中作为对象的「亚马逊」怪兽特殊召唤的处理
function c83407038.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的效果对象（即要特殊召唤的墓地怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
