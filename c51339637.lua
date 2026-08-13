--サラマングレイト・ロアー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「转生炎兽」连接怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：这张卡在墓地存在的状态，和自身同名的怪兽作为素材让「转生炎兽」连接怪兽在自己场上连接召唤的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c51339637.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：自己场上有「转生炎兽」连接怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
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
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡在墓地存在的状态，和自身同名的怪兽作为素材让「转生炎兽」连接怪兽在自己场上连接召唤的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
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
		-- 和自身同名的怪兽作为素材让「转生炎兽」连接怪兽在自己场上连接召唤的场合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c51339637.valcheck)
		-- 将全局素材检查效果ge1注册到全场（player=0表示双方共用），使所有怪兽的召唤/特殊召唤都经过素材检查，用于判断②的发动条件是否满足。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 获取怪兽出场时使用的素材组，若素材中存在任意1张与该怪兽卡名相同的怪兽，则给该怪兽赋予标记51339637，该标记在怪兽离场等重置事件时清除，供②的发动条件判定使用。
function c51339637.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,c:GetCode()) then
		c:RegisterFlagEffect(51339637,RESET_EVENT+0x4fe0000,0,1)
	end
end
-- 筛选己方场上的表侧表示且字段为「转生炎兽」（0x119）的链接怪兽，作为①的发动条件“自己场上有「转生炎兽」连接怪兽存在”的判定。
function c51339637.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x119) and c:IsType(TYPE_LINK)
end
-- ①效果的发动条件判断：自己场上存在符合条件的「转生炎兽」连接怪兽；当前的连锁可在效果处理时被无效；且发动的是怪兽效果或魔法·陷阱卡的发动。
function c51339637.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足cfilter的表侧「转生炎兽」连接怪兽，不存在则①不能发动。
	if not Duel.IsExistingMatchingCard(c51339637.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 检查当前连锁的发动是否能够被无效，若不能无效则①不能发动。
	if not Duel.IsChainNegatable(ev) then return false end
	return re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- ①效果发动时的目标操作：无取对象效果，登记将无效当前发动的效果；若作为对象的发动卡可被破坏且仍与效果相关，则同时登记将其破坏。
function c51339637.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次效果处理将无效当前连锁的发动（CATEGORY_NEGATE），涉及的卡为eg（当前发动的卡），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记操作信息：本次效果处理将破坏当前发动的卡（CATEGORY_DESTROY），涉及的卡为eg，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ①效果处理：无效当前发动的效果，若该发动卡仍与效果相关，则将其破坏。
function c51339637.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 发动无效成功，且被无效的卡仍与效果相关（未离场或未被重置），才继续执行破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因（REASON_EFFECT）将eg中的卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 筛选特殊召唤成功的怪兽：表侧表示、控制者为发动玩家、字段为「转生炎兽」、以连接召唤方式出场、且带有51339637标记（即素材中含有与自己同名的怪兽），用于②的发动条件。
function c51339637.setfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x119) and c:IsSummonType(SUMMON_TYPE_LINK) and c:GetFlagEffect(51339637)~=0
end
-- ②的发动条件判断：本次特殊召唤成功的事件组eg中，存在至少1只满足setfilter的「转生炎兽」连接怪兽。
function c51339637.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c51339637.setfilter,1,nil,tp)
end
-- ②发动时的目标操作：无取对象效果；先确认墓地中的这张卡可以盖放，然后登记将这张卡从墓地盖放到场上的操作信息。
function c51339637.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 登记操作信息：本次效果处理将把墓地里的这张卡从墓地盖放（CATEGORY_LEAVE_GRAVE），涉及卡为这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果相关，则将它盖放到自己场上；若盖放成功，则给它附加“从场上离开时除外”的离场代替效果。
function c51339637.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认墓地里的这张卡仍与当前效果相关，并尝试将其盖放（Duel.SSet返回非0表示盖放成功），成功后才附加除外效果。
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		-- 这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
