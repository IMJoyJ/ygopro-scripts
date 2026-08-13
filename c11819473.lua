--アルカナリーディング
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：进行1次投掷硬币，那个里表的以下效果适用。自己的场地区域有「光之结界」存在的场合，不进行投掷硬币而选里表的其中1个适用。
-- ●表：从卡组把「秘仪读牌」以外的1张持有进行投掷硬币效果的卡加入手卡。
-- ●里：对方从自身卡组选1张卡加入手卡。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只「秘仪之力」怪兽召唤。
function c11819473.initial_effect(c)
	-- 登记这张卡记载的卡名「光之结界」(73206827)，用于后续的场地判定和检索条件关联。
	aux.AddCodeList(c,73206827)
	-- ①：进行1次投掷硬币，那个里表的以下效果适用。自己的场地区域有「光之结界」存在的场合，不进行投掷硬币而选里表的其中1个适用。●表：从卡组把「秘仪读牌」以外的1张持有进行投掷硬币效果的卡加入手卡。●里：对方从自身卡组选1张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11819473,0))  --"投掷硬币"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,11819473)
	e1:SetTarget(c11819473.target)
	e1:SetOperation(c11819473.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从手卡把1只「秘仪之力」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11819473,1))  --"召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,11819474)
	-- 设置②效果的发动代价：把墓地的这张卡除外（bfgcost为除外自身作为cost的通用简易写法）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c11819473.sumtg)
	e2:SetOperation(c11819473.sumop)
	c:RegisterEffect(e2)
end
-- 定义表侧效果的检索过滤函数：判断一张卡是否为「秘仪读牌」以外、持有投掷硬币效果且能够加入手卡的卡。
function c11819473.thfilter1(c)
	-- 表侧检索的具体条件：卡名不是「秘仪读牌」(11819473)，效果含有EFFECT_FLAG_COIN（投掷硬币）属性，并且当前能被加入手卡。
	return not c:IsCode(11819473) and c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN)) and c:IsAbleToHand()
end
-- 定义里侧效果的过滤函数：以选择方p为基准判断卡片能否加入其手卡，用于对方从自身卡组选卡。
function c11819473.thfilter2(c,p)
	return c:IsAbleToHand(p)
end
-- ①效果的发动条件判定：满足“自己卡组存在可表侧检索的卡”或“对方卡组存在可由对方选入其手卡的卡”二者之一即可发动。
function c11819473.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张满足thfilter1（表侧检索目标）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c11819473.thfilter1,tp,LOCATION_DECK,0,1,nil)
		-- 或者检查对方卡组是否存在至少1张满足thfilter2（以对方为视角）的卡，保证里侧效果有可选目标。
		or Duel.IsExistingMatchingCard(c11819473.thfilter2,tp,0,LOCATION_DECK,1,nil,1-tp) end
	-- 设置操作信息：本效果包含投掷硬币分类，由tp投掷1枚硬币。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	-- 设置操作信息：本效果可能将1张卡加入手卡，涉及双方卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_DECK)
end
-- ①效果的实际处理：若自己场地区有「光之结界」，让发动者选择表或里（能执行的一侧）；否则投掷硬币。表侧则自己从卡组选1张符合条件的卡加入手卡并给对方确认；里侧则对方从自身卡组选1张卡加入手卡。
function c11819473.activate(e,tp,eg,ep,ev,re,r,rp)
	local res
	-- 判断自己场地区是否存在「光之结界」(73206827)，决定是否跳过投掷硬币直接选择里表。
	if Duel.IsEnvironment(73206827,tp,LOCATION_FZONE) then
		local off=1
		local ops={}
		local opval={}
		-- 检查自己卡组是否有可检索的表侧目标，若有则向操作者提供“表”选项。
		if Duel.IsExistingMatchingCard(c11819473.thfilter1,tp,LOCATION_DECK,0,1,nil) then
			ops[off]=aux.Stringid(11819473,2)  --"表：从卡组把持有进行投掷硬币效果的卡加入手卡"
			opval[off-1]=0
			off=off+1
		end
		-- 检查对方卡组是否有可供对方选择加入手卡的里侧目标，若有则向操作者提供“里”选项。
		if Duel.IsExistingMatchingCard(c11819473.thfilter2,tp,0,LOCATION_DECK,1,nil,1-tp) then
			ops[off]=aux.Stringid(11819473,3)  --"里：对方从自身卡组选1张卡加入手卡"
			opval[off-1]=1
			off=off+1
		end
		if off==1 then return end
		-- 让发动者在“表”和“里”选项中选择一项，返回值对应选择的序号。
		local op=Duel.SelectOption(tp,table.unpack(ops))
		res=opval[op]
	else
		-- 投掷1枚硬币，Duel.TossCoin返回1为正面、0为反面，用1减去结果使res=0对应表、res=1对应里。
		res=1-Duel.TossCoin(tp,1)
	end
	if res==0 then
		-- 表侧效果处理时，给tp提示消息“请选择要加入手牌的卡”，用于选择卡片的提示文本。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己的卡组中选择1张满足thfilter1（持有投掷硬币效果、非「秘仪读牌」、可加入手卡）的卡。
		local g=Duel.SelectMatchingCard(tp,c11819473.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡加入其持有者的手卡（即tp的手卡），原因记为效果。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方展示被加入手卡的卡片，符合“加入手卡需要确认”的规则要求。
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 里侧效果处理时，给对方(1-tp)提示消息“请选择要加入手牌的卡”。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让对方玩家(1-tp)从自身卡组选择1张以对方为判断基准可加入其手卡的卡（thfilter2）。
		local g=Duel.SelectMatchingCard(1-tp,c11819473.thfilter2,1-tp,LOCATION_DECK,0,1,1,nil,1-tp)
		if g:GetCount()>0 then
			g:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
			-- 将对方选择的卡加入对方的手卡，原因记为效果。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
-- 定义②效果的召唤过滤函数：手牌中属于「秘仪之力」系列，并且目前可以进行通常召唤的怪兽。
function c11819473.sumfilter(c)
	return c:IsSetCard(0x5) and c:IsSummonable(true,nil)
end
-- ②效果的发动条件判定：手牌中存在满足sumfilter的怪兽；并设置操作信息为本效果将进行1只怪兽的召唤。
function c11819473.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌是否存在至少1只满足sumfilter（「秘仪之力」且可通常召唤）的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c11819473.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：本效果将进行1只怪兽的通常召唤（CATEGORY_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ②效果的实际处理：从手牌选择1只「秘仪之力」怪兽进行通常召唤，且忽略每回合的通常召唤次数限制。
function c11819473.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 给tp提示消息“请选择要召唤的卡”，作为选择召唤怪兽的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手牌中选择1只满足sumfilter（「秘仪之力」且可召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c11819473.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 对选择的怪兽进行通常召唤，ignore_count=true表示不消耗通常召唤次数，e=nil表示按一般规则进行通常召唤。
		Duel.Summon(tp,tc,true,nil)
	end
end
