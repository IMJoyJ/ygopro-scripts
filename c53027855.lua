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
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡特殊召唤成功的场合发动。对方场上的魔法·陷阱卡全部破坏。
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
-- 特殊召唤手续的规则判定：自己场上有主要怪兽区空位，且自己墓地恰好有5只风属性怪兽时，才允许此卡从手牌进行特殊召唤。
function c53027855.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否存在空余的主要怪兽区，保证特殊召唤后有可用的怪兽区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 统计自己墓地的风属性怪兽数量，要求恰好为5只。
		Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_WIND)==5
end
-- 用于筛选对方场上的魔法·陷阱卡。
function c53027855.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 特殊召唤成功的诱发效果的发动时点：登记效果信息，确认可发动；效果处理时破坏对方场上所有魔法·陷阱卡。
function c53027855.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得对方场上所有魔法·陷阱卡，作为本次破坏的候选对象。
	local g=Duel.GetMatchingGroup(c53027855.desfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 将破坏效果及对象信息写入连锁，便于其他卡对此进行响应或判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理阶段：重新取得对方场上的魔法·陷阱卡，将其全部破坏。
function c53027855.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次获取对方场上现有的所有魔法·陷阱卡，防止只破坏发动时存在的卡。
	local g=Duel.GetMatchingGroup(c53027855.desfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果破坏的原因将获取到的卡全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 这张卡表侧表示从场上离开时，给其控制者附加跳过一次战斗阶段的效果；根据离开时是否为该控制者的回合来决定跳过的时机。
function c53027855.leaveop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() then return end
	local effp=e:GetHandler():GetControler()
	-- ②：表侧表示的这张卡从场上离开的场合，下次的自己回合的战斗阶段跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 判断当前回合是否正是这张卡的控制者的回合，以决定跳过效果的生效时机（是否跨回合）。
	if Duel.GetTurnPlayer()==effp then
		-- 记录离开时的回合数，用于在下一次自己的回合中判断是否应该跳过战斗阶段。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c53027855.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	-- 将跳过战斗阶段的效果注册给该玩家，使其受到‘跳过战斗阶段’的影响。
	Duel.RegisterEffect(e1,effp)
end
-- 跳过战斗阶段效果的生效条件：当前回合数不等于离开时记录的回合数，即从离开时的下一个自己的回合开始生效。
function c53027855.skipcon(e)
	-- 返回真/假：当前回合数已经与离开时不同，满足跳过战斗阶段的条件。
	return Duel.GetTurnCount()~=e:GetLabel()
end
