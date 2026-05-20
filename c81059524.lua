--デス・ヴォルストガルフ
-- 效果：
-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。给与对方500伤害。
-- ②：只要这张卡在怪兽区域存在，每次自己或者对方把通常·速攻魔法卡发动，直到回合结束时这张卡的攻击力上升各200。
function c81059524.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。给与对方500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81059524,0))  --"LP伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c81059524.damcon)
	e1:SetTarget(c81059524.damtg)
	e1:SetOperation(c81059524.damop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次自己或者对方把通常·速攻魔法卡发动，直到回合结束时这张卡的攻击力上升各200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 在连锁发生时，为这张卡注册连锁标记，用于记录魔法卡发动时这张卡已在场上
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，每次自己或者对方把通常·速攻魔法卡发动，直到回合结束时这张卡的攻击力上升各200。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetCondition(c81059524.atkcon)
	e3:SetOperation(c81059524.atkop)
	c:RegisterEffect(e3)
end
-- 检查是否满足发动条件：此卡战斗破坏怪兽并将其送入墓地
function c81059524.damcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc:IsType(TYPE_MONSTER) and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
-- 设置效果的对象玩家和伤害数值，并注册操作信息
function c81059524.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的对象参数（伤害值）设置为500
	Duel.SetTargetParam(500)
	-- 向系统注册造成500点伤害的操作信息，用于连锁处理和卡片检测
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 执行效果处理：给与对方500点伤害
function c81059524.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 检查是否满足攻击力上升的条件：发动的卡是通常魔法或速攻魔法，且发动时此卡已在场上
function c81059524.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tpe=re:GetActiveType()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and (tpe==TYPE_SPELL or tpe==TYPE_QUICKPLAY+TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 执行攻击力上升的效果处理
function c81059524.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 直到回合结束时这张卡的攻击力上升各200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(200)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
