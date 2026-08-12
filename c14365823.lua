--トリックスター・ディーヴァリディス
-- 效果：
-- 3星以下的「淘气仙星」怪兽2只
-- ①：「淘气仙星·蒂瓦丽迪丝」在自己场上只能有1只表侧表示存在。
-- ②：这张卡特殊召唤成功的场合才能发动。给与对方200伤害。
-- ③：每次对方对怪兽的召唤·特殊召唤成功发动。给与对方200伤害。
function c14365823.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,14365823)
	-- 添加连接召唤手续，使用满足过滤条件的怪兽作为连接素材，最少需要2只，最多2只。
	aux.AddLinkProcedure(c,c14365823.mfilter,2,2)
	-- ②：这张卡特殊召唤成功的场合才能发动。给与对方200伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14365823,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c14365823.damtg)
	e1:SetOperation(c14365823.damop)
	c:RegisterEffect(e1)
	-- ③：每次对方对怪兽的召唤·特殊召唤成功发动。给与对方200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14365823,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c14365823.damcon2)
	e2:SetTarget(c14365823.damtg)
	e2:SetOperation(c14365823.damop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的怪兽：连接属性为淘气仙星且等级不超过3的怪兽。
function c14365823.mfilter(c)
	return c:IsLinkSetCard(0xfb) and c:IsLevelBelow(3)
end
-- 设置伤害效果的目标玩家和参数，准备造成伤害。
function c14365823.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的目标参数为200点伤害。
	Duel.SetTargetParam(200)
	-- 设置连锁操作信息为造成伤害效果，目标玩家为对方，伤害值为200。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,200)
end
-- 执行伤害效果，对指定玩家造成指定伤害。
function c14365823.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标玩家和伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害，伤害原因为效果。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 过滤满足条件的怪兽：召唤玩家为指定玩家的怪兽。
function c14365823.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 判断是否满足触发条件：对方有怪兽被召唤或特殊召唤成功。
function c14365823.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c14365823.cfilter,1,nil,1-tp)
end
