--シークレット・パスフレーズ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张「直播☆双子」魔法·陷阱卡或「邪恶★双子」魔法·陷阱卡加入手卡。自己场上有「姬丝基勒」怪兽以及「璃拉」怪兽存在的场合，也能作为代替把1只「邪恶★双子」怪兽加入手卡。
function c61976639.initial_effect(c)
	-- ①：从卡组把1张「直播☆双子」魔法·陷阱卡或「邪恶★双子」魔法·陷阱卡加入手卡。自己场上有「姬丝基勒」怪兽以及「璃拉」怪兽存在的场合，也能作为代替把1只「邪恶★双子」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,61976639+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c61976639.target)
	e1:SetOperation(c61976639.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中「直播☆双子」或「邪恶★双子」的魔法·陷阱卡且能加入手卡
function c61976639.thfilter(c)
	return c:IsSetCard(0x1151,0x2151) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 过滤卡组中「邪恶★双子」的怪兽卡且能加入手卡
function c61976639.thfilter1(c)
	return c:IsSetCard(0x2151) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤场上表侧表示的指定系列怪兽
function c61976639.scchk(c,sc)
	return c:IsSetCard(sc) and c:IsFaceup()
end
-- 效果发动的目标检查与操作信息设置
function c61976639.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查卡组中是否存在可以加入手卡的「直播☆双子」或「邪恶★双子」魔法·陷阱卡
		local b1=Duel.IsExistingMatchingCard(c61976639.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查卡组中是否存在可以加入手卡的「邪恶★双子」怪兽卡
		local b2=Duel.IsExistingMatchingCard(c61976639.thfilter1,tp,LOCATION_DECK,0,1,nil)
			-- 检查自己场上是否存在表侧表示的「姬丝基勒」怪兽
			and Duel.IsExistingMatchingCard(c61976639.scchk,tp,LOCATION_MZONE,0,1,nil,0x152)
			-- 检查自己场上是否存在表侧表示的「璃拉」怪兽
			and Duel.IsExistingMatchingCard(c61976639.scchk,tp,LOCATION_MZONE,0,1,nil,0x153)
		return b1 or b2
	end
	-- 设置操作信息，表示该效果会将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的准备阶段，根据场上条件合并可选的卡片列表
function c61976639.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有可以加入手卡的「直播☆双子」或「邪恶★双子」魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c61976639.thfilter,tp,LOCATION_DECK,0,nil)
	-- 检查自己场上是否存在表侧表示的「姬丝基勒」怪兽
	if Duel.IsExistingMatchingCard(c61976639.scchk,tp,LOCATION_MZONE,0,1,nil,0x152)
		-- 检查自己场上是否存在表侧表示的「璃拉」怪兽
		and Duel.IsExistingMatchingCard(c61976639.scchk,tp,LOCATION_MZONE,0,1,nil,0x153) then
		-- 获取卡组中所有可以加入手卡的「邪恶★双子」怪兽卡
		local eg=Duel.GetMatchingGroup(c61976639.thfilter1,tp,LOCATION_DECK,0,nil)
		g:Merge(eg)
	end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local tg=g:Select(tp,1,1,nil)
	if #tg>0 then
		-- 将选中的卡片加入玩家手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,tg)
	end
end
