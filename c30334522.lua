--イビリチュア・プシュケローネ
-- 效果：
-- 名字带有「遗式」的仪式魔法卡降临。1回合1次，宣言怪兽的种族·属性才能发动。把对方手卡随机1张确认，宣言的种族·属性的怪兽的场合，那张卡回到持有者卡组。不是的场合回到原状。
function c30334522.initial_effect(c)
	c:EnableReviveLimit()
	-- 1回合1次，宣言怪兽的种族·属性才能发动。把对方手卡随机1张确认，宣言的种族·属性的怪兽的场合，那张卡回到持有者卡组。不是的场合回到原状。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30334522,0))  --"宣言"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c30334522.target)
	e1:SetOperation(c30334522.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的处理：检查对方手牌是否有卡；让发动者宣言1个种族和1个属性，并将宣言的种族存入效果标签、宣言的属性存入连锁参数，供效果处理时使用。
function c30334522.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：若对方手牌为0张，则不能发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0 end
	-- 向发动者显示“请选择要宣言的种族”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让发动者从全部种族中宣言1个种族，并将宣言结果赋值给rc。
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rc)
	-- 向发动者显示“请选择要宣言的属性”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让发动者从全部属性中宣言1个属性，并将宣言结果赋值给at。
	local at=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	-- 将宣言的属性值设置为当前连锁的目标参数，效果处理时通过CHAININFO_TARGET_PARAM读取。
	Duel.SetTargetParam(at)
end
-- 效果处理：随机选取对方手牌1张并展示，若该卡同时符合宣言的种族和属性，则将其返回持有者卡组并洗牌；否则洗切对方手牌（恢复原状）。
function c30334522.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若对方手牌为0张，则直接终止处理。
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==0 then return end
	-- 显示提示信息，提示将选取一张对方手牌进行确认。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从对方手牌中随机选择1张，取得该卡作为确认对象。
	local tc=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1):GetFirst()
	-- 将随机选出的卡展示给发动者确认。
	Duel.ConfirmCards(tp,tc)
	local rc=e:GetLabel()
	-- 从当前连锁信息中获取发动时宣言的属性值。
	local at=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc:IsRace(rc) and tc:IsAttribute(at) then
		-- 将满足条件的卡返回持有者卡组，并执行洗牌（SEQ_DECKSHUFFLE）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 若不符合条件，则洗切对方手牌，使手牌恢复原状（隐藏确认过的卡的位置）。
	else Duel.ShuffleHand(1-tp) end
end
