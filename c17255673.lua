--天御巫の闔
-- 效果：
-- ①：只要有装备卡装备的怪兽在自己场上存在，可以攻击的对方怪兽必须向有装备卡装备的怪兽作出攻击。
-- ②：自己的「御巫」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ③：自己的「御巫」怪兽进行攻击的伤害步骤结束时，把自己场上1张装备卡送去墓地才能发动。那只怪兽向对方怪兽可以继续攻击。
function c17255673.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要有装备卡装备的怪兽在自己场上存在，可以攻击的对方怪兽必须向有装备卡装备的怪兽作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c17255673.atkcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(c17255673.atklimit)
	c:RegisterEffect(e3)
	-- ②：自己的「御巫」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e4:SetCondition(c17255673.actcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ③：自己的「御巫」怪兽进行攻击的伤害步骤结束时，把自己场上1张装备卡送去墓地才能发动。那只怪兽向对方怪兽可以继续攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_DAMAGE_STEP_END)
	e5:SetCondition(c17255673.excon)
	e5:SetCost(c17255673.excost)
	e5:SetOperation(c17255673.exop)
	c:RegisterEffect(e5)
end
-- 判断怪兽是否装备有装备卡（装备卡数量>0）。
function c17255673.atkfilter(c)
	return c:GetEquipCount()>0
end
-- ①效果适用条件：效果控制者场上存在至少1只装备有装备卡的怪兽。
function c17255673.atkcon(e)
	-- 检索当前效果控制者场上（主要怪兽区）是否存在至少1只装备有装备卡的怪兽。
	return Duel.IsExistingMatchingCard(c17255673.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 作为EFFECT_MUST_ATTACK_MONSTER的值函数：若怪兽装备有装备卡，则允许其被指定为强制攻击对象。
function c17255673.atklimit(e,c)
	return c:GetEquipCount()>0
end
-- ②效果适用条件：自己场上存在表侧表示的「御巫」怪兽正在进行战斗。
function c17255673.actcon(e)
	-- 获取自己场上当前正在战斗的怪兽，若没有则为nil。
	local a=Duel.GetBattleMonster(e:GetHandlerPlayer())
	return a and a:IsFaceup() and a:IsSetCard(0x18d)
end
-- ③效果触发条件：攻击怪兽为自己场上的「御巫」怪兽且可以进行追加攻击；同时将攻击怪兽保存到效果标签中供处理时使用。
function c17255673.excon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前攻击怪兽（攻击者）并赋值给局部变量ec。
	local ec=Duel.GetAttacker()
	e:SetLabelObject(ec)
	return ec:IsControler(tp) and ec:IsSetCard(0x18d) and ec:IsChainAttackable(0,true)
end
-- 筛选可作为③效果代价的装备卡：卡类型为装备且可以作为代价送去墓地。
function c17255673.exfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
-- ③效果的发动代价：从自己场上选择并送去墓地1张装备卡。
function c17255673.excost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上是否存在至少1张满足条件的装备卡可作为发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c17255673.exfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 显示“请选择要送去墓地的卡”的选择提示，指引玩家选择装备卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1张装备卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c17255673.exfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将所选装备卡以代价（REASON_COST）形式送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ③效果处理：若攻击怪兽仍与本次战斗相关，则使其获得继续攻击的机会，并附加本战斗阶段内不能直接攻击的限制。
function c17255673.exop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetLabelObject()
	if not ec or not ec:IsRelateToBattle() then return end
	-- 使攻击怪兽获得一次追加攻击的机会（后续通过禁止直接攻击来限制只能向对方怪兽攻击）。
	Duel.ChainAttack()
	-- 那只怪兽向对方怪兽可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	ec:RegisterEffect(e1)
end
