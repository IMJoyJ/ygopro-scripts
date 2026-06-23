--天声の服従
-- 效果：
-- ①：支付2000基本分，宣言1个怪兽卡名才能发动。对方把自身卡组确认，有宣言的怪兽的场合，把那之内的1只给双方确认从以下效果选择1个适用。
-- ●确认的卡加入把这张卡发动的玩家手卡。
-- ●确认的卡在把这张卡发动的玩家场上无视召唤条件攻击表示特殊召唤。
function c39238953.initial_effect(c)
	-- ①：支付2000基本分，宣言1个怪兽卡名才能发动。对方把自身卡组确认，有宣言的怪兽的场合，把那之内的1只给双方确认从以下效果选择1个适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c39238953.cost)
	e1:SetTarget(c39238953.target)
	e1:SetOperation(c39238953.activate)
	c:RegisterEffect(e1)
end
-- 支付2000基本分
function c39238953.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 让玩家支付2000基本分
	Duel.PayLPCost(tp,2000)
end
-- 确认卡组存在可加入手卡的卡或玩家能特殊召唤
function c39238953.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方卡组是否存在可加入手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_DECK,1,nil)
		-- 检查玩家是否能特殊召唤
		or Duel.IsPlayerCanSpecialSummon(tp) end
	-- 提示玩家宣言一个卡名
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_MONSTER,OPCODE_ISTYPE,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT,OPCODE_AND}
	-- 让玩家宣言一个怪兽卡名
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡名设置为连锁参数
	Duel.SetTargetParam(ac)
	-- 设置连锁操作信息为宣言卡名
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果处理：确认对方卡组，选择宣言的卡，由玩家选择效果
function c39238953.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁参数中的宣言卡名
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 获取对方卡组所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_DECK)
	if g:GetCount()<1 then return end
	-- 确认对方卡组所有卡
	Duel.ConfirmCards(1-tp,g)
	-- 提示对方选择确认的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local sg=g:FilterSelect(1-tp,Card.IsCode,1,1,nil,ac)
	local tc=sg:GetFirst()
	if tc then
		-- 确认选择的卡给发动玩家看
		Duel.ConfirmCards(tp,sg)
		local b1=tc:IsAbleToHand()
		-- 检查玩家场上是否有空位
		local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK,tp)
		local sel=0
		if b1 and b2 then
			-- 提示对方选择效果
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_OPTION)  --"请选择一个选项"
			-- 选择效果：加入手卡/特殊召唤
			sel=Duel.SelectOption(1-tp,aux.Stringid(39238953,0),aux.Stringid(39238953,1))+1  --"加入手卡/特殊召唤"
		elseif b1 then
			-- 提示对方选择效果
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_OPTION)  --"请选择一个选项"
			-- 选择效果：加入手卡
			sel=Duel.SelectOption(1-tp,aux.Stringid(39238953,0))+1  --"加入手卡"
		elseif b2 then
			-- 提示对方选择效果
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_OPTION)  --"请选择一个选项"
			-- 选择效果：特殊召唤
			sel=Duel.SelectOption(1-tp,aux.Stringid(39238953,1))+2  --"特殊召唤"
		end
		if sel==1 then
			-- 将卡加入发动玩家手卡
			Duel.SendtoHand(sg,tp,REASON_EFFECT)
			-- 确认卡给对方看
			Duel.ConfirmCards(1-tp,sg)
		elseif sel==2 then
			-- 将卡特殊召唤到发动玩家场上
			Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP_ATTACK)
		end
	end
	-- 将对方卡组洗牌
	Duel.ShuffleDeck(1-tp)
end
