--妖精伝姫－ラチカ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤时才能发动。对方回复500基本分。那之后，对方从把这个效果发动的玩家的卡组上面把3张卡确认，从那之中选1张。自己把对方选的卡加入手卡。剩余回到卡组。
-- ②：这张卡进行战斗的伤害计算前才能发动。这张卡送去墓地。
function c65953423.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤时才能发动。对方回复500基本分。那之后，对方从把这个效果发动的玩家的卡组上面把3张卡确认，从那之中选1张。自己把对方选的卡加入手卡。剩余回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65953423,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,65953423)
	e1:SetTarget(c65953423.thtg)
	e1:SetOperation(c65953423.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的伤害计算前才能发动。这张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65953423,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_CONFIRM)
	e2:SetCondition(c65953423.batlcon)
	e2:SetTarget(c65953423.batltg)
	e2:SetOperation(c65953423.batlop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备与合法性检测（检查卡组上方是否有至少3张卡且存在可加入手牌的卡，并设置回复和加入手牌的操作信息）
function c65953423.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家卡组最上方的3张卡
		local g=Duel.GetDecktopGroup(tp,3)
		return #g>=3 and g:IsExists(Card.IsAbleToHand,1,nil)
	end
	-- 设置连锁处理中的操作信息：对方回复500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,500)
	-- 设置连锁处理中的操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- ①效果的执行（对方回复500基本分，确认卡组顶3张卡并由对方选择1张加入自己手牌，其余洗回卡组）
function c65953423.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 若对方成功回复500基本分且自己卡组数量在3张以上
	if Duel.Recover(1-tp,500,REASON_EFFECT)~=0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 then
		-- 中断当前效果，使后续处理与回复基本分不视为同时进行
		Duel.BreakEffect()
		-- 获取自己卡组最上方的3张卡
		local g=Duel.GetDecktopGroup(tp,3)
		-- 让对方玩家确认这3张卡
		Duel.ConfirmCards(1-tp,g)
		-- 向对方玩家发送提示信息：请选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sc=g:Select(1-tp,1,1,nil):GetFirst()
		if sc:IsAbleToHand() then
			-- 将对方选择的卡加入自己手牌
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			-- 让对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sc)
			-- 洗切自己手牌
			Duel.ShuffleHand(tp)
		else
			-- 若该卡无法加入手牌，则因规则送去墓地
			Duel.SendtoGrave(sc,REASON_RULE)
		end
		-- 将剩余的卡洗回卡组
		Duel.ShuffleDeck(tp)
	end
end
-- ②效果的发动条件（这张卡进行战斗且双方怪兽都在场上）
function c65953423.batlcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsRelateToBattle()
end
-- ②效果的发动准备（检测自身是否能送去墓地，并设置送去墓地的操作信息）
function c65953423.batltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGrave() end
	-- 设置连锁处理中的操作信息：将这张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,tp,0)
end
-- ②效果的执行（将这张卡送去墓地）
function c65953423.batlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
