--女神ヴェルダンディの導き
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，自己场上的怪兽只有「女武神」怪兽的场合，可以从卡组把1张「女神乌尔德的裁断」加入手卡。
-- ②：1回合1次，宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方卡组最上面的卡给双方确认，宣言的种类的卡的场合，对方把那张卡在自身场上盖放。不是的场合或者不能盖放的场合，对方把那张卡加入手卡。
function c64961254.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，自己场上的怪兽只有「女武神」怪兽的场合，可以从卡组把1张「女神乌尔德的裁断」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,64961254+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c64961254.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方卡组最上面的卡给双方确认，宣言的种类的卡的场合，对方把那张卡在自身场上盖放。不是的场合或者不能盖放的场合，对方把那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_MSET+CATEGORY_SSET)
	e3:SetDescription(aux.Stringid(64961254,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c64961254.target)
	e3:SetOperation(c64961254.operation)
	c:RegisterEffect(e3)
end
-- 过滤里侧表示或非「女武神」字段的怪兽，用于反向校验是否全为表侧「女武神」怪兽
function c64961254.thcfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x122)
end
-- 检查①效果条件：己方怪兽区存在怪兽且全部为表侧表示的「女武神」怪兽
function c64961254.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认己方怪兽区至少有1只怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 确认己方怪兽区不存在里侧或非「女武神」字段的怪兽
		and not Duel.IsExistingMatchingCard(c64961254.thcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤卡组中卡名为「女神乌尔德的裁断」且可加入手卡的卡片
function c64961254.thfilter(c)
	return c:IsCode(91969909) and c:IsAbleToHand()
end
-- ①发动时效果处理：若己方场上仅有「女武神」怪兽且卡组存在「女神乌尔德的裁断」，可选择将其检索加入手卡
function c64961254.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从己方卡组检索可加入手卡的「女神乌尔德的裁断」
	local g=Duel.GetMatchingGroup(c64961254.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and c64961254.thcon(e,tp,eg,ep,ev,re,r,rp) and
		-- 询问己方玩家是否从卡组把「女神乌尔德的裁断」加入手卡
		Duel.SelectYesNo(tp,aux.Stringid(64961254,0)) then  --"是否把「女神乌尔德的裁断」加入手卡？"
		-- 向己方发送选择要加入手卡的「女神乌尔德的裁断」的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的「女神乌尔德的裁断」以效果加入己方手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的「女神乌尔德的裁断」进行确认
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- ②效果发动前确认对方卡组仍有卡，并让己方宣言怪兽·魔法·陷阱之一作为连锁参数
function c64961254.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方卡组剩余卡片数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	-- 向己方发送选择宣言卡片种类的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让己方宣言卡片种类（怪兽·魔法·陷阱）并记录为当前连锁的目标参数
	Duel.SetTargetParam(Duel.AnnounceType(tp))
end
-- ②效果处理：翻开确认对方卡组最上方1张卡，若与宣言种类一致且可盖放则由对方盖放至自身场上（怪兽为里侧守备特召），否则让对方将其加入手卡
function c64961254.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时确认对方卡组仍有卡，若卡组为空则中止
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)<=0 then return end
	-- 将对方卡组最上面的1张卡翻开并给双方确认
	Duel.ConfirmDecktop(1-tp,1)
	-- 获取对方卡组最上面的1张卡
	local g=Duel.GetDecktopGroup(1-tp,1)
	local tc=g:GetFirst()
	-- 禁用下一次卡组操作后的洗卡检测，防止扰乱对方卡组顺序
	Duel.DisableShuffleCheck()
	-- 读取发动时宣言的卡片种类参数opt（0为怪兽、1为魔法、2为陷阱）
	local opt=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if opt==0 and tc:IsType(TYPE_MONSTER)
		and tc:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEDOWN_DEFENSE,1-tp) then
		-- 宣言怪兽且确认卡为可盖放的怪兽时，由对方将其以里侧守备表示特殊召唤到自身场上
		Duel.SpecialSummon(tc,0,1-tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
	elseif opt==1 and tc:IsType(TYPE_SPELL) and tc:IsSSetable() then
		-- 宣言魔法且确认卡为可盖放的魔法卡时，由对方将其盖放到自身的魔法·陷阱区
		Duel.SSet(1-tp,tc)
	elseif opt==2 and tc:IsType(TYPE_TRAP) and tc:IsSSetable() then
		-- 宣言陷阱且确认卡为可盖放的陷阱卡时，由对方将其盖放到自身的魔法·陷阱区
		Duel.SSet(1-tp,tc)
	else
		-- 宣言不中或无法盖放时，将确认的卡以效果加入对方手卡
		Duel.SendtoHand(g,1-tp,REASON_EFFECT)
		-- 洗切对方手卡
		Duel.ShuffleHand(1-tp)
	end
end
