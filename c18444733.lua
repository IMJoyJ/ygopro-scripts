--雷龍放電
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己的雷族怪兽的效果的发动不会被无效化。
-- ②：1回合1次，自己场上有「雷龙」怪兽召唤·特殊召唤的场合，以场上1张魔法·陷阱卡为对象才能发动。从卡组把1只雷族怪兽除外，作为对象的卡破坏。
function c18444733.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：只要这张卡在魔法与陷阱区域存在，自己的雷族怪兽的效果的发动不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(c18444733.efilter)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：1回合1次，自己场上有「雷龙」怪兽召唤·特殊召唤的场合，以场上1张魔法·陷阱卡为对象才能发动。从卡组把1只雷族怪兽除外，作为对象的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18444733,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(c18444733.descon)
	e3:SetTarget(c18444733.destg)
	e3:SetOperation(c18444733.desop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 规则层面作用：该函数用于判断连锁效果是否为雷族怪兽发动的效果，若是则该效果不会被无效。
function c18444733.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	-- 规则层面作用：获取当前正在处理的连锁效果及其发动玩家。
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsActiveType(TYPE_MONSTER) and te:GetHandler():IsRace(RACE_THUNDER)
end
-- 规则层面作用：过滤函数，用于判断一张卡是否为己方的雷族怪兽。
function c18444733.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x11c) and c:IsControler(tp)
end
-- 规则层面作用：判断是否有己方的雷族怪兽被召唤或特殊召唤成功。
function c18444733.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c18444733.cfilter,1,nil,tp)
end
-- 规则层面作用：过滤函数，用于判断卡组中是否存在可除外的雷族怪兽。
function c18444733.rmfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToRemove()
end
-- 规则层面作用：设置效果的发动条件和目标选择逻辑，检查场上是否存在魔法或陷阱卡作为目标，并确认卡组中是否存在雷族怪兽。
function c18444733.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	local xg=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then xg=e:GetHandler() end
	-- 规则层面作用：检查是否满足发动条件，即场上存在魔法或陷阱卡作为目标。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,xg,TYPE_SPELL+TYPE_TRAP)
		-- 规则层面作用：检查是否满足发动条件，即卡组中存在雷族怪兽。
		and Duel.IsExistingMatchingCard(c18444733.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面作用：提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面作用：选择场上的一张魔法或陷阱卡作为目标。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,xg,TYPE_SPELL+TYPE_TRAP)
	-- 规则层面作用：设置操作信息，表示将要破坏一张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 规则层面作用：设置操作信息，表示将要从卡组除外一只雷族怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：执行效果处理，选择雷族怪兽除外并破坏目标卡。
function c18444733.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	-- 规则层面作用：提示玩家选择要除外的雷族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 规则层面作用：从卡组中选择一只雷族怪兽除外。
	local g=Duel.SelectMatchingCard(tp,c18444733.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 规则层面作用：判断除外是否成功且目标卡仍然有效，若满足则进行破坏处理。
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_REMOVED) and tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
