--月光舞猫姫
-- 效果：
-- 「月光」怪兽×2
-- ①：这张卡不会被战斗破坏。
-- ②：1回合1次，自己主要阶段1把这张卡以外的自己场上1只「月光」怪兽解放才能发动。这个回合，对方怪兽各有1次不会被战斗破坏，这张卡可以向全部对方怪兽各作2次攻击。
-- ③：这张卡的攻击宣言时发动。给与对方100伤害。
function c51777272.initial_effect(c)
	-- 添加融合召唤手续，使用2个满足「月光」字段的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xdf),2,true)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段1把这张卡以外的自己场上1只「月光」怪兽解放才能发动。这个回合，对方怪兽各有1次不会被战斗破坏，这张卡可以向全部对方怪兽各作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51777272,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c51777272.condition)
	e2:SetCost(c51777272.cost)
	e2:SetOperation(c51777272.operation)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击宣言时发动。给与对方100伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51777272,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetTarget(c51777272.damtg)
	e3:SetOperation(c51777272.damop)
	c:RegisterEffect(e3)
end
-- 判断是否能进入战斗阶段
function c51777272.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家能否进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 支付效果代价，解放1只「月光」怪兽
function c51777272.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,e:GetHandler(),0xdf) end
	-- 选择1只满足条件的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,e:GetHandler(),0xdf)
	-- 以代价原因解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 设置效果处理，使对方怪兽在本回合内各有一次不会被战斗破坏，并使这张卡可以向全部对方怪兽各作2次攻击
function c51777272.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为对方场上所有怪兽设置效果，使其在本回合内各有一次不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c51777272.indct)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到全局环境
	Duel.RegisterEffect(e1,tp)
	if c:IsRelateToEffect(e) then
		-- 使这张卡在本回合内可以向全部对方怪兽各作2次攻击
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ATTACK_ALL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(2)
		c:RegisterEffect(e2)
	end
end
-- 判断是否为战斗破坏，若是则返回1，否则返回0
function c51777272.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- 设置伤害效果的目标玩家和伤害值
function c51777272.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理中目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理中目标参数为100
	Duel.SetTargetParam(100)
	-- 设置连锁操作信息为造成100点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,100)
end
-- 执行伤害效果，对指定玩家造成100点伤害
function c51777272.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对指定玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
