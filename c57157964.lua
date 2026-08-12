--古生代化石マシン スカルコンボイ
-- 效果：
-- 自己墓地的岩石族怪兽＋7星以上的怪兽
-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。
-- ①：只要融合召唤的这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降那怪兽的原本守备力数值。
-- ②：这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
-- ③：这张卡战斗破坏对方怪兽时才能发动。给与对方1000伤害。
function c57157964.initial_effect(c)
	-- 在卡片中记录关联了卡片密码为59419719（化石融合）的卡片
	aux.AddCodeList(c,59419719)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，素材为满足matfilter过滤条件的怪兽（自己墓地的岩石族）和7星以上的怪兽各1只
	aux.AddFusionProcFun2(c,c57157964.matfilter,aux.FilterBoolFunction(Card.IsLevelAbove,7),true)
	-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制条件为只能通过「化石融合」的效果从额外卡组特殊召唤
	e1:SetValue(aux.FossilFusionLimit)
	c:RegisterEffect(e1)
	-- ②：这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetValue(2)
	c:RegisterEffect(e2)
	-- ③：这张卡战斗破坏对方怪兽时才能发动。给与对方1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(57157964,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- 设置效果发动条件为自身战斗破坏对方怪兽并送去墓地
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(c57157964.damtg)
	e3:SetOperation(c57157964.damop)
	c:RegisterEffect(e3)
	-- ①：只要融合召唤的这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降那怪兽的原本守备力数值。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(c57157964.atkcon)
	e4:SetValue(c57157964.atkval)
	c:RegisterEffect(e4)
end
-- 过滤融合素材：属于自己且存在于墓地的岩石族怪兽
function c57157964.matfilter(c,fc)
	return c:IsRace(RACE_ROCK) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(fc:GetControler())
end
-- 伤害效果的发动准备与目标确认
function c57157964.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的参数值为1000
	Duel.SetTargetParam(1000)
	-- 设置连锁的操作信息，包含给与对方玩家1000点伤害的效果分类
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 伤害效果的执行函数
function c57157964.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 攻击力下降效果的适用条件：自身是通过融合召唤特殊召唤的
function c57157964.atkcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 计算攻击力下降的数值，返回目标怪兽原本守备力的负值
function c57157964.atkval(e,c)
	local val=math.max(c:GetBaseDefense(),0)
	return val*-1
end
