--ナーゲルの守護天
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己的主要怪兽区域的「廷达魔三角」怪兽不会被战斗以及对方的效果破坏。
-- ②：自己的「廷达魔三角」怪兽给与对方战斗伤害的场合，1回合只有1次让那次伤害变成2倍。
-- ③：把墓地的这张卡除外，从手卡丢弃1张「廷达魔三角」卡才能发动。从卡组把1张「奈格尔守护天」加入手卡。
function c63053267.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己的主要怪兽区域的「廷达魔三角」怪兽不会被战斗以及对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c63053267.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不会被对方的效果破坏
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ②：自己的「廷达魔三角」怪兽给与对方战斗伤害的场合，1回合只有1次让那次伤害变成2倍。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(c63053267.damcon)
	-- 设置效果影响的目标为「廷达魔三角」怪兽
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x10b))
	-- 设置将给与对方的战斗伤害变成2倍
	e4:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e4)
	-- ③：把墓地的这张卡除外，从手卡丢弃1张「廷达魔三角」卡才能发动。从卡组把1张「奈格尔守护天」加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,63053267)
	e5:SetCost(c63053267.thcost)
	e5:SetTarget(c63053267.thtg)
	e5:SetOperation(c63053267.thop)
	c:RegisterEffect(e5)
	-- ②：自己的「廷达魔三角」怪兽给与对方战斗伤害的场合，1回合只有1次让那次伤害变成2倍。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c63053267.regcon)
	e6:SetOperation(c63053267.regop)
	c:RegisterEffect(e6)
end
-- 过滤属于「廷达魔三角」且在主要怪兽区域（格子编号小于5）的怪兽
function c63053267.indtg(e,c)
	return c:IsSetCard(0x10b) and c:GetSequence()<5
end
-- 检查是否是自己的「廷达魔三角」怪兽给与对方战斗伤害
function c63053267.regcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and eg:GetFirst():IsSetCard(0x10b)
end
-- 给这张卡注册一个在本回合结束前有效的标记，用于记录本回合已触发过伤害加倍效果
function c63053267.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(63053267,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查本回合是否尚未触发过伤害加倍效果（即没有对应的标记）
function c63053267.damcon(e)
	return e:GetHandler():GetFlagEffect(63053267)==0
end
-- 过滤手卡中可以丢弃的「廷达魔三角」卡片
function c63053267.cfilter(c)
	return c:IsSetCard(0x10b) and c:IsDiscardable()
end
-- 墓地检索效果的发动代价（Cost）判定与执行函数
function c63053267.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查手卡中是否存在至少1张可以丢弃的「廷达魔三角」卡
		and Duel.IsExistingMatchingCard(c63053267.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 将墓地的这张卡表侧表示除外作为发动代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 从手卡丢弃1张「廷达魔三角」卡作为发动代价
	Duel.DiscardHand(tp,c63053267.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中可以加入手卡的「奈格尔守护天」
function c63053267.filter(c)
	return c:IsCode(63053267) and c:IsAbleToHand()
end
-- 墓地检索效果的发动条件判定与操作信息注册函数
function c63053267.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「奈格尔守护天」
	if chk==0 then return Duel.IsExistingMatchingCard(c63053267.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示该效果会将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 墓地检索效果的效果处理（将卡组的「奈格尔守护天」加入手卡并给对方确认）
function c63053267.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中第1张满足条件的「奈格尔守护天」
	local tc=Duel.GetFirstMatchingCard(c63053267.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将目标卡片加入玩家手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
