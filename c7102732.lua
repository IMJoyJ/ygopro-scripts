--クリアー・レイジ・ゴーレム
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。这个回合中，有「清透世界」的卡名记述的自己怪兽可以直接攻击。
-- ②：只要这张卡在怪兽区域存在，「清透世界」的效果对自己不适用。
-- ③：这张卡给与对方战斗伤害时才能发动。给与对方为对方手卡数量×300伤害。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①召唤·特殊召唤成功时发动使特定怪兽可以直接攻击的效果、②在怪兽区域存在时「清透世界」效果不适用的效果、③给与对方战斗伤害时发动给与伤害的效果
function s.initial_effect(c)
	-- 注册该卡片记述了卡名「清透世界」
	aux.AddCodeList(c,33900648)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。这个回合中，有「清透世界」的卡名记述的自己怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，「清透世界」的效果对自己不适用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetCode(97811903)
	c:RegisterEffect(e3)
	-- ③：这张卡给与对方战斗伤害时才能发动。给与对方为对方手卡数量×300伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(s.damcon)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
-- ①效果的发动条件：当前回合玩家能够进入战斗阶段
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能够进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- ①效果的处理：在全局注册一个持续到回合结束的效果，使自己场上记述有「清透世界」的怪兽可以直接攻击
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。这个回合中，有「清透世界」的卡名记述的自己怪兽可以直接攻击。③：这张卡给与对方战斗伤害时才能发动。给与对方为对方手卡数量×300伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将可以直接攻击的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- ①效果的适用对象过滤：必须是卡名记述有「清透世界」的怪兽
function s.atktg(e,c)
	-- 检查怪兽的效果文本中是否记述了「清透世界」的卡名
	return aux.IsCodeListed(c,33900648)
end
-- ③效果的发动条件：给与对方玩家战斗伤害时
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- ③效果的发动准备：确认对方手卡数量大于0，设置对象玩家为对方，并设置伤害操作信息
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 end
	-- 设置对方玩家为效果处理的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的操作信息为：给与对方玩家其手卡数量×300的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)*300)
end
-- ③效果的处理：获取目标玩家，并给与该玩家其手卡数量×300的效果伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被设为对象的玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 给与目标玩家其手卡数量×300的效果伤害
	Duel.Damage(p,Duel.GetFieldGroupCount(p,LOCATION_HAND,0)*300,REASON_EFFECT)
end
