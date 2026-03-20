--ラヴァル・ウォリアー
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合自己墓地有名字带有「熔岩」的怪兽4种类以上存在的场合，给与对方基本分那次战斗破坏的怪兽的攻击力数值的伤害。
function c52786469.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合自己墓地有名字带有「熔岩」的怪兽4种类以上存在的场合，给与对方基本分那次战斗破坏的怪兽的攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52786469,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c52786469.condition)
	e1:SetTarget(c52786469.target)
	e1:SetOperation(c52786469.operation)
	c:RegisterEffect(e1)
end
-- 判断是否参与战斗且战斗破坏的怪兽为怪兽类型，并将被破坏怪兽的攻击力设为标签值
function c52786469.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabel(bc:GetAttack())
	return c:IsRelateToBattle() and bc:IsType(TYPE_MONSTER)
end
-- 设置连锁目标玩家为自己以外的玩家，以及目标参数为之前设定的攻击力值，并注册伤害类别操作信息
function c52786469.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁的目标参数为被战斗破坏怪兽的攻击力值
	Duel.SetTargetParam(e:GetLabel())
	-- 设置当前处理的连锁的操作信息为伤害效果，目标玩家为对方，伤害值为之前设定的攻击力
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 检查自己墓地是否至少存在4种不同名字带有「熔岩」的怪兽，若满足条件则对对方造成等同于被战斗破坏怪兽攻击力的伤害
function c52786469.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检索自己墓地中所有名字带有「熔岩」的怪兽，并统计其种类数，若不足4种则不执行后续操作
	if Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x39):GetClassCount(Card.GetCode)<4 then return end
	-- 从当前连锁中获取目标玩家和目标参数（即对方玩家和攻击力值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成指定数值的伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
