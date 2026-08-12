--妖仙獣 鎌弐太刀
-- 效果：
-- ①：这张卡召唤成功的场合才能发动。从手卡把「妖仙兽 镰贰太刀」以外的1只「妖仙兽」怪兽召唤。
-- ②：这张卡可以直接攻击。那次战斗给与对方的战斗伤害变成一半。
-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
function c92246806.initial_effect(c)
	-- ①：这张卡召唤成功的场合才能发动。从手卡把「妖仙兽 镰贰太刀」以外的1只「妖仙兽」怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92246806,0))  --"召唤"
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c92246806.sumtg)
	e1:SetOperation(c92246806.sumop)
	c:RegisterEffect(e1)
	-- ②：这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- 那次战斗给与对方的战斗伤害变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(c92246806.rdcon)
	-- 设置战斗伤害变化效果的值，使自身给与对方的战斗伤害变成一半。
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
	-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(c92246806.regop)
	c:RegisterEffect(e4)
end
-- 过滤手卡中除「妖仙兽 镰贰太刀」以外的、可以进行通常召唤的「妖仙兽」怪兽。
function c92246806.filter(c)
	return c:IsSetCard(0xb3) and not c:IsCode(92246806) and c:IsSummonable(true,nil)
end
-- 召唤效果的靶向函数，检查手卡中是否存在可召唤的「妖仙兽」怪兽，并设置召唤的操作信息。
function c92246806.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张满足过滤条件的「妖仙兽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c92246806.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果包含召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 召唤效果的执行函数，让玩家从手卡选择1只满足条件的「妖仙兽」怪兽进行通常召唤。
function c92246806.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手卡选择1张满足过滤条件的「妖仙兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c92246806.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 忽略每回合的通常召唤次数限制，将选中的怪兽进行通常召唤。
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end
-- 伤害减半效果的生效条件判定函数。
function c92246806.rdcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	-- 判定攻击对象是否为空（即是否为直接攻击）。
	return Duel.GetAttackTarget()==nil
		-- 判定自身直接攻击效果未被叠加，且对方场上有怪兽存在（确保是利用直接攻击效果进行的攻击）。
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 召唤成功时的注册函数，用于在结束阶段注册让这张卡回到持有者手卡的效果。
function c92246806.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92246806,1))  --"返回手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetTarget(c92246806.rettg)
	e1:SetOperation(c92246806.retop)
	e1:SetReset(RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 回手卡效果的靶向函数，设置将自身送回手卡的操作信息。
function c92246806.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息，表示该效果包含将自身送回手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 回手卡效果的执行函数，将场上的这张卡送回持有者的手卡。
function c92246806.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果将这张卡送回持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
