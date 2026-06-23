--魔鍵銃－バトスバスター
-- 效果：
-- 「魔键-马夫提亚」降临。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡仪式召唤成功的场合才能发动。从卡组把1张「魔键」卡加入手卡。
-- ②：1回合1次，持有和自己墓地的通常怪兽或者「魔键」怪兽的其中任意种相同属性的对方怪兽在和这张卡进行战斗的攻击宣言时才能发动。自己手卡任意数量回到卡组最下面，那只对方怪兽的效果直到回合结束时无效。那之后，自己抽出回到卡组的数量。
function c19489718.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合才能发动。从卡组把1张「魔键」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19489718,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,19489718)
	e1:SetCondition(c19489718.srcon)
	e1:SetTarget(c19489718.srtg)
	e1:SetOperation(c19489718.srop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，持有和自己墓地的通常怪兽或者「魔键」怪兽的其中任意种相同属性的对方怪兽在和这张卡进行战斗的攻击宣言时才能发动。自己手卡任意数量回到卡组最下面，那只对方怪兽的效果直到回合结束时无效。那之后，自己抽出回到卡组的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19489718,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DISABLE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c19489718.discon)
	e2:SetTarget(c19489718.distg)
	e2:SetOperation(c19489718.disop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为仪式召唤成功
function c19489718.srcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 筛选满足「魔键」卡组且能加入手牌的卡片
function c19489718.srfilter(c)
	return c:IsSetCard(0x165) and c:IsAbleToHand()
end
-- 设置效果处理时要检索的卡片类型为「魔键」卡
function c19489718.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索「魔键」卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c19489718.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要检索的卡片数量为1张
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果的执行部分，选择并加入手牌
function c19489718.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「魔键」卡
	local g=Duel.SelectMatchingCard(tp,c19489718.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选墓地中的通常怪兽或「魔键」怪兽，且属性与对方怪兽相同的卡片
function c19489718.cfilter(c,attr)
	return (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165)) and c:IsAttribute(attr)
end
-- 判断是否满足发动效果的条件
function c19489718.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	e:SetLabelObject(tc)
	-- 判断对方怪兽是否为攻击状态且为怪兽
	return tc and tc:IsControler(1-tp) and tc:IsType(TYPE_MONSTER) and aux.NegateMonsterFilter(tc)
		-- 判断自己墓地是否存在与对方怪兽属性相同的怪兽
		and Duel.IsExistingMatchingCard(c19489718.cfilter,tp,LOCATION_GRAVE,0,1,nil,tc:GetAttribute())
end
-- 设置效果处理时要处理的卡片类型为手牌
function c19489718.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	-- 判断是否满足抽卡条件
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 判断是否满足将手牌送回卡组的条件
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	-- 设置效果处理时的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理时要送回卡组的卡片数量为1张
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置效果处理时要使对方怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
	-- 设置效果处理时要抽卡的数量为1张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理效果的执行部分，选择手牌送回卡组并使对方怪兽效果无效
function c19489718.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的手牌
	local g=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,1,63,nil)
	if g:GetCount()==0 then return end
	-- 将选中的手牌送回卡组
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	if ct==0 then return end
	-- 对送回卡组的卡进行排序
	Duel.SortDecktop(p,p,ct)
	for i=1,ct do
		-- 获取卡组最上方的卡
		local mg=Duel.GetDecktopGroup(p,1)
		-- 将卡移动到卡组最下方
		Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
	end
	if tc and tc:IsRelateToBattle() and tc:IsControler(1-tp)
		and tc:IsCanBeDisabledByEffect(e) then
		-- 使对方怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 让玩家抽卡
		Duel.Draw(p,ct,REASON_EFFECT)
	end
end
