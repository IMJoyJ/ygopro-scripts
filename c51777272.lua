--月光舞猫姫
-- 效果：
-- 「月光」怪兽×2
-- ①：这张卡不会被战斗破坏。
-- ②：1回合1次，自己主要阶段1把这张卡以外的自己场上1只「月光」怪兽解放才能发动。这个回合，对方怪兽各有1次不会被战斗破坏，这张卡可以向全部对方怪兽各作2次攻击。
-- ③：这张卡的攻击宣言时发动。给与对方100伤害。
function c51777272.initial_effect(c)
	-- 为这张卡添加融合召唤手续，指定以2只「月光」怪兽作为融合素材。
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
-- 效果②的发动条件函数：判断当前是否满足发动条件，即处于自己主要阶段1且可以进入战斗阶段。
function c51777272.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否能够进入战斗阶段，用于限制效果只能在主要阶段1发动。
	return Duel.IsAbleToEnterBP()
end
-- 效果②发动代价：从自己场上选择并解放1张这张卡以外的「月光」怪兽，作为发动效果的代价。
function c51777272.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段（chk==0）检查自己场上是否存在除本卡以外、可解放的1只「月光」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,e:GetHandler(),0xdf) end
	-- 让发动玩家从自己场上选择1只除本卡以外的「月光」怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,e:GetHandler(),0xdf)
	-- 将选择的那只「月光」怪兽解放，作为效果②的发动代价。
	Duel.Release(g,REASON_COST)
end
-- 效果②处理：为对方场上所有怪兽附加本回合战斗破坏无效1次的效果，并为本卡附加本回合可向对方全部怪兽各作2次攻击的效果。
function c51777272.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②中『这个回合，对方怪兽各有1次不会被战斗破坏』的对应处理：为对方怪兽附加本回合1次不会被战斗破坏的效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c51777272.indct)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述对方怪兽1回合1次不会被战斗破坏的领域效果注册到场上，持续至结束阶段。
	Duel.RegisterEffect(e1,tp)
	if c:IsRelateToEffect(e) then
		-- ②中『这张卡可以向全部对方怪兽各作2次攻击』的对应处理：为本卡附加本回合可向对方全部怪兽各作2次攻击的效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ATTACK_ALL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(2)
		c:RegisterEffect(e2)
	end
end
-- 该函数作为EFFECT_INDESTRUCTABLE_COUNT的Value，当对方怪兽将要被战斗破坏时返回1，使其本回合首次战斗破坏无效；非战斗破坏返回0。
function c51777272.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- 效果③的发动条件与伤害设定：必发效果，发动成立后设置对象玩家为对方、伤害参数为100，并声明造成100点伤害的操作信息。
function c51777272.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家，即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数（伤害数值）设置为100。
	Duel.SetTargetParam(100)
	-- 设置效果处理信息，声明本效果将对对方造成100点伤害，以便其他卡响应时点。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,100)
end
-- 效果③伤害处理：从连锁信息中取得对象玩家和伤害数值，实际给予对方玩家效果伤害。
function c51777272.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家和伤害参数，分别存入p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对玩家p造成d点效果伤害，即给予对方100点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
