--アーマー・カッパー
-- 效果：
-- 2星怪兽×2
-- 「铠甲河童」的②的效果在决斗中只能使用1次。
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力或者守备力上升1000。
-- ②：自己怪兽进行战斗的战斗步骤，丢弃1张手卡才能发动。这个回合，自己场上的怪兽不会被战斗破坏，自己受到的战斗伤害全部变成0。
function c50789693.initial_effect(c)
	-- 为卡片添加等级为2、需要2只怪兽进行叠放的XYZ召唤手续
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
-- 效果处理函数：检查是否能移除1个超量素材作为代价
function c50789693.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果处理函数：选择攻击力或守备力上升1000
function c50789693.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 让玩家从攻击力上升和守备力上升中选择一项
		local opt=Duel.SelectOption(tp,aux.Stringid(50789693,2),aux.Stringid(50789693,3))  --"攻击力上升1000/守备力上升1000"
		-- 根据选择结果为卡片添加攻击力或守备力上升1000的效果
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
-- 条件判断函数：检查是否有己方怪兽参与战斗
function c50789693.btcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local bt=Duel.GetAttacker()
	if bt and bt:IsControler(tp) then return true end
	-- 获取当前攻击目标怪兽
	bt=Duel.GetAttackTarget()
	return bt and bt:IsControler(tp)
end
-- 效果处理函数：检查是否能丢弃1张手卡作为代价
function c50789693.btcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从玩家手牌中丢弃1张可丢弃的卡片
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果处理函数：为己方玩家和场上怪兽注册战斗伤害无效和不会被战斗破坏的效果
function c50789693.btop(e,tp,eg,ep,ev,re,r,rp)
	-- 为己方玩家注册战斗伤害全部变为0的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
	-- 为己方场上怪兽注册不会被战斗破坏的效果
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	-- 将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
end
