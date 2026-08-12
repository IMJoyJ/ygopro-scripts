--光霊神フォスオラージュ
-- 效果：
-- 这张卡不能通常召唤。自己墓地的光属性怪兽是5只的场合才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功时才能发动。对方场上的怪兽全部破坏。
-- ②：表侧表示的这张卡从场上离开的场合，下次的自己回合的战斗阶段跳过。
function c8192327.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己墓地的光属性怪兽是5只的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c8192327.spcon)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤成功时才能发动。对方场上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(8192327,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,8192327)
	e3:SetTarget(c8192327.destg)
	e3:SetOperation(c8192327.desop)
	c:RegisterEffect(e3)
	-- ②：表侧表示的这张卡从场上离开的场合，下次的自己回合的战斗阶段跳过。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(c8192327.leaveop)
	c:RegisterEffect(e4)
end
-- 特殊召唤规则的条件函数：检查怪兽区域空位以及墓地光属性怪兽数量是否刚好为5只
function c8192327.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己墓地的光属性怪兽数量是否刚好为5只
		Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT)==5
end
-- 效果①的发动准备与目标确认函数
function c8192327.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查对方场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁的操作信息，表示该效果将破坏对方场上的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的处理函数：破坏对方场上的所有怪兽
function c8192327.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 因效果破坏获取到的怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
-- 效果②的处理函数：在表侧表示的这张卡离场时，注册跳过下次自己回合战斗阶段的效果
function c8192327.leaveop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() then return end
	local effp=e:GetHandler():GetControler()
	-- 下次的自己回合的战斗阶段跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 判断当前回合玩家是否为自己
	if Duel.GetTurnPlayer()==effp then
		-- 将当前回合数记录在效果的Label中，用于后续判断是否为“下次”的自己回合
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c8192327.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	-- 将跳过战斗阶段的效果注册给玩家
	Duel.RegisterEffect(e1,effp)
end
-- 跳过战斗阶段效果的条件函数：确保不在离场的当前回合生效
function c8192327.skipcon(e)
	-- 判断当前回合数不等于离场时的回合数，即必须是之后的自己回合
	return Duel.GetTurnCount()~=e:GetLabel()
end
