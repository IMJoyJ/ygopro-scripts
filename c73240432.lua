--エッジインプ・コットン・イーター
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己场上的融合怪兽的攻击力上升300。
-- ②：1回合1次，自己场上有「魔玩具」融合怪兽融合召唤的场合才能发动。自己从卡组抽1张。
-- 【怪兽效果】
-- 「锋利小鬼·棉花吞噬者」的怪兽效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。给与对方为自己墓地的「魔玩具」怪兽数量×200伤害。
function c73240432.initial_effect(c)
	-- 启用灵摆怪兽的辅助效果（灵摆召唤、灵摆卡的发动等）
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的融合怪兽的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤受攻击力上升效果影响的卡片为融合怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_FUSION))
	e1:SetValue(300)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己场上有「魔玩具」融合怪兽融合召唤的场合才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73240432,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c73240432.drcon)
	e2:SetTarget(c73240432.drtg)
	e2:SetOperation(c73240432.drop)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤成功的场合才能发动。给与对方为自己墓地的「魔玩具」怪兽数量×200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(73240432,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,73240432)
	e3:SetTarget(c73240432.damtg)
	e3:SetOperation(c73240432.damop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上融合召唤成功的「魔玩具」融合怪兽
function c73240432.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0xad) and c:IsType(TYPE_FUSION)
		and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 抽卡效果的发动条件：自己场上有「魔玩具」融合怪兽融合召唤成功
function c73240432.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c73240432.cfilter,1,nil,tp)
end
-- 抽卡效果的发动准备与操作信息设置
function c73240432.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以从卡组抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的操作信息为抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的实际处理
function c73240432.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行抽卡操作，让玩家抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
-- 过滤条件：自己墓地的「魔玩具」怪兽
function c73240432.damfilter(c)
	return c:IsSetCard(0xad) and c:IsType(TYPE_MONSTER)
end
-- 伤害效果的发动准备与操作信息设置
function c73240432.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在「魔玩具」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c73240432.damfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 计算伤害值：自己墓地的「魔玩具」怪兽数量 × 200
	local val=Duel.GetMatchingGroupCount(c73240432.damfilter,tp,LOCATION_GRAVE,0,nil)*200
	-- 设置效果的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为伤害值
	Duel.SetTargetParam(val)
	-- 设置当前连锁的操作信息为给与对方伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,val)
end
-- 伤害效果的实际处理
function c73240432.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算效果处理时自己墓地的「魔玩具」怪兽数量对应的伤害值
	local val=Duel.GetMatchingGroupCount(c73240432.damfilter,tp,LOCATION_GRAVE,0,nil)*200
	-- 执行伤害操作，给与目标玩家相应的伤害
	Duel.Damage(p,val,REASON_EFFECT)
end
