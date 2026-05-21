--アクションマジック－フルターン
-- 效果：
-- ①：这个回合，怪兽之间的战斗发生的双方的战斗伤害变成2倍。
-- ②：这张卡在墓地存在的场合，自己主要阶段从手卡丢弃1张魔法卡才能发动。这张卡在自己的魔法与陷阱区域盖放。这个效果在这张卡送去墓地的回合不能发动。
function c99004583.initial_effect(c)
	-- ①：这个回合，怪兽之间的战斗发生的双方的战斗伤害变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置发动条件为：当前可以进行战斗相关操作（处于战斗阶段或可以进入战斗阶段）
	e1:SetCondition(aux.bpcon)
	e1:SetTarget(c99004583.target)
	e1:SetOperation(c99004583.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，自己主要阶段从手卡丢弃1张魔法卡才能发动。这张卡在自己的魔法与陷阱区域盖放。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99004583,0))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置发动条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	e2:SetCost(c99004583.setcost)
	e2:SetTarget(c99004583.settg)
	e2:SetOperation(c99004583.setop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动准备与合法性检测函数
function c99004583.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方玩家是否至少有一方在本回合尚未适用过该效果（防止重复发动导致伤害叠加）
	if chk==0 then return Duel.GetFlagEffect(tp,99004583)==0 or Duel.GetFlagEffect(1-tp,99004583)==0 end
end
-- ①号效果的发动处理函数，注册使战斗伤害翻倍的全局效果
function c99004583.activate(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这个回合，怪兽之间的战斗发生的双方的战斗伤害变成2倍。 / ②：这张卡在墓地存在的场合，自己主要阶段从手卡丢弃1张魔法卡才能发动。这张卡在自己的魔法与陷阱区域盖放。这个效果在这张卡送去墓地的回合不能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetCondition(c99004583.dcon)
	e1:SetValue(DOUBLE_DAMAGE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将伤害翻倍的全局效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 为发动玩家注册回合结束前有效的全局标识，用于防止重复发动
	Duel.RegisterFlagEffect(tp,99004583,RESET_PHASE+PHASE_END,0,1)
end
-- 伤害翻倍效果的适用条件函数
function c99004583.dcon(e)
	-- 检查是否存在攻击对象（即进行怪兽之间的战斗）
	return Duel.GetAttackTarget()
end
-- 过滤手卡中可丢弃的魔法卡
function c99004583.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- ②号效果的发动代价处理函数
function c99004583.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可丢弃的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c99004583.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡选择1张魔法卡作为代价丢弃到墓地
	Duel.DiscardHand(tp,c99004583.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- ②号效果的发动准备与合法性检测函数
function c99004583.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：将墓地的这张卡移出墓地（盖放）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②号效果的效果处理函数
function c99004583.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在自己的魔法与陷阱区域盖放
		Duel.SSet(tp,c)
	end
end
