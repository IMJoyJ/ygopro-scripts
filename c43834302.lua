--シンクロ・フェローズ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把以下怪兽各1只加入手卡。那之后，选自己1张手卡丢弃。
-- ●「废品同调士」
-- ●有「废品战士」「星尘龙」其中任意种的卡名记述的怪兽
-- ②：把墓地的这张卡除外，以自己场上1只同调怪兽为对象才能发动。那只怪兽的等级下降1星。并且再在这个回合让自己在通常召唤外加上只有1次，自己主要阶段可以把1只「同调士」怪兽召唤。
local s,id,o=GetID()
-- 初始化函数：注册魔法卡发动效果（检索加入手卡并丢弃手牌）以及墓地除外激活的等级下降并追加召唤「同调士」怪兽的效果
function s.initial_effect(c)
	-- 记录本卡在规则上记述有「废品同调士」、「废品战士」和「星尘龙」这3张卡的卡名
	aux.AddCodeList(c,63977008,60800381,44508094)
	-- ①：从卡组把以下怪兽各1只加入手卡。那之后，选自己1张手卡丢弃。这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只同调怪兽为对象才能发动。那只怪兽的等级下降1星。并且再在这个回合让自己在通常召唤外加上只有1次，自己主要阶段可以把1只「同调士」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"等级下降"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 作为效果发动代价，把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
-- 定义检索条件1：在卡组中寻找卡号为63977008的「废品同调士」且能够加入手牌的卡
function s.thfilter1(c)
	return c:IsCode(63977008) and c:IsAbleToHand()
end
-- 定义检索条件2：在卡组中寻找效果文本记述有「废品战士」或「星尘龙」卡名的怪兽卡且能够加入手牌的卡
function s.thfilter2(c)
	-- 检索并判定：卡片是否为效果文本记述有「废品战士」或「星尘龙」卡名的怪兽卡且能够加入手牌
	return (aux.IsCodeListed(c,60800381) or aux.IsCodeListed(c,44508094)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索用通用过滤器：检查卡片是否是「废品同调士」或效果文本记述有「废品战士」「星尘龙」卡名的怪兽卡，且能够加入手牌
function s.thfilter(c)
	-- 检查卡片是否为「废品同调士」或者为记述有「废品战士」「星尘龙」卡名的怪兽
	return (c:IsCode(63977008) or (aux.IsCodeListed(c,60800381) or aux.IsCodeListed(c,44508094)) and c:IsType(TYPE_MONSTER))
		and c:IsAbleToHand()
end
-- 检查卡组中是否含有能够分别满足条件1与条件2的组合卡片，并设置检索2张卡片加入手牌的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 在卡组中获取所有符合基本检索条件的卡片
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		-- 检查卡组中获取到的卡片是否可以分组出各1张分别满足两个过滤条件的卡片组合
		return g:CheckSubGroup(aux.gffcheck,2,2,s.thfilter1,nil,s.thfilter2,nil)
	end
	-- 设置操作信息：将卡组中的2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从卡组检索「废品同调士」与记述有「废品战士」或「星尘龙」卡名的怪兽各1只加入手牌，之后将1张手牌送去墓地丢弃
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，从卡组获取所有符合过滤条件的卡片
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若处理时卡组中已不存在可以分别满足两条件的2张卡的组合，则不进行检索处理
	if not g:CheckSubGroup(aux.gffcheck,2,2,s.thfilter1,nil,s.thfilter2,nil) then return end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组筛选符合条件1与条件2的各1张卡片进行选择
	local tg1=g:SelectSubGroup(tp,aux.gffcheck,false,2,2,s.thfilter1,nil,s.thfilter2,nil)
	if #tg1==2 then
		-- 将选择的卡片加入玩家手牌
		Duel.SendtoHand(tg1,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tg1)
		-- 中断效果处理，使后续丢弃手牌与加入手牌的操作不同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 让玩家选择自己手牌中的任意1张卡
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
		-- 对玩家的手牌进行洗切
		Duel.ShuffleHand(tp)
		-- 以效果原因为代价将所选的1张手牌送去墓地丢弃
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 过滤条件：寻找自己场上表侧表示、等级大于1的同调怪兽
function s.lvfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:GetLevel()>1 and c:IsFaceup()
end
-- 设置效果对象并检测效果合法性：同调怪兽需表侧表示且等级在2以上，本回合未注册过此追加召唤标记，且玩家能够召唤以及能够进行通常召唤外的追加召唤
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	-- 在效果发动时，检查自己场上是否存在符合降低等级条件的同调怪兽，且本回合尚未适用过该追加召唤效果
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetFlagEffect(tp,id)==0
		-- 且玩家能够通常召唤并具有追加召唤的机会
		and Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
	end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择场上符合条件的1只表侧表示同调怪兽作为效果的对象
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使被选择的同调怪兽等级下降1星，且本回合内玩家可以额外通常召唤1只「同调士」怪兽
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取第一效果对象，即被降低等级的同调怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:GetLevel()>1
		and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的等级下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 如果玩家当前能进行追加召唤，且本回合尚未获得本卡效果的追加召唤次数，则进行追加召唤效果注册
		if Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and Duel.GetFlagEffect(tp,id)==0 then
			-- 并且再在这个回合让自己在通常召唤外加上只有1次，自己主要阶段可以把1只「同调士」怪兽召唤。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetDescription(aux.Stringid(id,2))  --"使用「同调伙伴」的效果召唤"
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
			e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
			-- 限定该追加通常召唤只能用于「同调士」系列的怪兽
			e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1017))
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 给玩家注册全局的追加通常召唤效果
			Duel.RegisterEffect(e2,tp)
			-- 注册本回合本卡效果已被适用的全局标识，防止重复获得追加召唤机会
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
