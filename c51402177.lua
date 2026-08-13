--スフィンクス・テーレイア
-- 效果：
-- 场上有「光之金字塔」存在的场合，可以支付500基本分把这张卡从手卡特殊召唤。这张卡在召唤·特殊召唤的回合不能攻击。这张卡不能作从墓地的特殊召唤。这张卡战斗破坏守备表示怪兽的场合，给与对方基本分破坏的怪兽的守备力一半数值的伤害。
function c51402177.initial_effect(c)
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
	e2:SetCondition(c51402177.spcon)
	e2:SetOperation(c51402177.spop)
	c:RegisterEffect(e2)
	-- 这张卡战斗破坏守备表示怪兽的场合，给与对方基本分破坏的怪兽的守备力一半数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51402177,0))  --"LP伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c51402177.damcon)
	e3:SetTarget(c51402177.damtg)
	e3:SetOperation(c51402177.damop)
	c:RegisterEffect(e3)
	-- 这张卡在召唤·特殊召唤的回合不能攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(c51402177.atklimit)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 在召唤或特殊召唤成功时，为这张卡本身赋予一个不能攻击的持续效果，该效果持续到本回合结束。
function c51402177.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡在召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 判断卡片是否为表侧表示且卡号为53569894（即「光之金字塔」），用于检索场上是否存在「光之金字塔」。
function c51402177.cfilter(c)
	return c:IsFaceup() and c:IsCode(53569894)
end
-- 特殊召唤条件：检查是否有空余的主要怪兽区、能否支付500基本分，以及场上是否存在表侧表示的「光之金字塔」；c==nil时作为规则咨询返回true。
function c51402177.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者场上主要怪兽区是否还有空位，并且其基本分是否足够支付500。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.CheckLPCost(c:GetControler(),500)
		-- 检查双方场上是否存在至少1张表侧表示的「光之金字塔」（卡号53569894）。
		and Duel.IsExistingMatchingCard(c51402177.cfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 特殊召唤手续的操作部分，即实际支付500基本分完成从手卡特殊召唤的代价。
function c51402177.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让当前玩家tp支付500基本分作为特殊召唤的代价。
	Duel.PayLPCost(tp,500)
end
-- 伤害效果的发动条件：这张卡仍在场上、与怪兽进行战斗，且该战斗对象为守备表示怪兽（本次战斗破坏守备表示怪兽时满足）。
function c51402177.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsType(TYPE_MONSTER) and bit.band(bc:GetBattlePosition(),POS_DEFENSE)~=0
end
-- 伤害效果的发动时点：计算被战斗破坏的怪兽原守备力的一半作为伤害值（向下取整且不小于0），将伤害对象设为对方，并把该伤害写入操作信息。
function c51402177.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=math.floor(e:GetHandler():GetBattleTarget():GetBaseDefense()/2)
	if dam<0 then dam=0 end
	-- 将本次效果的对象玩家设为对方（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将本次效果的对象参数设为伤害数值dam。
	Duel.SetTargetParam(dam)
	-- 登记操作信息，声明将给予对方dam点效果伤害，供其他卡进行发动判定和连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果处理：从连锁信息中取出目标玩家和伤害值，并对该玩家造成伤害。
function c51402177.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的目标玩家和目标参数（伤害值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的方式对玩家p造成d点生命值伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
