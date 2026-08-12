--アンドロ・スフィンクス
-- 效果：
-- 场上有「光之金字塔」存在的场合，可以支付500基本分把这张卡从手卡特殊召唤。这张卡在召唤·特殊召唤的回合不能攻击。这张卡不能作从墓地的特殊召唤。这张卡战斗破坏守备表示怪兽的场合，给与对方基本分破坏的怪兽的攻击力一半数值的伤害。
function c15013468.initial_effect(c)
	-- 场上有「光之金字塔」存在的场合，可以支付500基本分把这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡不能作从墓地的特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c15013468.spcon)
	e2:SetOperation(c15013468.spop)
	c:RegisterEffect(e2)
	-- 这张卡战斗破坏守备表示怪兽的场合，给与对方基本分破坏的怪兽的攻击力一半数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15013468,0))  --"LP伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c15013468.damcon)
	e3:SetTarget(c15013468.damtg)
	e3:SetOperation(c15013468.damop)
	c:RegisterEffect(e3)
	-- 这张卡在召唤·特殊召唤的回合不能攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(c15013468.atklimit)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 将目标怪兽设置为不能攻击状态直到回合结束。
function c15013468.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽设置为不能攻击状态直到回合结束。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 检查场上是否存在「光之金字塔」。
function c15013468.cfilter(c)
	return c:IsFaceup() and c:IsCode(53569894)
end
-- 检查是否满足特殊召唤条件：有空场、能支付500LP、场上有「光之金字塔」。
function c15013468.spcon(e,c)
	if c==nil then return true end
	-- 检查是否有足够的场上空位和是否能支付500LP。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.CheckLPCost(c:GetControler(),500)
		-- 检查场上是否存在「光之金字塔」。
		and Duel.IsExistingMatchingCard(c15013468.cfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 支付500LP作为特殊召唤的代价。
function c15013468.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 支付500LP作为特殊召唤的代价。
	Duel.PayLPCost(tp,500)
end
-- 判断战斗破坏的怪兽是否为守备表示。
function c15013468.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bit.band(bc:GetBattlePosition(),POS_DEFENSE)~=0
end
-- 设置伤害效果的目标玩家和伤害值。
function c15013468.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=math.floor(e:GetHandler():GetBattleTarget():GetBaseAttack()/2)
	if dam<0 then dam=0 end
	-- 设置伤害效果的目标玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的伤害值。
	Duel.SetTargetParam(dam)
	-- 设置连锁操作信息为伤害效果。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行伤害效果，对目标玩家造成指定伤害。
function c15013468.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成指定伤害值的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
