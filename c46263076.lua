--地縛神 Ccapac Apu
-- 效果：
-- 名字带有「地缚神」的怪兽在场上只能有1只表侧表示存在。场上没有表侧表示场地魔法卡存在的场合这张卡破坏。对方不能选择这张卡作为攻击对象。这张卡可以直接攻击对方玩家。这张卡战斗破坏对方怪兽的场合，给与对方基本分破坏怪兽的攻击力数值的伤害。
function c46263076.initial_effect(c)
	-- 设置场上只能存在1只名字带有「地缚神」的怪兽，且该怪兽只能在自己和对方的怪兽区域存在1张
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x1021),LOCATION_MZONE)
	-- 场上没有表侧表示场地魔法卡存在的场合这张卡破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(c46263076.sdcon)
	c:RegisterEffect(e4)
	-- 对方不能选择这张卡作为攻击对象
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	-- 设置该效果的Value为aux.imval1函数，用于判断是否能成为攻击对象
	e5:SetValue(aux.imval1)
	c:RegisterEffect(e5)
	-- 这张卡可以直接攻击对方玩家
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e6)
	-- 这张卡战斗破坏对方怪兽的场合，给与对方基本分破坏怪兽的攻击力数值的伤害
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(46263076,0))  --"伤害"
	e7:SetCategory(CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置该触发效果的条件为aux.bdocon函数，用于检测是否与对方怪兽战斗并被破坏
	e7:SetCondition(aux.bdocon)
	e7:SetTarget(c46263076.damtg)
	e7:SetOperation(c46263076.damop)
	c:RegisterEffect(e7)
end
-- 当场上没有表侧表示的场地魔法卡时，此卡破坏
function c46263076.sdcon(e)
	-- 若场上不存在表侧表示的场地魔法卡则返回true，否则返回false
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 设置伤害效果的目标玩家为对方玩家，目标参数为被战斗破坏怪兽的攻击力
function c46263076.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetBattleTarget()
	local atk=tc:GetBaseAttack()
	if atk<0 then atk=0 end
	-- 设置连锁处理中伤害效果的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理中伤害效果的目标参数为被战斗破坏怪兽的攻击力
	Duel.SetTargetParam(atk)
	-- 设置连锁操作信息为伤害效果，目标玩家为对方，伤害值为被战斗破坏怪兽的攻击力
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 执行伤害效果，对目标玩家造成对应攻击力数值的伤害
function c46263076.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取目标玩家和目标参数（即伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对指定玩家造成对应数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
