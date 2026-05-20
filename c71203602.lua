--イビリチュア・リヴァイアニマ
-- 效果：
-- 名字带有「遗式」的仪式魔法卡降临。这张卡的攻击宣言时，从自己卡组抽1张卡，给双方确认。确认的卡是名字带有「遗式」的怪兽的场合，把对方手卡随机1张确认。
function c71203602.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡的攻击宣言时，从自己卡组抽1张卡，给双方确认。确认的卡是名字带有「遗式」的怪兽的场合，把对方手卡随机1张确认。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71203602,0))  --"抽卡确认"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(c71203602.target)
	e1:SetOperation(c71203602.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标与检测函数
function c71203602.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息，表明此效果包含由自己抽1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果处理函数，执行抽卡、确认以及满足条件时确认对方手卡的操作
function c71203602.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让自身玩家因效果抽1张卡
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	if ct==0 then return end
	-- 获取刚才因抽卡操作而加入手卡的卡片
	local tc=Duel.GetOperatedGroup():GetFirst()
	-- 将抽到的卡给对方确认
	Duel.ConfirmCards(1-tp,tc)
	-- 洗切自身的手卡
	Duel.ShuffleHand(tp)
	if tc:IsSetCard(0x3a) and tc:IsType(TYPE_MONSTER) then
		-- 中断效果处理，使后续的确认手卡操作与抽卡不视为同时处理
		Duel.BreakEffect()
		-- 获取对方玩家的所有手卡
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if g:GetCount()>0 then
			local sg=g:RandomSelect(tp,1)
			-- 给自身玩家确认随机选出的对方手卡
			Duel.ConfirmCards(tp,sg)
		end
		-- 洗切对方的手卡
		Duel.ShuffleHand(1-tp)
	end
end
