--大霊術－「一輪」
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有守备力1500的魔法师族怪兽存在，对方发动的怪兽的效果1回合只有1次无效化。
-- ②：自己主要阶段才能发动。手卡1只魔法师族怪兽给对方观看，和那只怪兽相同属性而攻击力1500/守备力200的1只怪兽从卡组加入手卡，给人观看的怪兽回到卡组。
function c38057522.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要自己场上有守备力1500的魔法师族怪兽存在，对方发动的怪兽的效果1回合只有1次无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c38057522.discon)
	e1:SetOperation(c38057522.disop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。手卡1只魔法师族怪兽给对方观看，和那只怪兽相同属性而攻击力1500/守备力200的1只怪兽从卡组加入手卡，给人观看的怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38057522,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,38057522)
	e2:SetTarget(c38057522.thtg)
	e2:SetOperation(c38057522.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在满足条件的魔法师族怪兽（守备力为1500）
function c38057522.disfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsDefense(1500)
end
-- 条件函数，判断是否满足效果①的触发条件（对方发动怪兽效果且己方场上有符合条件的怪兽）
function c38057522.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在至少1只守备力为1500的魔法师族怪兽
	return Duel.IsExistingMatchingCard(c38057522.disfilter,tp,LOCATION_MZONE,0,1,nil)
		and rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 操作函数，使对方怪兽效果无效
function c38057522.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家显示此卡的发动动画
	Duel.Hint(HINT_CARD,0,38057522)
	-- 使当前连锁的效果无效
	Duel.NegateEffect(ev)
end
-- 过滤函数，用于选择手卡中可以给对方确认的魔法师族怪兽（未公开且能送回卡组）
function c38057522.tdfilter(c,tp)
	return c:IsRace(RACE_SPELLCASTER) and not c:IsPublic() and c:IsAbleToDeck()
		-- 检查卡组中是否存在满足条件的怪兽（攻击力1500/守备力200且属性相同）
		and Duel.IsExistingMatchingCard(c38057522.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
-- 过滤函数，用于选择卡组中满足条件的怪兽（攻击力1500/守备力200且属性相同）
function c38057522.thfilter(c,attr)
	return c:IsAttack(1500) and c:IsDefense(200) and c:IsAttribute(attr) and c:IsAbleToHand()
end
-- 目标函数，设置效果处理时的操作信息（检索、送手牌、送卡组）
function c38057522.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的魔法师族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c38057522.tdfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 设置效果处理时将1张卡从卡组送入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置效果处理时将1张卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，执行②效果的具体操作
function c38057522.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要给对方确认的手卡怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的手卡怪兽
	local g=Duel.SelectMatchingCard(tp,c38057522.tdfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		-- 向对方玩家确认所选怪兽
		Duel.ConfirmCards(1-tp,tc)
		local attr=tc:GetAttribute()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择满足条件的怪兽
		local hg=Duel.SelectMatchingCard(tp,c38057522.thfilter,tp,LOCATION_DECK,0,1,1,nil,attr)
		local hc=hg:GetFirst()
		-- 将选中的怪兽送入手牌
		if hc and Duel.SendtoHand(hc,nil,REASON_EFFECT)~=0 then
			-- 向对方玩家确认送入手牌的怪兽
			Duel.ConfirmCards(1-tp,hc)
			if hc:IsLocation(LOCATION_HAND) then
				-- 将给对方确认的怪兽送回卡组并洗牌
				Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end
