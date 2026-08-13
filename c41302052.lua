--トリックスター・ベラマドンナ
-- 效果：
-- 「淘气仙星」怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：连接召唤的这张卡所连接区没有怪兽存在的场合，这张卡不受其他卡发动的效果影响。
-- ②：这张卡所连接区没有怪兽存在的场合才能发动。给与对方为自己墓地的「淘气仙星」怪兽种类×200伤害。
function c41302052.initial_effect(c)
	-- 为这张卡设定连接召唤手续：必须以2只以上持有「淘气仙星」字段的连接怪兽作为连接素材。
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
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡所连接区没有怪兽存在的场合才能发动。给与对方为自己墓地的「淘气仙星」怪兽种类×200伤害。
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
-- ①免疫效果的适用条件：此卡为连接召唤出的连接怪兽，且其连接区没有怪兽存在时，免疫效果适用。
function c41302052.imcon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:IsType(TYPE_LINK) and c:GetLinkedGroupCount()==0
end
-- 免疫效果的判定值：若来源效果不是这张卡自身，并且是已发动的效果，则这张卡不受其影响。
function c41302052.immval(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActivated()
end
-- ②效果的发动条件：这张卡为连接怪兽，且其连接区没有怪兽存在时才能发动。
function c41302052.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsType(TYPE_LINK) and c:GetLinkedGroupCount()==0
end
-- 墓地中符合「淘气仙星」字段的怪兽卡过滤条件，用于统计伤害所需的怪兽种类。
function c41302052.damfilter(c)
	return c:IsSetCard(0xfb) and c:IsType(TYPE_MONSTER)
end
-- ②效果发动时的目标处理：确认自己墓地存在「淘气仙星」怪兽；取得墓地所有该类怪兽，按不同卡名数×200计算伤害；将对方设为伤害对象，并登记伤害数值与操作信息。
function c41302052.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：在效果发动前（chk==0）确认自己墓地至少存在1张「淘气仙星」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c41302052.damfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 取得自己墓地中所有「淘气仙星」怪兽组成的集合，用于计算伤害种类数。
	local g=Duel.GetMatchingGroup(c41302052.damfilter,tp,LOCATION_GRAVE,0,nil)
	local dam=g:GetClassCount(Card.GetCode)*200
	-- 将当前连锁的效果对象玩家设为对方（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的效果参数设为dam，即墓地「淘气仙星」怪兽不同卡名数×200的伤害值。
	Duel.SetTargetParam(dam)
	-- 登记操作信息：效果分类为造成伤害，目标玩家为对方，预计伤害数值为dam（不取对象，因此目标卡为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- ②效果处理时的实际操作：从连锁信息取得承受伤害的玩家，重新计算自己墓地「淘气仙星」怪兽不同卡名数×200，给予该玩家等量伤害。
function c41302052.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁的登记信息中取出承受伤害的玩家（即之前设定的对方）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果处理时再次取得自己墓地中所有「淘气仙星」怪兽，用于按当前状态计算伤害。
	local g=Duel.GetMatchingGroup(c41302052.damfilter,tp,LOCATION_GRAVE,0,nil)
	local dam=g:GetClassCount(Card.GetCode)*200
	-- 给予玩家p造成dam点效果伤害，伤害来源标识为REASON_EFFECT。
	Duel.Damage(p,dam,REASON_EFFECT)
end
