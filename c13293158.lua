--E-HERO ワイルド・サイクロン
-- 效果：
-- 「元素英雄 荒野侠」＋「元素英雄 羽翼侠」
-- 这张卡用「暗黑融合」的效果才能特殊召唤。
-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：这张卡给与对方战斗伤害的场合发动。对方场上盖放的魔法·陷阱卡全部破坏。
function c13293158.initial_effect(c)
	-- 将「暗黑融合」（卡号94820406）追加记录到这张卡的卡名列表中，表示这张卡上记载着「暗黑融合」之名，以供相关效果检测。
	aux.AddCodeList(c,94820406)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，融合素材为「元素英雄 荒野侠」（21844576）与「元素英雄 羽翼侠」（86188410）；sub和insf为true表示允许使用融合素材代用品，并可由「暗黑融合」等融合效果进行融合召唤。
	aux.AddFusionProcCode2(c,21844576,86188410,true,true)
	-- 这张卡用「暗黑融合」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将上述特殊召唤条件的判定函数设为DarkFusionLimit，即只有通过「暗黑融合」的效果、暗黑融合特召类型或特定效果允许时才能特殊召唤这张卡。
	e1:SetValue(aux.DarkFusionLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c13293158.aclimit)
	e2:SetCondition(c13293158.actcon)
	c:RegisterEffect(e2)
	-- ②：这张卡给与对方战斗伤害的场合发动。对方场上盖放的魔法·陷阱卡全部破坏。
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
-- 价值判定函数：若对方发动的效果属于魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），则被禁止。
function c13293158.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果条件：只有这张卡作为攻击怪兽进行攻击时，该封锁效果才适用。
function c13293158.actcon(e)
	-- 判断当前攻击的怪兽是否就是这张卡（即这张卡在攻击）。
	return Duel.GetAttacker()==e:GetHandler()
end
-- 诱发条件：受到战斗伤害的玩家（ep）不是这张卡的控制者（tp），即这张卡给对方造成了战斗伤害。
function c13293158.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤函数：选择对方场上里侧表示（盖放）的魔法·陷阱卡。
function c13293158.filter(c)
	return c:IsFacedown()
end
-- 效果发动时的确认与信息设置：确认可以发动后，检索对方场上全部里侧魔陷，并将破坏这些卡的信息写入连锁。
function c13293158.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有里侧表示的魔法·陷阱卡，作为本次效果处理时可能破坏的集合（不取对象）。
	local g=Duel.GetMatchingGroup(c13293158.filter,tp,0,LOCATION_SZONE,nil)
	-- 设置操作信息，声明本次效果将破坏对象g中的所有卡，数量为g:GetCount()，供「星尘龙」等效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果结算函数：处理时再次检索对方场上里侧表示的魔法·陷阱卡，全部以效果破坏。
function c13293158.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上全部里侧表示的魔法·陷阱卡（与第13行相同，用于处理时再取一次）。
	local g=Duel.GetMatchingGroup(c13293158.filter,tp,0,LOCATION_SZONE,nil)
	-- 以效果原因（REASON_EFFECT）破坏g中的所有卡（即对方场上全部盖放的魔法·陷阱卡）。
	Duel.Destroy(g,REASON_EFFECT)
end
