--アドバンスド・ダーク
-- 效果：
-- ①：场上的「宝玉兽」怪兽以及墓地的「宝玉兽」怪兽全部变成暗属性。
-- ②：只要这张卡在场地区域存在，成为「究极宝玉神」怪兽的攻击对象的怪兽的效果只在那次战斗阶段内无效化。
-- ③：自己的「宝玉兽」怪兽的战斗要让自己受到战斗伤害的伤害计算时，从卡组把1只「宝玉兽」怪兽送去墓地才能发动。那次战斗发生的对自己的战斗伤害变成0。
function c12644061.initial_effect(c)
	-- ①：场上的「宝玉兽」怪兽以及墓地的「宝玉兽」怪兽全部变成暗属性。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在场地区域存在，成为「究极宝玉神」怪兽的攻击对象的怪兽的效果只在那次战斗阶段内无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	-- 筛选满足条件的怪兽组（宝玉兽）
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1034))
	e2:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e2)
	local e2g=e2:Clone()
	e2g:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e2g:SetCondition(c12644061.gravecon)
	c:RegisterEffect(e2g)
	-- ③：自己的「宝玉兽」怪兽的战斗要让自己受到战斗伤害的伤害计算时，从卡组把1只「宝玉兽」怪兽送去墓地才能发动。那次战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(c12644061.discon)
	e3:SetOperation(c12644061.disop)
	c:RegisterEffect(e3)
	-- 检索满足条件的卡片组
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
	-- 发动时点
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(12644061,0))  --"战斗伤害变成0"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(c12644061.damcon)
	e4:SetCost(c12644061.damcost)
	e4:SetOperation(c12644061.damop)
	c:RegisterEffect(e4)
	-- 墓地宝玉兽属性变为暗属性
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CHANGE_GRAVE_ATTRIBUTE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
	e5:SetCondition(c12644061.gravecon)
	e5:SetValue(ATTRIBUTE_DARK)
	-- 筛选满足条件的怪兽组（宝玉兽）
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1034))
	c:RegisterEffect(e5)
end
-- 攻击宣言时的条件判断函数
function c12644061.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取攻击目标怪兽
	local at=Duel.GetAttackTarget()
	return at and a:IsSetCard(0x2034)
end
-- 攻击宣言时的效果处理函数
function c12644061.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击目标怪兽
	local tc=Duel.GetAttackTarget()
	tc:RegisterFlagEffect(12644061,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 无效化效果的目标判断函数
function c12644061.distg(e,c)
	return c:GetFlagEffect(12644061)~=0
end
-- 墓地效果的发动条件函数
function c12644061.gravecon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断自己是否受到Necro Valley影响
	return not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NECRO_VALLEY)
		-- 判断对手是否受到Necro Valley影响
		and not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_NECRO_VALLEY)
end
-- 伤害计算时的条件判断函数
function c12644061.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取攻击目标怪兽
	local at=Duel.GetAttackTarget()
	-- 判断本次战斗伤害是否大于0
	return Duel.GetBattleDamage(tp)>0
		and ((a:IsControler(tp) and a:IsSetCard(0x1034)) or (at and at:IsControler(tp) and at:IsSetCard(0x1034)))
end
-- 用于检索的过滤函数
function c12644061.dfilter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 支付代价时的处理函数
function c12644061.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足支付代价条件
	if chk==0 then return Duel.IsExistingMatchingCard(c12644061.dfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示选择卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,c12644061.dfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡片送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 伤害处理时的效果处理函数
function c12644061.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使自己受到的战斗伤害变为0
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册效果到游戏环境
	Duel.RegisterEffect(e1,tp)
end
