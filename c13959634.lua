--氷霊神ムーラングレイス
-- 效果：
-- 这张卡不能通常召唤。自己墓地的水属性怪兽是5只的场合才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合发动。对方手卡随机2张丢弃。
-- ②：表侧表示的这张卡从场上离开时适用。下次的自己回合的战斗阶段跳过。
function c13959634.initial_effect(c)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己墓地的水属性怪兽是5只的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c13959634.spcon)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤的场合发动。对方手卡随机2张丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13959634,0))  --"手牌丢弃"
	e3:SetCategory(CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,13959634)
	e3:SetTarget(c13959634.hdtg)
	e3:SetOperation(c13959634.hdop)
	c:RegisterEffect(e3)
	-- ②：表侧表示的这张卡从场上离开时适用。下次的自己回合的战斗阶段跳过。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(c13959634.leaveop)
	c:RegisterEffect(e4)
end
-- 检查特殊召唤条件是否满足，包括是否有足够的怪兽区域和墓地水属性怪兽数量是否为5。
function c13959634.spcon(e,c)
	if c==nil then return true end
	-- 检查当前玩家场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查当前玩家墓地中的水属性怪兽数量是否等于5。
		Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_WATER)==5
end
-- 设置丢弃手牌效果的目标和参数。
function c13959634.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，指定对方将随机丢弃2张手牌。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,2)
end
-- 执行丢弃手牌效果的操作。
function c13959634.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前玩家的手牌中随机选择2张牌。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,2)
	-- 将选中的2张牌送入墓地。
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
end
-- 处理卡片离开场上的效果。
function c13959634.leaveop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() then return end
	local effp=e:GetHandler():GetControler()
	-- 创建并注册一个跳过战斗阶段的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 判断当前回合玩家是否为该卡的控制者。
	if Duel.GetTurnPlayer()==effp then
		-- 记录当前回合数用于后续判断。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c13959634.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	-- 将跳过战斗阶段的效果注册到控制者玩家的场上。
	Duel.RegisterEffect(e1,effp)
end
-- 判断是否跳过战斗阶段的条件函数。
function c13959634.skipcon(e)
	-- 当回合数不等于记录的回合数时，跳过战斗阶段。
	return Duel.GetTurnCount()~=e:GetLabel()
end
