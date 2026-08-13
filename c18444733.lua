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
	-- ①：只要这张卡在魔法与陷阱区域存在，自己的雷族怪兽的效果的发动不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(c18444733.efilter)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己场上有「雷龙」怪兽召唤·特殊召唤的场合，以场上1张魔法·陷阱卡为对象才能发动。从卡组把1只雷族怪兽除外，作为对象的卡破坏。
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
-- 过滤函数：检查当前连锁的效果是否为玩家自己的雷族怪兽效果，若是则返回true，用于决定是否给予“发动不会被无效化”的适用。
function c18444733.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	-- 获取当前连锁的效果te及发动玩家tp，用于判断发动者是否为自己、效果是否来自雷族怪兽。
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsActiveType(TYPE_MONSTER) and te:GetHandler():IsRace(RACE_THUNDER)
end
-- 过滤函数：判断怪兽是否表侧表示、卡名属于「雷龙」字段、且控制者为tp。
function c18444733.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x11c) and c:IsControler(tp)
end
-- 触发条件：在召唤·特殊召唤成功时，若这些怪兽中存在满足cfilter的「雷龙」怪兽，则条件成立。
function c18444733.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c18444733.cfilter,1,nil,tp)
end
-- 过滤函数：判断卡组中的卡是否雷族怪兽且可以被除外。
function c18444733.rmfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToRemove()
end
-- 取对象及发动合法性检查：选择场上1张魔法·陷阱卡作为对象，同时确认卡组中有雷族怪兽可除外；若本卡效果尚未正常生效（如正在发动中），则将自身排除在可选对象外。
function c18444733.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	local xg=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then xg=e:GetHandler() end
	-- 检查场上是否存在1张除排除对象外的魔法·陷阱卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,xg,TYPE_SPELL+TYPE_TRAP)
		-- 检查卡组中是否存在1张雷族怪兽可以除外。
		and Duel.IsExistingMatchingCard(c18444733.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家提示“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡，将其设为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,xg,TYPE_SPELL+TYPE_TRAP)
	-- 设置操作信息：本次连锁将破坏1张卡（即选择的对象）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本次连锁将从卡组除外1张雷族怪兽（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：先选择卡组1张雷族怪兽除外，若除外成功且对象卡仍与效果关联，则破坏该对象卡。
function c18444733.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时连锁的对象卡（之前选择的魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	-- 向玩家提示“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组选择1张雷族怪兽，准备除外。
	local g=Duel.SelectMatchingCard(tp,c18444733.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判定除外是否成功、被除外的卡是否在除外区，以及对象卡是否仍与效果有联系；满足条件才执行破坏。
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_REMOVED) and tc:IsRelateToEffect(e) then
		-- 将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
