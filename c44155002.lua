--魔轟神獣ユニコール
-- 效果：
-- 「魔轰神」调整＋调整以外的怪兽1只以上
-- ①：只要这张卡在怪兽区域存在并是双方手卡相同数量，对方发动的魔法·陷阱·怪兽的效果无效化并破坏。
function c44155002.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整必须为「魔轰神」怪兽，非调整任意怪兽1只以上（这里最小数量为1）。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x35),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在并是双方手卡相同数量，对方发动的魔法·陷阱·怪兽的效果无效化并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetOperation(c44155002.disop)
	c:RegisterEffect(e1)
end
-- 该效果处理函数：当连锁处理时，若满足“对方发动效果且双方手牌数相同”的条件，则无效那次效果的发动，并破坏发动效果的那张卡。
function c44155002.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若该连锁是这张卡的控制者（tp）自己发动的效果，或双方手牌数量不相同，则效果不适用，直接返回。
	if ep==tp or Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) then return end
	local rc=re:GetHandler()
	-- 将当前连锁的效果无效化（NegateEffect），并确认效果发动者的卡片仍然与该效果存在关联（没有因处理而离场或失效）。
	if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
		-- 无效成功后，将该卡片以效果破坏（REASON_EFFECT）送入墓地。
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
