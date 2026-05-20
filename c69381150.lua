--Ai－Q
-- 效果：
-- 自己场上有「@火灵天星」怪兽存在的场合才能把这张卡发动。这张卡的控制者在每次自己准备阶段把自己场上1只连接怪兽解放。或者不解放让这张卡破坏。
-- ①：只要这张卡在魔法与陷阱区域存在，那个期间双方1回合只能有1次连接召唤。
function c69381150.initial_effect(c)
	-- 自己场上有「@火灵天星」怪兽存在的场合才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c69381150.condition)
	c:RegisterEffect(e1)
	-- 这张卡的控制者在每次自己准备阶段把自己场上1只连接怪兽解放。或者不解放让这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c69381150.descon)
	e2:SetOperation(c69381150.desop)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在魔法与陷阱区域存在，那个期间双方1回合只能有1次连接召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c69381150.regcon1)
	e3:SetOperation(c69381150.regop1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCondition(c69381150.regcon2)
	e4:SetOperation(c69381150.regop2)
	c:RegisterEffect(e4)
end
-- 过滤属于指定玩家且是通过连接召唤特殊召唤的怪兽
function c69381150.regfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:IsSummonPlayer(tp)
end
-- 检查当前特殊召唤的怪兽中是否存在自己连接召唤的怪兽
function c69381150.regcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c69381150.regfilter,1,nil,tp)
end
-- 在自己连接召唤成功时，注册一个限制自己本回合不能再进行连接召唤的效果
function c69381150.regop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 那个期间双方1回合只能有1次连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetTarget(c69381150.splimit)
	c:RegisterEffect(e1)
end
-- 检查当前特殊召唤的怪兽中是否存在对方连接召唤的怪兽
function c69381150.regcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c69381150.regfilter,1,nil,1-tp)
end
-- 在对方连接召唤成功时，注册一个限制对方本回合不能再进行连接召唤的效果
function c69381150.regop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 那个期间双方1回合只能有1次连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetTarget(c69381150.splimit)
	c:RegisterEffect(e1)
end
-- 限制特殊召唤的类型为连接召唤
function c69381150.splimit(e,c,tp,sumtp,sumpos)
	return bit.band(sumtp,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- 过滤自己场上表侧表示的「@火灵天星」怪兽
function c69381150.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x135)
end
-- 发动条件：自己场上有「@火灵天星」怪兽存在
function c69381150.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「@火灵天星」怪兽
	return Duel.IsExistingMatchingCard(c69381150.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 维持代价触发条件：当前回合是控制者的回合
function c69381150.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 维持代价处理：选择解放1只连接怪兽，或者将这张卡破坏
function c69381150.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选中这张卡并显示被选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 检查自己场上是否存在可解放的连接怪兽，并由玩家选择是否进行解放
	if Duel.CheckReleaseGroupEx(tp,Card.IsType,1,REASON_MAINTENANCE,false,nil,TYPE_LINK) and Duel.SelectYesNo(tp,aux.Stringid(69381150,0)) then  --"是否解放连接怪兽？"
		-- 玩家选择自己场上1只用于作为维持代价解放的连接怪兽
		local g=Duel.SelectReleaseGroupEx(tp,Card.IsType,1,1,REASON_MAINTENANCE,false,nil,TYPE_LINK)
		-- 将选中的连接怪兽作为维持代价解放
		Duel.Release(g,REASON_MAINTENANCE)
	-- 若不解放怪兽，则将这张卡破坏
	else Duel.Destroy(c,REASON_COST) end
end
