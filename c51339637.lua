--サラマングレイト・ロアー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「转生炎兽」连接怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：这张卡在墓地存在的状态，和自身同名的怪兽作为素材让「转生炎兽」连接怪兽在自己场上连接召唤的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c51339637.initial_effect(c)
	-- 效果原文内容：①：自己场上有「转生炎兽」连接怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51339637,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,51339637)
	e1:SetCondition(c51339637.condition)
	e1:SetTarget(c51339637.target)
	e1:SetOperation(c51339637.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡在墓地存在的状态，和自身同名的怪兽作为素材让「转生炎兽」连接怪兽在自己场上连接召唤的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51339637,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,51339637)
	e2:SetCondition(c51339637.setcon)
	e2:SetTarget(c51339637.settg)
	e2:SetOperation(c51339637.setop)
	c:RegisterEffect(e2)
	if not c51339637.global_check then
		c51339637.global_check=true
		-- 注册一个全局的素材检查效果，用于标记连接召唤时是否使用了同名怪兽作为素材。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c51339637.valcheck)
		-- 将全局效果ge1注册到游戏环境，使所有玩家都能触发该效果。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有怪兽作为素材被送去墓地时，检查其是否包含与自身同名的连接怪兽，若是则为该怪兽标记一个flag。
function c51339637.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,c:GetCode()) then
		c:RegisterFlagEffect(51339637,RESET_EVENT+0x4fe0000,0,1)
	end
end
-- 过滤函数：用于判断场上是否存在满足条件的「转生炎兽」连接怪兽（表侧表示、属于转生炎兽卡组、类型为连接）。
function c51339637.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x119) and c:IsType(TYPE_LINK)
end
-- 效果发动条件函数：检查自己场上有「转生炎兽」连接怪兽存在，且当前连锁的发动可以被无效。
function c51339637.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只「转生炎兽」连接怪兽。
	if not Duel.IsExistingMatchingCard(c51339637.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 检查当前连锁是否可以被无效。
	if not Duel.IsChainNegatable(ev) then return false end
	return re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 设置效果处理时的操作信息：将要使发动无效，并可能破坏目标卡。
function c51339637.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果发动的卡可以被破坏，则设置操作信息为破坏该卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数：使连锁发动无效，并在满足条件下破坏对应卡。
function c51339637.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁发动无效且目标卡仍然存在。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡，原因设为效果。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤函数：用于判断是否有自己控制的「转生炎兽」连接召唤怪兽，并且该怪兽使用了同名怪兽作为素材。
function c51339637.setfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x119) and c:IsSummonType(SUMMON_TYPE_LINK) and c:GetFlagEffect(51339637)~=0
end
-- 盖放效果发动条件函数：检查是否有满足条件的怪兽被特殊召唤成功，即其为「转生炎兽」连接怪兽且使用了同名怪兽作为素材。
function c51339637.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c51339637.setfilter,1,nil,tp)
end
-- 设置盖放效果的目标信息：确认该卡可以盖放。
function c51339637.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息为将该卡从墓地离开（即盖放）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 盖放效果处理函数：将该卡盖放到场上，并在离场时将其移除。
function c51339637.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否仍然存在于游戏中且成功盖放。
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		-- 为盖放的这张卡注册一个效果，使其在离开场上时被移除而不是送入墓地。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
