--氷霊神ムーラングレイス
-- 效果：
-- 这张卡不能通常召唤。自己墓地的水属性怪兽是5只的场合才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合发动。对方手卡随机2张丢弃。
-- ②：表侧表示的这张卡从场上离开时适用。下次的自己回合的战斗阶段跳过。
function c13959634.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
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
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡特殊召唤的场合发动。对方手卡随机2张丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13959634,0))  --"手牌丢弃"
	e3:SetCategory(CATEGORY_HANDES_OPPO)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,13959634)
	e3:SetTarget(c13959634.hdtg)
	e3:SetOperation(c13959634.hdop)
	c:RegisterEffect(e3)
	-- ②：表侧表示的这张卡从场上离开时适用。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(c13959634.leaveop)
	c:RegisterEffect(e4)
end
-- 自身特殊召唤条件的判定
function c13959634.spcon(e,c)
	if c==nil then return true end
	-- 判断己方场上是否有可用的怪兽区域空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 判断自己墓地的水属性怪兽数量是否为5
		Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_WATER)==5
end
-- 丢弃对方手卡效果的发动检测与效果分类信息设置
function c13959634.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置对方随机丢弃2张手牌的效果分类与操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,2)
end
-- 丢弃对方手卡效果的实际处理
function c13959634.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 随机选择对方的2张手牌
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,2)
	-- 将选中的手牌因效果丢弃送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
end
-- 表侧表示离场时跳过战斗阶段效果的实际处理
function c13959634.leaveop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() then return end
	local effp=e:GetHandler():GetControler()
	-- 下次的自己回合的战斗阶段跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 判断当前是否为自己回合
	if Duel.GetTurnPlayer()==effp then
		-- 记录当前的回合数
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c13959634.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	-- 给玩家注册跳过战斗阶段的效果
	Duel.RegisterEffect(e1,effp)
end
-- 跳过战斗阶段效果的条件判定
function c13959634.skipcon(e)
	-- 当前回合数不等于记录的回合数时生效（防止在离场当回合就跳过）
	return Duel.GetTurnCount()~=e:GetLabel()
end
