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
-- 诱发效果的发动条件：这张卡与怪兽进行战斗并将其战斗破坏，且此时这张卡仍与本次战斗关联（未离场）；同时将战斗破坏的怪兽的当前攻击力记录到效果的标签，作为之后伤害的数值。
function c52786469.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabel(bc:GetAttack())
	return c:IsRelateToBattle() and bc:IsType(TYPE_MONSTER)
end
-- 必发效果的发动时处理：无需选择对象，直接记录伤害对象为对方玩家，伤害数值为标签中保存的攻击力，并设定操作信息为造成伤害。
function c52786469.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为对方玩家，表示后续伤害给予对方基本分。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设为之前记录的战斗破坏怪兽的攻击力数值，作为将要造成的伤害值。
	Duel.SetTargetParam(e:GetLabel())
	-- 设定操作信息：本连锁将造成伤害，伤害对象为对方玩家，伤害数值为记录的攻击力；该信息供其他效果（如星尘龙）进行联动判断。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 效果处理时，先检查自己墓地中名字带有「熔岩」的怪兽是否达到4种类以上，若满足则从连锁信息中读取对象玩家和伤害值，对其造成效果伤害。
function c52786469.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己墓地中所有名字带有「熔岩」的怪兽，并按卡名统计种类数；若种类数少于4，则直接结束处理，不给予伤害。
	if Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x39):GetClassCount(Card.GetCode)<4 then return end
	-- 从当前连锁信息中取出之前设定的对象玩家和伤害参数，分别赋给变量 p 和 d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对玩家 p 造成 d 点效果伤害，伤害原因为卡片效果。
	Duel.Damage(p,d,REASON_EFFECT)
end
