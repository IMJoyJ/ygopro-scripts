--アーマー・カッパー
-- 效果：
-- 2星怪兽×2
-- 「铠甲河童」的②的效果在决斗中只能使用1次。
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力或者守备力上升1000。
-- ②：自己怪兽进行战斗的战斗步骤，丢弃1张手卡才能发动。这个回合，自己场上的怪兽不会被战斗破坏，自己受到的战斗伤害全部变成0。
function c50789693.initial_effect(c)
	-- 为铠甲河童添加XYZ召唤手续：以2只2星怪兽作为超量素材来超量召唤。
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力或者守备力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetDescription(aux.Stringid(50789693,0))  --"攻守上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c50789693.adcost)
	e1:SetOperation(c50789693.adop)
	c:RegisterEffect(e1)
	-- ②：自己怪兽进行战斗的战斗步骤，丢弃1张手卡才能发动。这个回合，自己场上的怪兽不会被战斗破坏，自己受到的战斗伤害全部变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50789693,1))  --"破坏耐性"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCountLimit(1,50789693+EFFECT_COUNT_CODE_DUEL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_BATTLE_PHASE)
	e2:SetCondition(c50789693.btcon)
	e2:SetCost(c50789693.btcost)
	e2:SetOperation(c50789693.btop)
	c:RegisterEffect(e2)
end
-- ①效果的代价处理：检查这张卡是否有1个超量素材可以作为代价取除，并在发动时实际取除1个超量素材。
function c50789693.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果处理：根据选择，使这张卡的攻击力或守备力上升1000，该增减效果在怪兽离场或效果被无效时重置。
function c50789693.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 玩家在“攻击力上升1000”和“守备力上升1000”两个选项中选择一个（返回0或1）。
		local opt=Duel.SelectOption(tp,aux.Stringid(50789693,2),aux.Stringid(50789693,3))  --"攻击力上升1000/守备力上升1000"
		-- 这张卡的攻击力或者守备力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		if opt==0 then
			e1:SetCode(EFFECT_UPDATE_ATTACK)
		else
			e1:SetCode(EFFECT_UPDATE_DEFENSE)
		end
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：自己场上有怪兽正在进行战斗（包括攻击宣言的怪兽或被攻击的怪兽）。
function c50789693.btcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前战斗的攻击怪兽。
	local bt=Duel.GetAttacker()
	if bt and bt:IsControler(tp) then return true end
	-- 若攻击怪兽不是己方怪兽，则取得当前战斗的被攻击怪兽，用于判断是否为己方怪兽。
	bt=Duel.GetAttackTarget()
	return bt and bt:IsControler(tp)
end
-- ②效果的代价：从手牌丢弃1张卡作为发动代价。
function c50789693.btcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己手牌中是否存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手牌丢弃1张可以丢弃的卡（理由为代价+丢弃）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ②效果处理：本回合内，我方受到的战斗伤害全部变成0，且我方场上的怪兽不会被战斗破坏。
function c50789693.btop(e,tp,eg,ep,ev,re,r,rp)
	-- 自己受到的战斗伤害全部变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将‘我方受到的战斗伤害变为0’的效果注册到当前玩家tp，该效果持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	-- 自己场上的怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	-- 将‘我方场上的怪兽不会被战斗破坏’的效果注册到当前玩家tp，持续到结束阶段。
	Duel.RegisterEffect(e2,tp)
end
