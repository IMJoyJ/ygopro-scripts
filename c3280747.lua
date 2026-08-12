--第六感
-- 效果：
-- 自己在1至6的范围里宣言2个数字。对方丢出1个「骰子」，丢出的数目是宣言的数字的其中1个，自己就抽相等数目的卡。猜不中的场合，自己卡组从上面丢弃「骰子」丢出数目的卡去墓地。
function c3280747.initial_effect(c)
	-- 卡片效果初始化，设置效果类型为发动时点，分类包含抽卡、卡组破坏和骰子效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DECKDES+CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c3280747.target)
	e1:SetOperation(c3280747.activate)
	c:RegisterEffect(e1)
end
-- 效果的处理目标函数，用于判断是否可以发动此效果
function c3280747.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组数量是否不少于6张，不足则无法发动
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=6 end
	-- 设置连锁操作信息，声明将使用骰子效果，需要对方投掷1个骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
end
-- 效果的发动处理函数，用于执行效果的具体逻辑
function c3280747.activate(e,tp,eg,ep,ev,re,r,rp)
	local t={}
	local i=1
	local p=1
	for i=1,6 do t[i]=i end
	-- 玩家宣言一个1至6之间的数字作为第一个猜测数字
	local a1=Duel.AnnounceNumber(tp,table.unpack(t))
	for i=1,6 do
		if a1~=i then t[p]=i p=p+1 end
	end
	t[p]=nil
	-- 玩家宣言另一个1至6之间的数字作为第二个猜测数字
	local a2=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 对方投掷1个骰子，获取骰子结果
	local dc=Duel.TossDice(1-tp,1)
	-- 如果骰子结果等于任一宣言数字，则自己抽相等数量的卡
	if dc==a1 or dc==a2 then Duel.Draw(tp,dc,REASON_EFFECT)
	-- 如果骰子结果不等于任一宣言数字，则自己从卡组上方丢弃相等数量的卡到墓地
	else Duel.DiscardDeck(tp,dc,REASON_EFFECT) end
end
