--アースゴーレム＠イグニスター
-- 效果：
-- 电子界族怪兽＋连接怪兽
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡融合召唤成功的回合，自己受到的全部伤害变成0。
-- ②：向从额外卡组特殊召唤的怪兽用这张卡攻击的伤害步骤内，这张卡的攻击力上升原本攻击力数值。
-- ③：这张卡被战斗破坏时，以「地石人@火灵天星」以外的自己墓地1只电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
function c62111090.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为电子界族怪兽和连接怪兽各1只。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE),aux.FilterBoolFunction(Card.IsFusionType,TYPE_LINK),true)
	-- ①：这张卡融合召唤成功的回合，自己受到的全部伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c62111090.damcon)
	e1:SetOperation(c62111090.damop)
	c:RegisterEffect(e1)
	-- ②：向从额外卡组特殊召唤的怪兽用这张卡攻击的伤害步骤内，这张卡的攻击力上升原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c62111090.atkcon)
	e2:SetValue(c62111090.atkval)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗破坏时，以「地石人@火灵天星」以外的自己墓地1只电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(62111090,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,62111090)
	e3:SetTarget(c62111090.sptg)
	e3:SetOperation(c62111090.spop)
	c:RegisterEffect(e3)
end
-- 判断自身是否为融合召唤成功。
function c62111090.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 在当前回合内，将自己受到的全部战斗伤害和效果伤害变成0。
function c62111090.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：这张卡融合召唤成功的回合，自己受到的全部伤害变成0。②：向从额外卡组特殊召唤的怪兽用这张卡攻击的伤害步骤内，这张卡的攻击力上升原本攻击力数值。③：这张卡被战斗破坏时，以「地石人@火灵天星」以外的自己墓地1只电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册“受到的战斗伤害变成0”的效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册“受到的效果伤害变成0”的效果。
	Duel.RegisterEffect(e2,tp)
end
-- 判断是否在伤害步骤内，且自身向从额外卡组特殊召唤的怪兽进行攻击。
function c62111090.atkcon(e)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	if ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL then return false end
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽。
	local d=Duel.GetAttackTarget()
	return e:GetHandler()==a and d and d:IsSummonLocation(LOCATION_EXTRA)
end
-- 返回自身原本攻击力的数值。
function c62111090.atkval(e,c)
	return e:GetHandler():GetBaseAttack()
end
-- 过滤墓地中除「地石人@火灵天星」以外、可以特殊召唤的电子界族怪兽。
function c62111090.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and not c:IsCode(62111090) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动条件与靶向判定（检查是否有可用怪兽区域及符合条件的墓地怪兽）。
function c62111090.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c62111090.spfilter(chkc,e,tp) end
	-- 在发动效果时，检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动效果时，检查自己墓地是否存在符合条件的电子界族怪兽。
		and Duel.IsExistingTarget(c62111090.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的电子界族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c62111090.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理的操作信息为特殊召唤选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的执行处理（将选中的墓地怪兽特殊召唤）。
function c62111090.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
