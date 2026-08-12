--お注射天使リリー
-- 效果：
-- ①：这张卡进行战斗的伤害计算时1次，支付2000基本分才能发动。这张卡的攻击力只在那次伤害计算时上升3000。
function c79575620.initial_effect(c)
	-- ①：这张卡进行战斗的伤害计算时1次，支付2000基本分才能发动。这张卡的攻击力只在那次伤害计算时上升3000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79575620,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c79575620.con)
	e1:SetCost(c79575620.cost)
	e1:SetOperation(c79575620.op)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：此卡在本次伤害计算中未发动过该效果，且此卡是本次战斗的攻击怪兽或被攻击怪兽
function c79575620.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡在本次伤害计算中是否尚未发动过该效果，且此卡是本次战斗的攻击怪兽或被攻击怪兽
	return c:GetFlagEffect(79575620)==0 and (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
end
-- 定义效果发动代价：检查并支付2000基本分，并给自身注册一个在伤害计算时重置的标识以限制发动次数
function c79575620.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 扣除玩家2000基本分作为发动代价
	Duel.PayLPCost(tp,2000)
	e:GetHandler():RegisterFlagEffect(79575620,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 定义效果处理：使此卡的攻击力在本次伤害计算时上升3000
function c79575620.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的攻击力只在那次伤害计算时上升3000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	e1:SetValue(3000)
	c:RegisterEffect(e1)
end
