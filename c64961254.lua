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
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_MSET+CATEGORY_SSET)
	e3:SetDescription(aux.Stringid(64961254,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c64961254.target)
	e3:SetOperation(c64961254.operation)
	c:RegisterEffect(e3)
end
-- 过滤条件：里侧表示或者不是「女武神」怪兽的卡
function c64961254.thcfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x122)
end
-- 检查自己场上是否存在怪兽，且这些怪兽是否全部为「女武神」怪兽
function c64961254.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查自己场上是否存在里侧表示怪兽或非「女武神」怪兽，并取反（即自己场上只有表侧表示的「女武神」怪兽）
		and not Duel.IsExistingMatchingCard(c64961254.thcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡名为「女神乌尔德的裁断」且能加入手卡的卡
function c64961254.thfilter(c)
	return c:IsCode(91969909) and c:IsAbleToHand()
end
-- 作为这张卡的发动时的效果处理：若满足条件，可以从卡组将1张「女神乌尔德的裁断」加入手卡
function c64961254.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的「女神乌尔德的裁断」
	local g=Duel.GetMatchingGroup(c64961254.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and c64961254.thcon(e,tp,eg,ep,ev,re,r,rp) and
		-- 提示玩家是否选择将「女神乌尔德的裁断」加入手卡
		Duel.SelectYesNo(tp,aux.Stringid(64961254,0)) then  --"是否把「女神乌尔德的裁断」加入手卡？"
		-- 提示玩家选择要加入手卡的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- ②号效果的发动准备：检查对方卡组是否有卡，并让玩家宣言一个卡片种类
function c64961254.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方卡组是否至少有1张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	-- 提示玩家选择卡片种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让玩家宣言一个卡片种类（怪兽·魔法·陷阱），并将宣言的结果保存为效果目标参数
	Duel.SetTargetParam(Duel.AnnounceType(tp))
end
-- ②号效果的效果处理：确认对方卡组最上方的卡，若与宣言种类相同则在对方场上盖放，否则或无法盖放时加入对方手卡
function c64961254.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若对方卡组没有卡，则不处理效果
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)<=0 then return end
	-- 给双方确认对方卡组最上方的一张卡
	Duel.ConfirmDecktop(1-tp,1)
	-- 获取对方卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(1-tp,1)
	local tc=g:GetFirst()
	-- 禁用接下来的洗牌检查，防止在操作卡组顶端卡片时自动洗牌
	Duel.DisableShuffleCheck()
	-- 获取之前宣言并保存的卡片种类参数
	local opt=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if opt==0 and tc:IsType(TYPE_MONSTER)
		and tc:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEDOWN_DEFENSE,1-tp) then
		-- 将该怪兽在对方场上以里侧守备表示特殊召唤（盖放怪兽）
		Duel.SpecialSummon(tc,0,1-tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
	elseif opt==1 and tc:IsType(TYPE_SPELL) and tc:IsSSetable() then
		-- 将该魔法卡在对方场上盖放
		Duel.SSet(1-tp,tc)
	elseif opt==2 and tc:IsType(TYPE_TRAP) and tc:IsSSetable() then
		-- 将该陷阱卡在对方场上盖放
		Duel.SSet(1-tp,tc)
	else
		-- 将该卡加入对方手卡
		Duel.SendtoHand(g,1-tp,REASON_EFFECT)
		-- 洗切对方的手卡
		Duel.ShuffleHand(1-tp)
	end
end
