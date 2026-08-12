--E・HERO シャイニング・ネオス・ウィングマン
-- 效果：
-- 「元素英雄 新宇侠」＋「翼侠」融合怪兽
-- 这张卡不用融合召唤不能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。把最多有场上的怪兽的属性种类数量的对方场上的卡破坏。
-- ②：场上的这张卡攻击力上升自己墓地的怪兽数量×300，不会被效果破坏。
-- ③：这张卡战斗破坏怪兽的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
local s,id,o=GetID()
-- 注册卡片的初始化效果（融合召唤手续、召唤限制、特殊召唤时破坏对方卡片、攻击力上升、效果破坏抗性、战斗破坏怪兽时追加伤害）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合召唤素材：「元素英雄 新宇侠」（卡号89943723）＋ 1只满足s.mfilter过滤条件的怪兽（「翼侠」融合怪兽）
	aux.AddFusionProcCodeFun(c,89943723,s.mfilter,1,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为仅能通过融合召唤进行特殊召唤
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ①：这张卡特殊召唤的场合才能发动。把最多有场上的怪兽的属性种类数量的对方场上的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡攻击力上升自己墓地的怪兽数量×300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- 不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：这张卡战斗破坏怪兽的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置发动条件为自身在场且战斗破坏了怪兽
	e4:SetCondition(aux.bdcon)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
s.material_setcode=0x8
-- 融合素材过滤条件：属于「翼侠」系列（0x184）的融合怪兽
function s.mfilter(c)
	return c:IsFusionSetCard(0x184) and c:IsFusionType(TYPE_FUSION)
end
-- 过滤条件：场上表侧表示的怪兽（用于统计属性种类）
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 效果①（破坏对方卡片）的发动准备与可行性检查
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 并且对方场上存在至少1张卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁处理信息：预计破坏对方场上的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①（破坏对方卡片）的效果处理（计算属性种类并选择破坏）
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有表侧表示的怪兽
	local cg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 计算这些怪兽所拥有的不同属性种类的数量
	local ct=aux.GetAttributeCount(cg)
	if ct==0 then return end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择最多等同于属性种类数量（1到ct张）的对方场上的卡片
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	if g:GetCount()>0 then
		-- 显式示出被选择的卡片
		Duel.HintSelection(g)
		-- 破坏所选择的卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 效果②（攻击力上升）的数值计算函数
function s.atkval(e,c)
	-- 返回自己墓地的怪兽数量乘以300的数值
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)*300
end
-- 效果③（战斗破坏伤害）的发动准备与参数设定
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetBattleTarget():GetBaseAttack()
	if dam<0 then dam=0 end
	-- 设置伤害的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值为被破坏怪兽的原本攻击力
	Duel.SetTargetParam(dam)
	-- 设置连锁处理信息：给与对方原本攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果③（战斗破坏伤害）的效果处理
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取设定的伤害对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与对方玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
