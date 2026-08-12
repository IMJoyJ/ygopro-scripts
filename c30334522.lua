--イビリチュア・プシュケローネ
-- 效果：
-- 名字带有「遗式」的仪式魔法卡降临。1回合1次，宣言怪兽的种族·属性才能发动。把对方手卡随机1张确认，宣言的种族·属性的怪兽的场合，那张卡回到持有者卡组。不是的场合回到原状。
function c30334522.initial_effect(c)
	c:EnableReviveLimit()
	-- 名字带有「遗式」的仪式魔法卡降临。1回合1次，宣言怪兽的种族·属性才能发动。把对方手卡随机1张确认，宣言的种族·属性的怪兽的场合，那张卡回到持有者卡组。不是的场合回到原状。
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
-- 检索满足条件的卡片组
function c30334522.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌是否存在
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0 end
	-- 提示玩家选择种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家宣言一个种族
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rc)
	-- 提示玩家选择属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言一个属性
	local at=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	-- 将宣言的属性设置为效果参数
	Duel.SetTargetParam(at)
end
-- 执行效果处理流程
function c30334522.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方手牌是否存在
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==0 then return end
	-- 提示玩家选择确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从对方手牌中随机选择一张卡
	local tc=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1):GetFirst()
	-- 确认所选的卡
	Duel.ConfirmCards(tp,tc)
	local rc=e:GetLabel()
	-- 获取效果参数中的属性值
	local at=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc:IsRace(rc) and tc:IsAttribute(at) then
		-- 将卡送回卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 将对方手牌洗牌
	else Duel.ShuffleHand(1-tp) end
end
