--秘竜星－セフィラシウゴ
-- 效果：
-- ←7 【灵摆】 7→
-- ①：自己不是「龙星」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡灵摆召唤成功时或者自己的怪兽区域的这张卡被战斗·效果破坏时才能发动。从卡组把1张「龙星」魔法·陷阱卡或者「神数」魔法·陷阱卡加入手卡。
function c58990362.initial_effect(c)
	-- 初始化并添加灵摆怪兽的灵摆召唤和灵摆卡发动等基本属性。
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「龙星」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c58990362.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡灵摆召唤成功时或者自己的怪兽区域的这张卡被战斗·效果破坏时才能发动。从卡组把1张「龙星」魔法·陷阱卡或者「神数」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,58990362)
	e3:SetCondition(c58990362.condition1)
	e3:SetTarget(c58990362.target)
	e3:SetOperation(c58990362.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCondition(c58990362.condition2)
	c:RegisterEffect(e4)
end
-- 灵摆召唤限制的过滤函数，若召唤的不是「龙星」或「神数」怪兽，则不能进行灵摆召唤。
function c58990362.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x9e,0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 检查这张卡是否是通过灵摆召唤成功特殊召唤的。
function c58990362.condition1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 检查这张卡是否在自己的怪兽区域被战斗或效果破坏。
function c58990362.condition2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 过滤卡组中可以加入手牌的「龙星」或「神数」魔法·陷阱卡。
function c58990362.thfilter(c)
	return c:IsSetCard(0x9e,0xc4) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 检索效果的发动准备，检查卡组中是否存在可检索的卡，并设置检索的操作信息。
function c58990362.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「龙星」或「神数」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c58990362.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数，从卡组选择1张「龙星」或「神数」魔法·陷阱卡加入手牌并给对方确认。
function c58990362.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「龙星」或「神数」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c58990362.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
