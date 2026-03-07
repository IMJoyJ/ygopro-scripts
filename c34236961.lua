--アンティ勝負
-- 效果：
-- 双方各自选择1张手卡并展示，相互确认等级。选择等级较高卡的一方将选出的卡放回手卡，选择等级较低卡的一方受到1000点伤害，将选出的卡送去墓地。选择怪兽卡以外的卡时，等级强制计为0。双方选择的卡等级相同时，各自将选出的卡放回手卡。
function c34236961.initial_effect(c)
	-- 效果原文内容：双方各自选择1张手卡并展示，相互确认等级。选择等级较高卡的一方将选出的卡放回手卡，选择等级较低卡的一方受到1000点伤害，将选出的卡送去墓地。选择怪兽卡以外的卡时，等级强制计为0。双方选择的卡等级相同时，各自将选出的卡放回手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c34236961.target)
	e1:SetOperation(c34236961.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否满足发动条件，即双方手牌数量都大于0
function c34236961.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 效果作用：获取我方手牌数量
		local h1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		if e:GetHandler():IsLocation(LOCATION_HAND) then h1=h1-1 end
		-- 效果作用：获取对方手牌数量
		local h2=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
		return (h1>0 and h2>0)
	end
end
-- 效果原文内容：双方各自选择1张手卡并展示，相互确认等级。选择等级较高卡的一方将选出的卡放回手卡，选择等级较低卡的一方受到1000点伤害，将选出的卡送去墓地。选择怪兽卡以外的卡时，等级强制计为0。双方选择的卡等级相同时，各自将选出的卡放回手卡。
function c34236961.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查双方是否都有手牌，若无则不执行效果
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 or Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==0 then return end
	-- 效果作用：提示玩家选择一张手卡进行确认
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 效果作用：让玩家选择一张手卡用于确认
	local g1=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
	-- 效果作用：提示对方玩家选择一张手卡进行确认
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 效果作用：让对方玩家选择一张手卡用于确认
	local g2=Duel.SelectMatchingCard(1-tp,nil,1-tp,LOCATION_HAND,0,1,1,nil)
	-- 效果作用：向对方玩家展示所选的卡
	Duel.ConfirmCards(1-tp,g1)
	-- 效果作用：向玩家展示所选的卡
	Duel.ConfirmCards(tp,g2)
	local atpsl=g1:GetFirst()
	local ntpsl=g2:GetFirst()
	local atplv=atpsl:IsType(TYPE_MONSTER) and atpsl:GetLevel() or 0
	local ntplv=ntpsl:IsType(TYPE_MONSTER) and ntpsl:GetLevel() or 0
	if atplv==ntplv then
		-- 效果作用：将玩家手牌洗切
		Duel.ShuffleHand(tp)
		-- 效果作用：将对方手牌洗切
		Duel.ShuffleHand(1-tp)
	elseif atplv>ntplv then
		-- 效果作用：给对方玩家造成1000点伤害
		Duel.Damage(1-tp,1000,REASON_EFFECT)
		-- 效果作用：将对方选择的卡送去墓地
		Duel.SendtoGrave(g2,REASON_EFFECT)
		-- 效果作用：将玩家手牌洗切
		Duel.ShuffleHand(tp)
	else
		-- 效果作用：给玩家造成1000点伤害
		Duel.Damage(tp,1000,REASON_EFFECT)
		-- 效果作用：将玩家选择的卡送去墓地
		Duel.SendtoGrave(g1,REASON_EFFECT)
		-- 效果作用：将对方手牌洗切
		Duel.ShuffleHand(1-tp)
	end
end
