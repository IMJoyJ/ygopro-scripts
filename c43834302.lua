--シンクロ・フェローズ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把以下怪兽各1只加入手卡。那之后，选自己1张手卡丢弃。
-- ●「废品同调士」
-- ●有「废品战士」「星尘龙」其中任意种的卡名记述的怪兽
-- ②：把墓地的这张卡除外，以自己场上1只同调怪兽为对象才能发动。那只怪兽的等级下降1星。并且再在这个回合让自己在通常召唤外加上只有1次，自己主要阶段可以把1只「同调士」怪兽召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个效果：①检索效果和②等级下降效果
function s.initial_effect(c)
	-- 为该卡添加允许作为融合/仪式召唤素材的卡牌代码列表，包括废品同调士、废品战士和星尘龙
	aux.AddMaterialCodeList(c,63977008,60800381,44508094)
	-- ①：从卡组把以下怪兽各1只加入手卡。那之后，选自己1张手卡丢弃。
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
	-- 将此卡除外作为发动②效果的费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
-- 定义检索过滤器1：筛选卡号为废品同调士的怪兽
function s.thfilter1(c)
	return c:IsCode(63977008) and c:IsAbleToHand()
end
-- 定义检索过滤器2：筛选卡名记载有废品战士或星尘龙的怪兽
function s.thfilter2(c)
	-- 判断卡名是否记载有废品战士或星尘龙
	return (aux.IsCodeListed(c,60800381) or aux.IsCodeListed(c,44508094)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义综合检索过滤器：筛选卡号为废品同调士或记载有废品战士或星尘龙的怪兽
function s.thfilter(c)
	-- 判断卡号是否为废品同调士或卡名记载有废品战士或星尘龙
	return (c:IsCode(63977008) or (aux.IsCodeListed(c,60800381) or aux.IsCodeListed(c,44508094)) and c:IsType(TYPE_MONSTER))
		and c:IsAbleToHand()
end
-- ①效果的发动条件判断：检查卡组中是否存在满足条件的2张卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有满足检索条件的卡
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		-- 检查是否存在满足条件的2张卡组合（一张为废品同调士，一张为废品战士或星尘龙）
		return g:CheckSubGroup(aux.gffcheck,2,2,s.thfilter1,nil,s.thfilter2,nil)
	end
	-- 设置连锁操作信息，表示将从卡组检索2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- ①效果的发动处理：检索满足条件的2张卡并丢弃1张手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足检索条件的卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若无法找到满足条件的2张卡组合则返回
	if not g:CheckSubGroup(aux.gffcheck,2,2,s.thfilter1,nil,s.thfilter2,nil) then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的2张卡
	local tg1=g:SelectSubGroup(tp,aux.gffcheck,false,2,2,s.thfilter1,nil,s.thfilter2,nil)
	if #tg1==2 then
		-- 将选中的2张卡加入手牌
		Duel.SendtoHand(tg1,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tg1)
		-- 中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 选择1张手牌进行丢弃
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
		-- 洗切玩家手牌
		Duel.ShuffleHand(tp)
		-- 将选中的手牌送去墓地
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 定义等级下降效果的目标过滤器：筛选场上1只等级大于1的同调怪兽
function s.lvfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:GetLevel()>1 and c:IsFaceup()
end
-- ②效果的发动条件判断：检查场上是否存在满足条件的同调怪兽且玩家未使用过此效果
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	-- 检查场上是否存在满足条件的同调怪兽
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetFlagEffect(tp,id)==0
		-- 检查玩家是否可以通常召唤和额外召唤
		and Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
	end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只满足条件的同调怪兽作为对象
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的发动处理：使目标怪兽等级下降1星并获得额外召唤次数
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:GetLevel()>1
		and not tc:IsImmuneToEffect(e) then
		-- 使目标怪兽等级下降1星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 检查玩家是否可以通常召唤和额外召唤且未使用过此效果
		if Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and Duel.GetFlagEffect(tp,id)==0 then
			-- 为玩家注册额外召唤次数效果，使其在本回合可以额外召唤1只「同调士」怪兽
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetDescription(aux.Stringid(id,2))  --"使用「同调伙伴」的效果召唤"
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
			e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
			-- 设置额外召唤次数效果的目标为手牌和场上的「同调士」怪兽
			e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1017))
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 注册额外召唤次数效果
			Duel.RegisterEffect(e2,tp)
			-- 为玩家注册标识效果，防止此效果在本回合再次发动
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
