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
-- 发动时的条件判定与对象设定：获取对方卡组顶5张，若其中有能加入手卡的卡则满足发动条件，并将连锁的对象玩家设为自己（用于后续处理中确定回复与加入手卡的主体）。
function c43618262.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方卡组最上方的5张卡作为对象组。
	local g=Duel.GetDecktopGroup(1-tp,5)
	if chk==0 then return g:FilterCount(Card.IsAbleToHand,nil,tp)>0 end
	-- 将当前连锁的效果对象玩家设置为发动玩家自己，使后续处理知道“自己从那之中选1张”以及“自己失去基本分”等主体。
	Duel.SetTargetPlayer(tp)
end
-- 效果处理整体：确认对方卡组顶5张，自己选择其中1张并宣言100的倍数的数值（最多3000），让对方选择是否回复该数值。若对方回复，则自己失去等量基本分、所选卡加入自己手卡，剩余卡按原顺序放回对方卡组顶；若对方不回复，则翻开的卡全部按原顺序留在对方卡组顶（无需额外移动）。
function c43618262.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得连锁中记录的对象玩家（即为发动玩家tp）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 取得该对象玩家的对方（即原对方）卡组最上方的5张卡。
	local g=Duel.GetDecktopGroup(1-p,5)
	if g:FilterCount(Card.IsAbleToHand,nil,tp)==0 then return end
	-- 让对方玩家确认其卡组最上方的5张卡（即翻开这些卡）。
	Duel.ConfirmDecktop(1-p,5)
	-- 弹出选择提示：请选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 开始以卡组原本顺序展示这些翻开的卡，方便从其中选择1张（开启顺序显示模式）。
	Duel.RevealSelectDeckSequence(true)
	local tc=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil,tp):GetFirst()
	-- 结束以卡组原本顺序展示，恢复普通选择显示（关闭顺序显示模式）。
	Duel.RevealSelectDeckSequence(false)
	local num=math.floor(3000/100)
	local t={}
	for i=1,num do
		t[i]=i*100
	end
	-- 让发动玩家从100到3000的100的倍数中宣言一个数值。
	local val=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 询问对方玩家是否回复该数值的基本分，以决定后续分支。
	if Duel.SelectYesNo(1-p,aux.Stringid(43618262,0)) then  --"是否回复基本分让对方把卡加入手卡？"
		-- 若对方玩家回复该数值的基本分成功，才执行失去LP和加入手卡等后续操作（回复值可能因其他效果变为0）。
		if Duel.Recover(1-p,val,REASON_EFFECT)>0 then
			-- 强制将发动玩家的LP减去宣言数值，实现“自己失去那个数值的基本分”。
			Duel.SetLP(tp,Duel.GetLP(tp)-val)
			-- 禁用紧接着的自动洗切检测，防止后续移动卡片时自动洗切卡组，保证剩下卡片能按原顺序放回卡组顶。
			Duel.DisableShuffleCheck(true)
			-- 将所选的那张卡加入发动玩家（对象玩家p）手卡，实现“选的卡加入自己手卡”。
			Duel.SendtoHand(tc,p,REASON_EFFECT)
			-- 将加入手卡的那张卡展示给对方玩家确认。
			Duel.ConfirmCards(1-p,tc)
			-- 洗切发动玩家的手牌，重置洗牌检测状态（配合禁用自动洗切，确保卡组顺序不受影响）。
			Duel.ShuffleHand(p)
		end
	end
end
