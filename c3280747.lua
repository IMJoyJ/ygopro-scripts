--第六感
-- 效果：
-- 自己在1至6的范围里宣言2个数字。对方丢出1个「骰子」，丢出的数目是宣言的数字的其中1个，自己就抽相等数目的卡。猜不中的场合，自己卡组从上面丢弃「骰子」丢出数目的卡去墓地。
function c3280747.initial_effect(c)
	-- 自己在1至6的范围里宣言2个数字。对方丢出1个「骰子」，丢出的数目是宣言的数字的其中1个，自己就抽相等数目的卡。猜不中的场合，自己卡组从上面丢弃「骰子」丢出数目的卡去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DECKDES+CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c3280747.target)
	e1:SetOperation(c3280747.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的合法性判定与操作信息登记：检查我方卡组张数是否足以宣言2个数字（至少6张），并登记骰子效果需宣言2个数字的操作信息。
function c3280747.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定效果能否发动：我方卡组张数必须不少于6，否则不能发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=6 end
	-- 登记骰子效果的操作信息：效果类别为CATEGORY_DICE，目标玩家为我方，参数2表示本次需要宣言2个数字。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
end
-- 效果处理开始：构造一个包含1到6数字的表格，作为玩家宣言数字的候选集合。
function c3280747.activate(e,tp,eg,ep,ev,re,r,rp)
	local t={}
	local i=1
	local p=1
	for i=1,6 do t[i]=i end
	-- 让发动者从1到6中宣言第一个数字，并存入a1。
	local a1=Duel.AnnounceNumber(tp,table.unpack(t))
	for i=1,6 do
		if a1~=i then t[p]=i p=p+1 end
	end
	t[p]=nil
	-- 在排除第一个宣言数字后，让发动者从剩余5个数字中宣言第二个数字，并存入a2。
	local a2=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 由对方玩家投掷1个骰子，将点数存入dc。
	local dc=Duel.TossDice(1-tp,1)
	-- 若骰子点数等于宣言的两个数字之一，则我方抽dc张卡。
	if dc==a1 or dc==a2 then Duel.Draw(tp,dc,REASON_EFFECT)
	-- 否则（未猜中），我方从卡组上方把dc张卡送去墓地。
	else Duel.DiscardDeck(tp,dc,REASON_EFFECT) end
end
