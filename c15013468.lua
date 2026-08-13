--アンドロ・スフィンクス
-- 效果：
-- 场上有「光之金字塔」存在的场合，可以支付500基本分把这张卡从手卡特殊召唤。这张卡在召唤·特殊召唤的回合不能攻击。这张卡不能作从墓地的特殊召唤。这张卡战斗破坏守备表示怪兽的场合，给与对方基本分破坏的怪兽的攻击力一半数值的伤害。
function c15013468.initial_effect(c)
	-- 这张卡不能作从墓地的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 场上有「光之金字塔」存在的场合，可以支付500基本分把这张卡从手卡特殊召唤。
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
-- 当这张卡召唤/特殊召唤成功时，为其设置一个不能攻击的效果，该效果在结束阶段或卡片离开场上等标准重置条件时消失。
function c15013468.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡在召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤函数：判断卡片是否为表侧表示且卡名为「光之金字塔」（卡号53569894），用于检索场上是否存在满足条件的卡片。
function c15013468.cfilter(c)
	return c:IsFaceup() and c:IsCode(53569894)
end
-- 特殊召唤手续的条件：当c为空时允许执行手续；否则需满足自己主要怪兽区有空位、自己可支付500基本分、且场上存在表侧表示的「光之金字塔」。
function c15013468.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的主要怪兽区空格，并且自己可以支付500基本分。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.CheckLPCost(c:GetControler(),500)
		-- 检查双方场上是否存在至少1张表侧表示的「光之金字塔」（卡号53569894）。
		and Duel.IsExistingMatchingCard(c15013468.cfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 特殊召唤手续的操作：支付500基本分作为特殊召唤代价。
function c15013468.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让当前玩家支付500基本分。
	Duel.PayLPCost(tp,500)
end
-- 伤害触发条件：这张卡战斗破坏对方怪兽，且被破坏的怪兽当时是守备表示，并且这张卡仍与战斗相关。
function c15013468.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bit.band(bc:GetBattlePosition(),POS_DEFENSE)~=0
end
-- 伤害效果的目标设定：计算被战斗破坏怪兽的攻击力一半作为伤害值（低于0按0计算），将对方玩家设为伤害对象，并登记伤害效果的操作信息。
function c15013468.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=math.floor(e:GetHandler():GetBattleTarget():GetBaseAttack()/2)
	if dam<0 then dam=0 end
	-- 将伤害对象玩家设置为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将伤害值设置为之前计算的dam值。
	Duel.SetTargetParam(dam)
	-- 登记当前连锁的操作信息：效果将造成dam点伤害，对象为对方玩家（targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果处理：从连锁信息中取出对象玩家和伤害数值，对对方玩家造成效果伤害。
function c15013468.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的目标玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害形式，向玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
