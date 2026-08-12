--地縛神 Chacu Challhua
-- 效果：
-- 名字带有「地缚神」的怪兽在场上只能有1只表侧表示存在。场上没有表侧表示场地魔法卡存在的场合这张卡破坏。对方不能选择这张卡作为攻击对象。这张卡可以直接攻击对方玩家。1回合1次，可以给与对方基本分这张卡的守备力一半数值的伤害。这个效果发动的回合，这张卡不能攻击。此外，这张卡在场上表侧守备表示存在的场合，对方不能进行战斗阶段。
function c69931927.initial_effect(c)
	-- 设置场上只能有1只表侧表示的「地缚神」怪兽存在。
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x1021),LOCATION_MZONE)
	-- 场上没有表侧表示场地魔法卡存在的场合这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(c69931927.sdcon)
	c:RegisterEffect(e4)
	-- 对方不能选择这张卡作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	-- 设置不能成为攻击对象效果的过滤函数，使自身不会被不受效果影响的怪兽选择为攻击对象。
	e5:SetValue(aux.imval1)
	c:RegisterEffect(e5)
	-- 这张卡可以直接攻击对方玩家。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e6)
	-- 1回合1次，可以给与对方基本分这张卡的守备力一半数值的伤害。这个效果发动的回合，这张卡不能攻击。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(69931927,0))  --"伤害"
	e7:SetCategory(CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetCost(c69931927.damcost)
	e7:SetTarget(c69931927.damtg)
	e7:SetOperation(c69931927.damop)
	c:RegisterEffect(e7)
	-- 此外，这张卡在场上表侧守备表示存在的场合，对方不能进行战斗阶段。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetCode(EFFECT_CANNOT_BP)
	e8:SetRange(LOCATION_MZONE)
	e8:SetTargetRange(0,1)
	e8:SetCondition(c69931927.bpcon)
	c:RegisterEffect(e8)
end
-- 自我破坏效果的判定条件函数。
function c69931927.sdcon(e)
	-- 检查双方场地区域是否存在表侧表示的场地魔法卡，若不存在则返回true。
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 伤害效果的发动代价与限制处理函数。
function c69931927.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 伤害效果的发动目标与参数设定函数。
function c69931927.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=math.floor(e:GetHandler():GetDefense()/2)
	-- 设置当前连锁的对象玩家为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为计算出的伤害数值。
	Duel.SetTargetParam(dam)
	-- 设置连锁的操作信息，表明此效果会给与对方玩家指定数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的执行函数。
function c69931927.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 依效果给与目标玩家对应的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 对方不能进行战斗阶段效果的适用条件函数（自身必须表侧守备表示）。
function c69931927.bpcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
