--アドバンスド・ダーク
-- 效果：
-- ①：场上的「宝玉兽」怪兽以及墓地的「宝玉兽」怪兽全部变成暗属性。
-- ②：只要这张卡在场地区域存在，成为「究极宝玉神」怪兽的攻击对象的怪兽的效果只在那次战斗阶段内无效化。
-- ③：自己的「宝玉兽」怪兽的战斗要让自己受到战斗伤害的伤害计算时，从卡组把1只「宝玉兽」怪兽送去墓地才能发动。那次战斗发生的对自己的战斗伤害变成0。
function c12644061.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「宝玉兽」怪兽全部变成暗属性。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	-- 指定只有「宝玉兽」字段（0x1034）的怪兽才会成为该改变属性效果的对象。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1034))
	e2:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e2)
	local e2g=e2:Clone()
	e2g:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e2g:SetCondition(c12644061.gravecon)
	c:RegisterEffect(e2g)
	-- ②：成为「究极宝玉神」怪兽的攻击对象的怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(c12644061.discon)
	e3:SetOperation(c12644061.disop)
	c:RegisterEffect(e3)
	-- 的效果只在那次战斗阶段内无效化
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_DISABLE)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(c12644061.distg)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e7)
	-- ③：自己的「宝玉兽」怪兽的战斗要让自己受到战斗伤害的伤害计算时，从卡组把1只「宝玉兽」怪兽送去墓地才能发动。那次战斗发生的对自己的战斗伤害变成0。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(12644061,0))  --"战斗伤害变成0"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(c12644061.damcon)
	e4:SetCost(c12644061.damcost)
	e4:SetOperation(c12644061.damop)
	c:RegisterEffect(e4)
	-- 墓地的「宝玉兽」怪兽全部变成暗属性。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CHANGE_GRAVE_ATTRIBUTE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
	e5:SetCondition(c12644061.gravecon)
	e5:SetValue(ATTRIBUTE_DARK)
	-- 指定只有「宝玉兽」字段（0x1034）的怪兽才会成为该墓地属性改变效果的对象。
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1034))
	c:RegisterEffect(e5)
end
-- 攻击宣言时，若存在攻击对象且攻击怪兽是「究极宝玉神」字段（0x2034）的怪兽，则满足效果②的发动条件。
function c12644061.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽（攻击对象）。
	local at=Duel.GetAttackTarget()
	return at and a:IsSetCard(0x2034)
end
-- 给攻击对象怪兽登记一个编号为12644061的标记，该标记会在战斗阶段结束或离场等标准重置条件下清除，以便效果②识别要无效的怪兽。
function c12644061.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击对象怪兽，作为需要打标记的卡。
	local tc=Duel.GetAttackTarget()
	tc:RegisterFlagEffect(12644061,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 检查怪兽是否带有12644061标记，以此筛选出“成为「究极宝玉神」攻击对象”的怪兽进行效果无效。
function c12644061.distg(e,c)
	return c:GetFlagEffect(12644061)~=0
end
-- 判断双方玩家是否都不受「王家长眠之谷」影响；只有双方均不受影响时，墓地属性变更效果才能适用。
function c12644061.gravecon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查我方玩家没有受到「王家长眠之谷」效果影响。
	return not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NECRO_VALLEY)
		-- 同时检查对方玩家也没有受到「王家长眠之谷」效果影响。
		and not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_NECRO_VALLEY)
end
-- 伤害计算时，若攻击方或被攻击方中存在由我方控制的「宝玉兽」怪兽，且我方本次战斗将受到战斗伤害，则满足效果③的发动条件。
function c12644061.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取攻击对象（被攻击怪兽）。
	local at=Duel.GetAttackTarget()
	-- 判定我方玩家在这次战斗中将要受到的战斗伤害大于0，即确实会承受战斗伤害。
	return Duel.GetBattleDamage(tp)>0
		and ((a:IsControler(tp) and a:IsSetCard(0x1034)) or (at and at:IsControler(tp) and at:IsSetCard(0x1034)))
end
-- 筛选可作为代价的卡：持有「宝玉兽」字段（0x1034）、是怪兽卡，并且可以作为代价被送去墓地。
function c12644061.dfilter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果③的代价处理：检查卡组是否存在符合条件的「宝玉兽」怪兽，提示玩家选择1只，并将其作为代价送去墓地。
function c12644061.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）时，确认自己卡组中是否存在至少1只符合条件的「宝玉兽」怪兽，以判断能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c12644061.dfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向操作玩家显示“请选择要送去墓地的卡”的选择提示，用于选择卡组中作为代价的「宝玉兽」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组中选出1只符合条件的「宝玉兽」怪兽，作为发动效果③的代价。
	local g=Duel.SelectMatchingCard(tp,c12644061.dfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的「宝玉兽」怪兽作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果③处理时，为「高等暗黑结界」控制者注册一个仅在本战斗伤害阶段有效的避免战斗伤害效果，使那次对自己的战斗伤害变为0。
function c12644061.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 那次战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将避免战斗伤害的效果注册给玩家tp，使该玩家在此次伤害阶段不承受那次战斗伤害。
	Duel.RegisterEffect(e1,tp)
end
