--極星邪龍ヨルムンガンド
-- 效果：
-- 这张卡不能通常召唤。场上有「极神」怪兽存在的场合可以从手卡往对方场上守备表示特殊召唤。
-- ①：场上没有「极神」怪兽存在的场合这张卡破坏。
-- ②：只在这张卡在场上表侧表示存在才有1次，表侧守备表示的这张卡变成表侧攻击表示的场合发动。自己受到3000伤害。
function c64203620.initial_effect(c)
	c:EnableReviveLimit()
	-- 场上有「极神」怪兽存在的场合可以从手卡往对方场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64203620,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,1)
	e1:SetCondition(c64203620.spcon)
	c:RegisterEffect(e1)
	-- ①：场上没有「极神」怪兽存在的场合这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(c64203620.descon)
	c:RegisterEffect(e4)
	-- ②：只在这张卡在场上表侧表示存在才有1次，表侧守备表示的这张卡变成表侧攻击表示的场合发动。自己受到3000伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(64203620,1))  --"3000伤害"
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e5:SetCode(EVENT_CHANGE_POS)
	e5:SetCountLimit(1)
	e5:SetCondition(c64203620.damcon)
	e5:SetTarget(c64203620.damtg)
	e5:SetOperation(c64203620.damop)
	c:RegisterEffect(e5)
end
-- 特殊召唤规则的条件：对方怪兽区域有空位，且场上存在「极神」怪兽
function c64203620.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查双方场上是否存在至少1张表侧表示的「极神」怪兽
		and Duel.IsExistingMatchingCard(c64203620.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤条件：表侧表示且属于「极神」系列的怪兽
function c64203620.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b)
end
-- 自我破坏效果的条件：场上不存在表侧表示的「极神」怪兽
function c64203620.descon(e)
	-- 检查双方场上是否不存在表侧表示的「极神」怪兽
	return not Duel.IsExistingMatchingCard(c64203620.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 伤害效果的发动条件：此卡由表侧守备表示变成表侧攻击表示
function c64203620.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK) and e:GetHandler():IsPreviousPosition(POS_FACEUP_DEFENSE)
end
-- 伤害效果的靶向：设置自己为受到伤害的玩家，伤害数值为3000，并声明伤害操作信息
function c64203620.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为发动效果的玩家（自己）
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为3000
	Duel.SetTargetParam(3000)
	-- 设置当前连锁的操作信息为给与玩家3000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,3000)
end
-- 伤害效果的执行：获取目标玩家和伤害值，并给与该玩家对应的效果伤害
function c64203620.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
