--ライト・オブ・デストラクション
-- 效果：
-- 对方的效果从对方卡组让卡送去墓地时，从对方卡组上面把3张卡送去墓地。
function c83027236.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方的效果从对方卡组让卡送去墓地时，从对方卡组上面把3张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83027236,0))  --"卡组送墓"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c83027236.condtion)
	e2:SetTarget(c83027236.target)
	e2:SetOperation(c83027236.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查卡片原本的位置是否为卡组，且原本的持有者是否为对方
function c83027236.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp)
end
-- 判断触发条件：必须是由对方的效果引起，且送去墓地的卡中存在原本属于对方卡组的卡
function c83027236.condtion(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rp==1-tp and bit.band(r,REASON_EFFECT)~=0 and eg:IsExists(c83027236.cfilter,1,nil,1-tp)
end
-- 设置效果的目标：此效果为必发效果，并设置将对方卡组送去墓地的操作信息
function c83027236.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：包含卡组送墓分类，预计将对方卡组的3张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,3)
end
-- 执行效果处理：将对方卡组最上方的3张卡送去墓地
function c83027236.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方卡组最上方的3张卡因效果原因送去墓地
	Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
end
