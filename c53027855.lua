--風霊神ウィンドローズ
-- 效果：
-- 这张卡不能通常召唤。自己墓地的风属性怪兽是5只的场合才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合发动。对方场上的魔法·陷阱卡全部破坏。
-- ②：表侧表示的这张卡从场上离开的场合，下次的自己回合的战斗阶段跳过。
function c53027855.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己墓地的风属性怪兽是5只的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c53027855.spcon)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤成功的场合发动。对方场上的魔法·陷阱卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53027855,0))  --"魔陷破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,53027855)
	e3:SetTarget(c53027855.destg)
	e3:SetOperation(c53027855.desop)
	c:RegisterEffect(e3)
	-- ②：表侧表示的这张卡从场上离开的场合，下次的自己回合的战斗阶段跳过。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(c53027855.leaveop)
	c:RegisterEffect(e4)
end
-- 检查特殊召唤条件：确保场上存在空位且己方墓地风属性怪兽数量为5只。
function c53027855.spcon(e,c)
	if c==nil then return true end
	-- 检查己方场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查己方墓地风属性怪兽数量是否等于5。
		Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_WIND)==5
end
-- 定义用于筛选魔法·陷阱卡的过滤函数。
function c53027855.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果处理时的目标：对方场上的所有魔法·陷阱卡。
function c53027855.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的所有魔法·陷阱卡组成的组。
	local g=Duel.GetMatchingGroup(c53027855.desfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，指定将要破坏的卡组和数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果：将目标魔法·陷阱卡全部破坏。
function c53027855.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有魔法·陷阱卡组成的组。
	local g=Duel.GetMatchingGroup(c53027855.desfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 执行破坏效果：将目标魔法·陷阱卡全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 处理卡片离场时的效果：设置跳过下次自己回合战斗阶段的条件。
function c53027855.leaveop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() then return end
	local effp=e:GetHandler():GetControler()
	-- 创建并注册一个影响己方玩家的跳过战斗阶段效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 判断当前回合玩家是否为该卡的控制者。
	if Duel.GetTurnPlayer()==effp then
		-- 记录当前回合数作为标签，用于后续判断是否跳过战斗阶段。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c53027855.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	-- 将创建的效果注册到对应玩家的全局环境中。
	Duel.RegisterEffect(e1,effp)
end
-- 定义跳过战斗阶段效果的触发条件：当前回合数不等于记录的标签值。
function c53027855.skipcon(e)
	-- 当当前回合数与记录标签不一致时，触发跳过战斗阶段效果。
	return Duel.GetTurnCount()~=e:GetLabel()
end
