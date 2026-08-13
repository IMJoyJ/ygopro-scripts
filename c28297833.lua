--ネクロフェイス
-- 效果：
-- ①：这张卡召唤成功的场合发动。除外的双方的卡全部回到持有者卡组。这张卡的攻击力上升这个效果回到卡组的数量×100。
-- ②：这张卡被除外的场合发动。双方玩家各自从自身卡组上面把5张卡除外。
function c28297833.initial_effect(c)
	-- ①：这张卡召唤成功的场合发动。除外的双方的卡全部回到持有者卡组。这张卡的攻击力上升这个效果回到卡组的数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28297833,0))  --"除外的卡全部回到卡组"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c28297833.tdtg)
	e1:SetOperation(c28297833.tdop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合发动。双方玩家各自从自身卡组上面把5张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28297833,1))  --"双方从卡组上面把5张卡从游戏中除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_REMOVE)
	e2:SetTarget(c28297833.rmtg)
	e2:SetOperation(c28297833.rmop)
	c:RegisterEffect(e2)
end
-- 效果发动时的目标判定：无发动条件限制；声明将双方除外区的卡返回卡组（回卡组分类），并设置对应操作信息，便于系统检测和连锁处理。
function c28297833.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁将以回卡组方式处理双方除外区的卡，对象在效果处理时确定（nil），预计处理数量为1，涉及双方玩家的除外区。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_REMOVED)
end
-- 效果处理：取得双方除外区的所有卡，以效果原因送回持有者卡组并洗切；统计实际回到卡组的张数，若本卡仍表侧表示且与效果关联，则赋予其攻击力上升该张数×100的效果。
function c28297833.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方玩家除外区的全部卡，组成一个卡片组g，用于接下来的回卡组处理。
	local g=Duel.GetFieldGroup(tp,LOCATION_REMOVED,LOCATION_REMOVED)
	-- 将卡片组g中的卡以效果原因送回各自持有者的卡组，并以SEQ_DECKSHUFFLE方式标记需洗切卡组。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升这个效果回到卡组的数量×100。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(ct*100)
		c:RegisterEffect(e1)
	end
end
-- 效果发动时的目标判定：无发动条件限制；声明将双方玩家各自卡组上方的5张卡除外（除外分类），并设置对应操作信息。
function c28297833.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁将把双方玩家卡组上方的卡除外，对象在效果处理时确定（nil），预计处理数量为5，涉及双方玩家的卡组（从卡组除外）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,5,PLAYER_ALL,LOCATION_DECK)
end
-- 效果处理：分别取得双方玩家卡组最上方的5张卡，合并为同一组；禁用自动洗牌检测；然后将这些卡以效果原因表侧表示除外。
function c28297833.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前玩家（效果发动者）卡组最上方的5张卡，作为卡片组g1。
	local g1=Duel.GetDecktopGroup(tp,5)
	-- 获取对方玩家卡组最上方的5张卡，作为卡片组g2。
	local g2=Duel.GetDecktopGroup(1-tp,5)
	g1:Merge(g2)
	-- 禁用本次操作后系统自动检测洗切卡组的功能，因为直接从卡组顶部除外固定张数，不应触发洗牌。
	Duel.DisableShuffleCheck()
	-- 将合并后的卡片组g1中的所有卡以表侧表示除外，原因为效果处理，操作对象是双方卡组顶部的卡。
	Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
end
