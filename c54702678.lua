--極戦機王ヴァルバロイド
-- 效果：
-- 名字带有「机人」的机械族怪兽×5
-- 这张卡在同1次的战斗阶段中可以作2次攻击。这张卡攻击的对方的效果怪兽的效果在伤害计算后无效化。这张卡战斗破坏对方怪兽的场合，给与对方基本分1000分伤害。这张卡不能向对方玩家直接攻击。
function c54702678.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤手续，需要5只满足特定条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c54702678.ffilter,5,true)
	-- 这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡攻击的对方的效果怪兽的效果在伤害计算后无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54702678,0))  --"效果无效"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c54702678.discon)
	e2:SetOperation(c54702678.disop)
	c:RegisterEffect(e2)
	-- 这张卡战斗破坏对方怪兽的场合，给与对方基本分1000分伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(54702678,1))  --"1000伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(c54702678.damcon)
	e3:SetTarget(c54702678.damtg)
	e3:SetOperation(c54702678.damop)
	c:RegisterEffect(e3)
	-- 这张卡不能向对方玩家直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e4)
end
-- 过滤融合素材：名字带有「机人」的机械族怪兽
function c54702678.ffilter(c)
	return c:IsFusionSetCard(0x16) and c:IsRace(RACE_MACHINE)
end
-- 判断是否满足效果无效化的发动条件：自身进行攻击且存在攻击对象
function c54702678.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否存在攻击对象，且自身是否为攻击怪兽
	return Duel.GetAttackTarget() and e:GetHandler()==Duel.GetAttacker()
end
-- 执行效果无效化：使战斗对象的怪兽效果以及发动的效果无效化
function c54702678.disop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	-- 效果在伤害计算后无效化。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x57a0000)
	bc:RegisterEffect(e1)
	-- 效果在伤害计算后无效化。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x57a0000)
	bc:RegisterEffect(e2)
end
-- 判断是否满足伤害效果的发动条件：自身仍在战斗中且战斗破坏的卡是怪兽
function c54702678.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 设置伤害效果的目标玩家、伤害数值以及操作信息
function c54702678.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为1000
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为给与对方玩家1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 执行伤害效果：获取目标玩家和伤害数值并给与伤害
function c54702678.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
