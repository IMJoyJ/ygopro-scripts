--E-HERO ワイルド・サイクロン
-- 效果：
-- 「元素英雄 荒野侠」＋「元素英雄 羽翼侠」
-- 这张卡用「暗黑融合」的效果才能特殊召唤。
-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：这张卡给与对方战斗伤害的场合发动。对方场上盖放的魔法·陷阱卡全部破坏。
function c13293158.initial_effect(c)
	-- 为卡片注册「暗黑融合」的卡片代码，用于后续效果判断
	aux.AddCodeList(c,94820406)
	c:EnableReviveLimit()
	-- 设置融合召唤所需的两张融合素材卡片代码，分别为「元素英雄 荒野侠」和「元素英雄 羽翼侠」
	aux.AddFusionProcCode2(c,21844576,86188410,true,true)
	-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为必须通过「暗黑融合」或「暗黑神召」的效果进行特殊召唤
	e1:SetValue(aux.DarkFusionLimit)
	c:RegisterEffect(e1)
	-- ②：这张卡给与对方战斗伤害的场合发动。对方场上盖放的魔法·陷阱卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c13293158.aclimit)
	e2:SetCondition(c13293158.actcon)
	c:RegisterEffect(e2)
	-- 当此卡造成战斗伤害时，对方场上盖放的魔法·陷阱卡全部破坏
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13293158,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(c13293158.condition)
	e3:SetTarget(c13293158.target)
	e3:SetOperation(c13293158.activate)
	c:RegisterEffect(e3)
end
c13293158.material_setcode=0x8
c13293158.dark_calling=true
-- 判断发动效果的卡是否为魔法·陷阱卡
function c13293158.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断当前是否为该卡攻击状态
function c13293158.actcon(e)
	-- 判断当前攻击怪兽是否为该卡
	return Duel.GetAttacker()==e:GetHandler()
end
-- 判断是否为对方受到战斗伤害
function c13293158.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤对方场上盖放的魔法·陷阱卡
function c13293158.filter(c)
	return c:IsFacedown()
end
-- 设置效果发动时的目标选择函数
function c13293158.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上盖放的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c13293158.filter,tp,0,LOCATION_SZONE,nil)
	-- 设置连锁操作信息，指定将要破坏的卡组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 设置效果发动时的处理函数
function c13293158.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上盖放的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c13293158.filter,tp,0,LOCATION_SZONE,nil)
	-- 将对方场上盖放的魔法·陷阱卡全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
