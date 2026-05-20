--メメント・ボーン・パーティー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的手卡·场上（表侧表示）1只「莫忘」怪兽破坏，从卡组选和那只怪兽卡名不同的1只「莫忘」怪兽加入手卡或守备表示特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只「莫忘」怪兽为对象才能发动。这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（卡片发动）和②效果（墓地起动）的注册。
function s.initial_effect(c)
	-- ①：自己的手卡·场上（表侧表示）1只「莫忘」怪兽破坏，从卡组选和那只怪兽卡名不同的1只「莫忘」怪兽加入手卡或守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只「莫忘」怪兽为对象才能发动。这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置②效果的发动条件为：当前处于可以进行战斗相关操作的时点或阶段（主要阶段）。
	e2:SetCondition(aux.bpcon)
	-- 设置②效果的Cost为：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.prctg)
	e2:SetOperation(s.prcop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选手卡·场上表侧表示的、破坏后能从卡组将不同名「莫忘」怪兽加入手卡或特殊召唤的「莫忘」怪兽。
function s.dfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1a1)
		-- 检查卡组中是否存在至少1只满足过滤条件（与被破坏怪兽不同名、可检索或可特召）的「莫忘」怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 过滤函数：筛选卡组中与被破坏怪兽卡名不同，且可以加入手卡或在怪兽区域守备表示特殊召唤的「莫忘」怪兽。
function s.filter(c,e,tp,tc)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_MONSTER) and not c:IsCode(tc:GetCode()) and (c:IsAbleToHand()
		-- 或者在被破坏怪兽离开场上后有可用怪兽区域，且该卡可以以表侧守备表示特殊召唤。
		or Duel.GetMZoneCount(tp,tc)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE))
end
-- ①效果的发动准备（Target）函数，检查是否存在可破坏的怪兽并设置破坏操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上（表侧表示）是否存在满足破坏及后续处理条件的「莫忘」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	-- 设置操作信息：在手卡或场上破坏1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end
-- ①效果的效果处理（Operation）函数，执行破坏并从卡组选卡加入手卡或特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1只手卡或场上（表侧表示）的「莫忘」怪兽。
	local dc=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	-- 若未选到卡或破坏失败，则效果处理终止。
	if dc==nil or Duel.Destroy(dc,REASON_EFFECT)<1 then return end
	-- 提示玩家选择要操作（加入手卡或特殊召唤）的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 玩家从卡组选择1只与被破坏怪兽卡名不同的「莫忘」怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,dc):GetFirst()
	if tc then
		-- 让玩家在“加入手卡”和“守备表示特殊召唤”（需有可用怪兽区域）之间选择一项操作。
		local op=aux.SelectFromOptions(tp,{tc:IsAbleToHand(),1190},{Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE),1152})
		if op==1 then
			-- 将选中的怪兽加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的怪兽。
			Duel.ConfirmCards(1-tp,tc)
		-- 否则，将选中的怪兽以表侧守备表示特殊召唤。
		else Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) end
	end
end
-- 过滤函数：筛选场上表侧表示的「莫忘」怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a1)
end
-- ②效果的发动准备（Target）函数，选择自己场上1只表侧表示的「莫忘」怪兽作为对象。
function s.prctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的表侧表示「莫忘」怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择自己场上1只表侧表示的「莫忘」怪兽作为效果对象。
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的效果处理（Operation）函数，赋予目标怪兽贯通伤害效果。
function s.prcop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的效果目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
