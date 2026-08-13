--地縛神 Ccapac Apu
-- 效果：
-- 名字带有「地缚神」的怪兽在场上只能有1只表侧表示存在。场上没有表侧表示场地魔法卡存在的场合这张卡破坏。对方不能选择这张卡作为攻击对象。这张卡可以直接攻击对方玩家。这张卡战斗破坏对方怪兽的场合，给与对方基本分破坏怪兽的攻击力数值的伤害。
function c46263076.initial_effect(c)
	-- 设置这张卡在主要怪兽区与名字带有「地缚神」的怪兽合计只能有1只表侧表示存在，己方和对方场上均进行唯一性检查。
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x1021),LOCATION_MZONE)
	-- 场上没有表侧表示场地魔法卡存在的场合这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(c46263076.sdcon)
	c:RegisterEffect(e4)
	-- 对方不能选择这张卡作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	-- 将“不能成为攻击对象”的判定值设为函数 aux.imval1，即只要此卡不免疫该效果，对方就不能将其选为攻击对象。
	e5:SetValue(aux.imval1)
	c:RegisterEffect(e5)
	-- 这张卡可以直接攻击对方玩家。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e6)
	-- 这张卡战斗破坏对方怪兽的场合，给与对方基本分破坏怪兽的攻击力数值的伤害。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(46263076,0))  --"伤害"
	e7:SetCategory(CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置该诱发效果的发动条件：此卡与对方怪兽战斗并战斗破坏该怪兽的场合才能发动。
	e7:SetCondition(aux.bdocon)
	e7:SetTarget(c46263076.damtg)
	e7:SetOperation(c46263076.damop)
	c:RegisterEffect(e7)
end
-- 自我破坏效果的条件函数：检查双方场地区是否存在表侧表示的场地魔法卡，不存在时返回真。
function c46263076.sdcon(e)
	-- 返回真，当且仅当双方场地区不存在任何表侧表示的场地魔法卡。
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 伤害诱发效果的目标设定函数：取得被战斗破坏的对方怪兽的原本攻击力，负值按0处理，并将对象玩家设为对方、伤害值设为该攻击力，同时登记操作信息。
function c46263076.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetBattleTarget()
	local atk=tc:GetBaseAttack()
	if atk<0 then atk=0 end
	-- 将当前连锁效果的对象玩家设置为对方玩家，即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁效果的对象参数为战斗破坏的对方怪兽的原本攻击力数值，作为后续伤害计算值。
	Duel.SetTargetParam(atk)
	-- 向连锁系统登记本次效果处理将造成伤害：类别为伤害，不取对象，对象玩家为对方，伤害值为 atk。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 伤害效果的实际处理函数：取出之前设定的目标玩家和伤害值，给该玩家造成效果伤害。
function c46263076.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取效果设定的对象玩家和伤害数值，分别赋给 p 和 d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式，给予玩家 p 数值为 d 的伤害，即给对方造成战斗破坏怪兽原本攻击力数值的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
