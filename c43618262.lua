--初買い
-- 效果：
-- ①：从对方卡组上面把5张卡翻开，自己从那之中选1张并宣言100的倍数的数值（最多3000）。对方可以回复那个数值的基本分。回复的场合，自己失去那个数值的基本分，选的卡加入自己手卡，剩下的卡用原本的顺序回到卡组上面。没回复的场合，翻开的卡用原本的顺序回到卡组上面。
function c43618262.initial_effect(c)
	-- ①：从对方卡组上面把5张卡翻开，自己从那之中选1张并宣言100的倍数的数值（最多3000）。对方可以回复那个数值的基本分。回复的场合，自己失去那个数值的基本分，选的卡加入自己手卡，剩下的卡用原本的顺序回到卡组上面。没回复的场合，翻开的卡用原本的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c43618262.cftg)
	e1:SetOperation(c43618262.cfop)
	c:RegisterEffect(e1)
end
-- 检索对方卡组最上方5张卡，判断其中是否有能加入手牌的卡
function c43618262.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方卡组最上方5张卡组成的卡片组
	local g=Duel.GetDecktopGroup(1-tp,5)
	if chk==0 then return g:FilterCount(Card.IsAbleToHand,nil,tp)>0 end
	-- 设置效果的对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
end
-- 处理效果的发动流程，包括翻开卡组、选择卡片、宣言数值、决定是否回复基本分等操作
function c43618262.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取对方卡组最上方5张卡组成的卡片组
	local g=Duel.GetDecktopGroup(1-p,5)
	if g:FilterCount(Card.IsAbleToHand,nil,tp)==0 then return end
	-- 确认对方卡组最上方5张卡
	Duel.ConfirmDecktop(1-p,5)
	-- 提示当前玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 显示对方卡组最上方5张卡的顺序供选择
	Duel.RevealSelectDeckSequence(true)
	local tc=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil,tp):GetFirst()
	-- 隐藏对方卡组最上方5张卡的顺序
	Duel.RevealSelectDeckSequence(false)
	local num=math.floor(3000/100)
	local t={}
	for i=1,num do
		t[i]=i*100
	end
	-- 让当前玩家宣言一个100的倍数（最多3000）的数值
	local val=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 询问对方是否回复基本分让对方把卡加入手卡
	if Duel.SelectYesNo(1-p,aux.Stringid(43618262,0)) then  --"是否回复基本分让对方把卡加入手卡？"
		-- 使对方回复宣言的基本分，若成功则继续执行后续操作
		if Duel.Recover(1-p,val,REASON_EFFECT)>0 then
			-- 使当前玩家失去宣言的基本分
			Duel.SetLP(tp,Duel.GetLP(tp)-val)
			-- 禁止接下来的操作进行洗切卡组检测
			Duel.DisableShuffleCheck(true)
			-- 将选中的卡加入当前玩家手牌
			Duel.SendtoHand(tc,p,REASON_EFFECT)
			-- 确认对方查看选中的卡
			Duel.ConfirmCards(1-p,tc)
			-- 手动洗切当前玩家的手牌
			Duel.ShuffleHand(p)
		end
	end
end
