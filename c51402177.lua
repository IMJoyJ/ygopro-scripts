--スフィンクス・テーレイア
-- 效果：
-- 场上有「光之金字塔」存在的场合，可以支付500基本分把这张卡从手卡特殊召唤。这张卡在召唤·特殊召唤的回合不能攻击。这张卡不能作从墓地的特殊召唤。这张卡战斗破坏守备表示怪兽的场合，给与对方基本分破坏的怪兽的守备力一半数值的伤害。
function c51402177.initial_effect(c)
	-- 效果原文：场上有「光之金字塔」存在的场合，可以支付500基本分把这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡在召唤·特殊召唤的回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c51402177.spcon)
	e2:SetOperation(c51402177.spop)
	c:RegisterEffect(e2)
	-- 效果原文：这张卡不能作从墓地的特殊召唤。
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
	-- 效果原文：这张卡战斗破坏守备表示怪兽的场合，给与对方基本分破坏的怪兽的守备力一半数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(c51402177.atklimit)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 代码作用：使该卡在召唤成功后无法攻击
function c51402177.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 代码作用：设置该卡在结束阶段重置无法攻击效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 代码作用：过滤场上存在的「光之金字塔」
function c51402177.cfilter(c)
	return c:IsFaceup() and c:IsCode(53569894)
end
-- 代码作用：检查是否满足特殊召唤条件（支付LP、有「光之金字塔」、场上存在空位）
function c51402177.spcon(e,c)
	if c==nil then return true end
	-- 代码作用：检查玩家是否能支付500基本分
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.CheckLPCost(c:GetControler(),500)
		-- 代码作用：检查场上是否存在「光之金字塔」
		and Duel.IsExistingMatchingCard(c51402177.cfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 代码作用：支付500基本分的特殊召唤操作
function c51402177.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 代码作用：扣除玩家500基本分
	Duel.PayLPCost(tp,500)
end
-- 代码作用：判断是否满足伤害效果发动条件（战斗破坏守备表示怪兽）
function c51402177.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsType(TYPE_MONSTER) and bit.band(bc:GetBattlePosition(),POS_DEFENSE)~=0
end
-- 代码作用：设置伤害效果的目标玩家和伤害值
function c51402177.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=math.floor(e:GetHandler():GetBattleTarget():GetBaseDefense()/2)
	if dam<0 then dam=0 end
	-- 代码作用：设定连锁处理中伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 代码作用：设定连锁处理中伤害效果的伤害值
	Duel.SetTargetParam(dam)
	-- 代码作用：设置连锁操作信息，包含伤害效果的分类、目标玩家与伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 代码作用：执行对敌方造成伤害的操作
function c51402177.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 代码作用：获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 代码作用：以REASON_EFFECT原因对指定玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
