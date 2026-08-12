--SPYGAL－ミスティ
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合，宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方卡组最上面的卡给双方确认，宣言的种类的卡的场合，自己从卡组抽1张。
-- ②：1回合1次，以自己场上1只「秘旋谍-花公子」和对方场上1只怪兽为对象才能发动。那2只怪兽回到持有者手卡。这个效果在对方回合也能发动。
function c94096018.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方卡组最上面的卡给双方确认，宣言的种类的卡的场合，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94096018,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c94096018.drtg)
	e1:SetOperation(c94096018.drop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己场上1只「秘旋谍-花公子」和对方场上1只怪兽为对象才能发动。那2只怪兽回到持有者手卡。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94096018,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetTarget(c94096018.thtg)
	e3:SetOperation(c94096018.thop)
	c:RegisterEffect(e3)
end
-- 效果①的发动准备与条件检查函数
function c94096018.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 以及对方卡组是否有卡
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	-- 提示玩家选择卡片种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让玩家宣言卡片种类（怪兽·魔法·陷阱）并将结果保存在Label中
	e:SetLabel(Duel.AnnounceType(tp))
	-- 设置效果处理的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的对象参数为1（抽1张卡）
	Duel.SetTargetParam(1)
end
-- 效果①的效果处理函数
function c94096018.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果对方卡组没有卡，则不处理
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	-- 获取当前连锁的对象玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给双方确认对方卡组最上面的1张卡
	Duel.ConfirmDecktop(1-tp,1)
	-- 获取对方卡组最上面的1张卡
	local g=Duel.GetDecktopGroup(1-tp,1)
	local tc=g:GetFirst()
	local opt=e:GetLabel()
	if (opt==0 and tc:IsType(TYPE_MONSTER)) or (opt==1 and tc:IsType(TYPE_SPELL)) or (opt==2 and tc:IsType(TYPE_TRAP)) then
		-- 让对象玩家抽指定数量的卡
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
-- 过滤自己场上表侧表示的「秘旋谍-花公子」且能回到手牌的卡
function c94096018.thfilter(c)
	return c:IsFaceup() and c:IsCode(41091257) and c:IsAbleToHand()
end
-- 效果②的发动准备与条件检查函数
function c94096018.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在符合条件的「秘旋谍-花公子」
	if chk==0 then return Duel.IsExistingTarget(c94096018.thfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 以及对方场上是否存在可以回到手牌的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只符合条件的「秘旋谍-花公子」作为效果对象
	local g1=Duel.SelectTarget(tp,c94096018.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只可以回到手牌的怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁的操作信息为：将这2张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 效果②的效果处理函数
function c94096018.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==2 then
		-- 将这些卡送回持有者手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
