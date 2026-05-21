--六花の風花
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上的「六花」怪兽被解放的场合才能发动。对方必须把自身场上1只怪兽解放。
-- ②：对方结束阶段，植物族怪兽以外的表侧表示怪兽在自己场上存在的场合发动。这张卡破坏。
function c96162588.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己场上的「六花」怪兽被解放的场合才能发动。对方必须把自身场上1只怪兽解放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96162588,0))  --"对方必须把自身场上1只怪兽解放"
	e1:SetCategory(CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_RELEASE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,96162588)
	e1:SetCondition(c96162588.rlcon)
	e1:SetTarget(c96162588.rltg)
	e1:SetOperation(c96162588.rlop)
	c:RegisterEffect(e1)
	-- ②：对方结束阶段，植物族怪兽以外的表侧表示怪兽在自己场上存在的场合发动。这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96162588,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c96162588.descon)
	e2:SetTarget(c96162588.destg)
	e2:SetOperation(c96162588.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：原本控制者为自己、原本在怪兽区域且原本是「六花」怪兽
function c96162588.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousSetCard(0x141)
end
-- 发动条件：被解放的卡中存在满足过滤条件的怪兽，且此卡已在场上表侧表示存在
function c96162588.rlcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c96162588.cfilter,1,nil,tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 效果发动时的目标选择与检查：检查对方场上是否有可解放的怪兽，并设置解放的操作信息
function c96162588.rltg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查对方场上是否存在至少1只可因规则解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroupEx(1-tp,nil,1,REASON_RULE,false,nil) end
	-- 设置操作信息：在对方怪兽区域有1张卡要被解放
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,1-tp,LOCATION_MZONE)
end
-- 效果处理：对方选择自身场上1只怪兽并因规则解放
function c96162588.rlop(e,tp,eg,ep,ev,re,r,rp)
	-- 让对方玩家从自身场上选择1只可因规则解放的怪兽
	local g=Duel.SelectReleaseGroupEx(1-tp,nil,1,1,REASON_RULE,false,nil)
	if g:GetCount()>0 then
		-- 为选中的怪兽显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 将选中的怪兽以规则原因解放
		Duel.Release(g,REASON_RULE,1-tp)
	end
end
-- 过滤条件：表侧表示且不是植物族的怪兽
function c96162588.desfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_PLANT)
end
-- 发动条件：当前是对方的结束阶段，且自己场上存在满足过滤条件的怪兽
function c96162588.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	-- 返回是否为对方回合且自己场上存在植物族以外的表侧表示怪兽
	return Duel.GetTurnPlayer()==1-tp and g:IsExists(c96162588.desfilter,1,nil)
end
-- 效果发动时的目标选择与检查：此效果为必发效果，直接返回true，并设置破坏自身的操作信息
function c96162588.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：破坏此卡自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡仍在场上，则将其破坏
function c96162588.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果破坏此卡
		Duel.Destroy(c,REASON_EFFECT)
	end
end
