--マグナム・ザ・リリーバー
-- 效果：
-- 从额外卡组特殊召唤的怪兽＋手卡的怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1张「融合」魔法卡为对象才能发动。那张卡回到卡组最下面。那之后，自己抽1张。
-- ②：其他卡的效果发动时，从自己墓地把1张「融合」魔法卡除外，以场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化函数：为该卡添加融合召唤限制与融合召唤手续（额外卡组特殊召唤的怪兽＋手卡的怪兽），并注册①效果（回收融合魔法并抽卡）和②效果（除外融合魔法并破坏场上1张卡）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加融合召唤手续：以“从额外卡组特殊召唤的怪兽”1只和“手卡的怪兽”1只为融合素材。
	aux.AddFusionProcFun2(c,s.matfilter,aux.FilterBoolFunction(Card.IsLocation,LOCATION_HAND),true)
	-- ①：以自己墓地1张「融合」魔法卡为对象才能发动。那张卡回到卡组最下面。那之后，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收并抽卡"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	-- ②：其他卡的效果发动时，从自己墓地把1张「融合」魔法卡除外，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外并破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤函数：素材必须是从额外卡组特殊召唤、且当前位于怪兽区域的怪兽。
function s.matfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsLocation(LOCATION_MZONE)
end
-- ①效果的过滤函数：自己墓地的卡名包含「融合」（0x46）的魔法卡，且能够返回卡组。
function s.filter(c)
	return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- ①效果的目标函数：检查对象是否为自己墓地符合条件的「融合」魔法卡；发动判定时需满足自己可抽1张卡且墓地存在可选目标。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 发动条件检查：控制者是否能够抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 发动条件检查：自己墓地是否存在1张符合条件的「融合」魔法卡可以作为对象。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 发送选择提示，让玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1张符合条件的「融合」魔法卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：将选中的对象卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 登记操作信息：自己将抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果处理：将对象卡送回持有者卡组最下面，那之后自己抽1张卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联，并且成功将其送回卡组最下面后，才继续抽卡处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_DECK) then
		-- 中断当前效果处理，使“回卡组”和“抽卡”视为不同时处理，防止错失时点。
		Duel.BreakEffect()
		-- 让控制者抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- ②效果发动条件：连锁中其他卡的效果发动，且发动效果的卡不是本卡自身。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler()
end
-- ②效果代价的过滤函数：墓地中卡名包含「融合」（0x46）的魔法卡，且能够除外作为代价。
function s.cfilter(c)
	return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- ②效果发动代价：从自己墓地除外1张符合条件的「融合」魔法卡。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己墓地是否存在1张可以除外的「融合」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 发送选择提示，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1张符合条件的「融合」魔法卡作为除外代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡表侧除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标函数：对象必须是场上1张卡；发动判定时需确认场上存在可选对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动条件检查：场上是否存在1张可以成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 发送选择提示，让玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记操作信息：将对象卡破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：将选择的对象卡破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果关联，则将其破坏。
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
