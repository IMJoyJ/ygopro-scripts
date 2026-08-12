--導かれし烙印
-- 效果：
-- ①：1回合1次，只以自己场上的「深渊之兽」怪兽1只为对象的卡的效果由对方发动时或者对方连锁自己的「深渊之兽」怪兽的效果的发动把卡的效果发动时，以自己或者对方的墓地1只光·暗属性怪兽为对象才能发动。那只怪兽除外，那个发动的效果无效。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含魔法卡的发动以及在魔陷区发动的诱发即时效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：1回合1次，只以自己场上的「深渊之兽」怪兽1只为对象的卡的效果由对方发动时或者对方连锁自己的「深渊之兽」怪兽的效果的发动把卡的效果发动时，以自己或者对方的墓地1只光·暗属性怪兽为对象才能发动。那只怪兽除外，那个发动的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足“自己场上表侧表示的「深渊之兽」怪兽”条件的卡片。
function s.tfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
		and c:IsSetCard(0x188) and c:IsControler(tp)
end
-- 检查发动条件：对方发动的效果是否满足“只以自己场上1只「深渊之兽」怪兽为对象”或“对方连锁自己「深渊之兽」怪兽的效果发动”。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁的效果是否可以被无效，若不能则无法发动。
	if not Duel.IsChainDisablable(ev) then return false end
	-- 获取当前的连锁数。
	local ct=Duel.GetCurrentChain()
	-- 获取对方发动效果的对象卡片组。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 获取前一个连锁（即被对方连锁的连锁）的效果和发动玩家。
	local te,p=Duel.GetChainInfo(ct-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	local b1=re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and tg and tg:IsExists(s.tfilter,1,nil,tp) and #tg==1
	local b2=ct>=2 and te and te:GetHandler():IsSetCard(0x188) and p==tp
	return rp==1-tp and (b1 or b2)
end
-- 过滤满足“自己或对方墓地的光·暗属性且可以除外”条件的怪兽。
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToRemove()
end
-- 效果发动的靶向处理，包括合法对象检查、提示玩家选择墓地的光·暗属性怪兽作为对象，并设置除外和无效的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.cfilter(chkc) end
	-- 检查自己或对方的墓地是否存在至少1只可以作为对象的光·暗属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 在客户端提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择双方墓地中1只满足条件的光·暗属性怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置除外操作的信息，表示将除外选中的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置无效操作的信息，表示将无效对方发动的效果。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果处理的核心逻辑：将作为对象的墓地怪兽除外，若除外成功，则使对方发动的效果无效。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的墓地怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e)
		-- 将该怪兽以表侧表示除外，并确认是否成功除外。
		and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		-- 使对方发动的效果无效。
		Duel.NegateEffect(ev)
	end
end
