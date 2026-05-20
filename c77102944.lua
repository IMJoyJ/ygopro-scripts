--洗濯機塊ランドリードラゴン
-- 效果：
-- 「机块」怪兽1只
-- 这张卡在连接召唤的回合不能作为连接素材。
-- ①：这张卡的战斗发生的双方的战斗伤害变成0。
-- ②：1回合1次，互相连接状态的这张卡在和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽除外。
-- ③：1回合1次，不在互相连接状态的这张卡在和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽破坏，给与对方那个原本攻击力数值的伤害。
function c77102944.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：需要1只「机块」怪兽
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x14b),1,1)
	-- 这张卡在连接召唤的回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(c77102944.lmlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡的战斗发生的双方的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：这张卡的战斗发生的双方的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：1回合1次，互相连接状态的这张卡在和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(77102944,0))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c77102944.rmcon)
	e4:SetTarget(c77102944.rmtg)
	e4:SetOperation(c77102944.rmop)
	c:RegisterEffect(e4)
	-- ③：1回合1次，不在互相连接状态的这张卡在和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽破坏，给与对方那个原本攻击力数值的伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(77102944,1))
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLED)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c77102944.descon)
	e5:SetTarget(c77102944.destg)
	e5:SetOperation(c77102944.desop)
	c:RegisterEffect(e5)
end
-- 限制此卡在连接召唤的回合不能作为连接素材
function c77102944.lmlimit(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果②的发动条件：此卡处于互相连接状态，且与对方怪兽进行战斗的伤害计算后
function c77102944.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not bc then return false end
	e:SetLabelObject(bc)
	return c:GetMutualLinkedGroupCount()>0 and c:IsStatus(STATUS_OPPO_BATTLE) and bc:IsControler(1-tp) and bc:IsRelateToBattle()
end
-- 效果②的靶向与发动准备：确认对方怪兽是否可以除外，并设置除外操作信息
function c77102944.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if not bc then return false end
	if chk==0 then return bc:IsAbleToRemove() end
	-- 设置除外操作信息，目标为进行战斗的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
-- 效果②的处理：将进行战斗的对方怪兽除外
function c77102944.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if not bc then return end
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 以效果将进行战斗的对方怪兽表侧表示除外
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果③的发动条件：此卡不处于互相连接状态，且与对方怪兽进行战斗的伤害计算后
function c77102944.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not bc then return false end
	e:SetLabelObject(bc)
	return c:GetMutualLinkedGroupCount()==0 and c:IsStatus(STATUS_OPPO_BATTLE) and bc:IsControler(1-tp) and bc:IsRelateToBattle()
end
-- 效果③的靶向与发动准备：设置破坏对方怪兽及给予对方其原本攻击力数值伤害的操作信息
function c77102944.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if not bc then return false end
	if chk==0 then return true end
	local dam=bc:GetTextAttack()
	if dam<0 then dam=0 end
	-- 设置破坏操作信息，目标为进行战斗的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	-- 设置伤害操作信息，数值为该怪兽的原本攻击力，对象为对方玩家
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果③的处理：破坏进行战斗的对方怪兽，并给予对方其原本攻击力数值的伤害
function c77102944.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if not bc then return end
	-- 确认对方怪兽仍处于战斗关联且由对方控制，并成功将其破坏
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) and Duel.Destroy(bc,REASON_EFFECT)~=0 then
		local dam=bc:GetTextAttack()
		if dam<0 then dam=0 end
		-- 给予对方玩家等同于被破坏怪兽原本攻击力数值的效果伤害
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
