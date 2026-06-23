--トリックスター・ベラマドンナ
-- 效果：
-- 「淘气仙星」怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：连接召唤的这张卡所连接区没有怪兽存在的场合，这张卡不受其他卡发动的效果影响。
-- ②：这张卡所连接区没有怪兽存在的场合才能发动。给与对方为自己墓地的「淘气仙星」怪兽种类×200伤害。
function c41302052.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2张属于「淘气仙星」的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfb),2)
	c:EnableReviveLimit()
	-- ①：连接召唤的这张卡所连接区没有怪兽存在的场合，这张卡不受其他卡发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c41302052.imcon)
	e1:SetValue(c41302052.immval)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区没有怪兽存在的场合才能发动。给与对方为自己墓地的「淘气仙星」怪兽种类×200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41302052,0))  --"给予伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,41302052)
	e2:SetCondition(c41302052.damcon)
	e2:SetTarget(c41302052.damtg)
	e2:SetOperation(c41302052.damop)
	c:RegisterEffect(e2)
end
-- 效果条件：这张卡是连接召唤且类型为连接怪兽，并且连接区没有怪兽存在
function c41302052.imcon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:IsType(TYPE_LINK) and c:GetLinkedGroupCount()==0
end
-- 效果值：当其他卡的效果被发动时，若该效果的持有者不是自己，则该效果不适用
function c41302052.immval(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActivated()
end
-- 伤害效果发动条件：这张卡是连接怪兽，并且连接区没有怪兽存在
function c41302052.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsType(TYPE_LINK) and c:GetLinkedGroupCount()==0
end
-- 伤害效果的卡片过滤器：筛选墓地里属于「淘气仙星」的怪兽
function c41302052.damfilter(c)
	return c:IsSetCard(0xfb) and c:IsType(TYPE_MONSTER)
end
-- 伤害效果的处理函数：检查墓地是否存在「淘气仙星」怪兽，计算种类数乘以200作为伤害值，并设置连锁操作信息
function c41302052.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：墓地是否存在至少1张「淘气仙星」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41302052.damfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 获取满足条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(c41302052.damfilter,tp,LOCATION_GRAVE,0,nil)
	local dam=g:GetClassCount(Card.GetCode)*200
	-- 设置连锁的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁的目标参数为计算出的伤害值
	Duel.SetTargetParam(dam)
	-- 设置连锁操作信息，指定伤害效果类别和目标玩家及伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的执行函数：根据墓地「淘气仙星」怪兽数量计算伤害值并给予对方
function c41302052.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 再次获取满足条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(c41302052.damfilter,tp,LOCATION_GRAVE,0,nil)
	local dam=g:GetClassCount(Card.GetCode)*200
	-- 以效果原因对目标玩家造成指定伤害值
	Duel.Damage(p,dam,REASON_EFFECT)
end
