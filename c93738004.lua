--空牙団の孤高 サジータ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。给与对方为「空牙团的孤高 莎吉塔」以外的自己场上的「空牙团」怪兽种类×500伤害。
-- ②：只要这张卡在怪兽区域存在，对方不能把这张卡以外的自己场上的「空牙团」怪兽作为效果的对象。
function c93738004.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡特殊召唤成功的场合才能发动。给与对方为「空牙团的孤高 莎吉塔」以外的自己场上的「空牙团」怪兽种类×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93738004,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,93738004)
	e1:SetTarget(c93738004.damtg)
	e1:SetOperation(c93738004.damop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方不能把这张卡以外的自己场上的「空牙团」怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c93738004.tgtg)
	-- 设置不能成为对方卡的效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「空牙团的孤高 莎吉塔」以外的「空牙团」怪兽
function c93738004.damfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114) and not c:IsCode(93738004)
end
-- ①号效果的发动准备（检查可行性并计算伤害值以设置操作信息）
function c93738004.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只「空牙团的孤高 莎吉塔」以外的表侧表示「空牙团」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c93738004.damfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有「空牙团的孤高 莎吉塔」以外的表侧表示「空牙团」怪兽
	local g=Duel.GetMatchingGroup(c93738004.damfilter,tp,LOCATION_MZONE,0,nil)
	local dam=g:GetClassCount(Card.GetCode)*500
	-- 设置效果处理的操作信息为给与对方玩家计算出的伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- ①号效果的效果处理（计算种类并给与对方伤害）
function c93738004.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有「空牙团的孤高 莎吉塔」以外的表侧表示「空牙团」怪兽
	local g=Duel.GetMatchingGroup(c93738004.damfilter,tp,LOCATION_MZONE,0,nil)
	local dam=g:GetClassCount(Card.GetCode)*500
	-- 给与对方玩家计算出的伤害
	Duel.Damage(1-tp,dam,REASON_EFFECT)
end
-- 过滤自身以外的自己场上的「空牙团」怪兽
function c93738004.tgtg(e,c)
	return c~=e:GetHandler() and c:IsSetCard(0x114)
end
