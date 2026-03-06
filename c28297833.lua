--ネクロフェイス
-- 效果：
-- ①：这张卡召唤成功的场合发动。除外的双方的卡全部回到持有者卡组。这张卡的攻击力上升这个效果回到卡组的数量×100。
-- ②：这张卡被除外的场合发动。双方玩家各自从自身卡组上面把5张卡除外。
function c28297833.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤成功的场合发动。除外的双方的卡全部回到持有者卡组。这张卡的攻击力上升这个效果回到卡组的数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28297833,0))  --"除外的卡全部回到卡组"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c28297833.tdtg)
	e1:SetOperation(c28297833.tdop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡被除外的场合发动。双方玩家各自从自身卡组上面把5张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28297833,1))  --"双方从卡组上面把5张卡从游戏中除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_REMOVE)
	e2:SetTarget(c28297833.rmtg)
	e2:SetOperation(c28297833.rmop)
	c:RegisterEffect(e2)
end
-- 设置效果处理时的操作信息，用于确定效果处理中将要将除外区的卡送回卡组
function c28297833.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为将除外区的卡送回卡组，数量为1，对象为双方玩家的除外区
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_REMOVED)
end
-- 效果处理函数，将除外区的卡全部送回卡组，并根据送回卡组的数量提升自身攻击力
function c28297833.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方玩家除外区的所有卡组成一个卡组
	local g=Duel.GetFieldGroup(tp,LOCATION_REMOVED,LOCATION_REMOVED)
	-- 将指定卡组送回双方玩家的卡组最底端并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 效果原文内容：①：这张卡召唤成功的场合发动。除外的双方的卡全部回到持有者卡组。这张卡的攻击力上升这个效果回到卡组的数量×100。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(ct*100)
		c:RegisterEffect(e1)
	end
end
-- 设置效果处理时的操作信息，用于确定效果处理中将要将双方卡组最上方的卡除外
function c28297833.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为将双方卡组最上方的卡除外，数量为5，对象为双方玩家的卡组
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,5,PLAYER_ALL,LOCATION_DECK)
end
-- 效果处理函数，双方各自从卡组最上方除外5张卡
function c28297833.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前玩家卡组最上方的5张卡
	local g1=Duel.GetDecktopGroup(tp,5)
	-- 获取对方玩家卡组最上方的5张卡
	local g2=Duel.GetDecktopGroup(1-tp,5)
	g1:Merge(g2)
	-- 禁止接下来的操作自动触发洗牌检查
	Duel.DisableShuffleCheck()
	-- 将指定卡组以除外形式移除，即从游戏中除外
	Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
end
