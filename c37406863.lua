--封神鏡
-- 效果：
-- 看对方手卡。对方手卡有灵魂怪兽存在的场合，选择1只灵魂怪兽丢弃去墓地。
function c37406863.initial_effect(c)
	-- 效果原文内容：看对方手卡。对方手卡有灵魂怪兽存在的场合，选择1只灵魂怪兽丢弃去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c37406863.target)
	e1:SetOperation(c37406863.activate)
	c:RegisterEffect(e1)
end
c37406863.has_text_type=TYPE_SPIRIT
-- 效果作用：检查对方手牌数量是否大于0，并设置目标玩家为当前玩家。
function c37406863.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件，即对方手牌数量大于0。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 效果作用：将当前连锁的目标玩家设置为tp。
	Duel.SetTargetPlayer(tp)
end
-- 效果作用：处理封神镜的发动效果，包括确认对方手牌、筛选灵魂怪兽并将其丢弃至墓地。
function c37406863.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果作用：获取目标玩家的对方手牌组。
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 效果作用：向目标玩家确认其手牌内容。
		Duel.ConfirmCards(p,g)
		local tg=g:Filter(Card.IsType,nil,TYPE_SPIRIT)
		if tg:GetCount()>0 then
			-- 效果作用：提示目标玩家选择要送去墓地的卡。
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local sg=tg:Select(p,1,1,nil)
			-- 效果作用：将选择的卡片以丢弃和效果原因送入墓地。
			Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
		end
		-- 效果作用：将对方手牌进行洗牌处理。
		Duel.ShuffleHand(1-p)
	end
end
