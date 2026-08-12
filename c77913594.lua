--エクソシスター・パークス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段，支付800基本分才能发动。从卡组把「救祓少女和平问候」以外的1张「救祓少女」卡加入手卡。这个效果把怪兽加入手卡，有在那只怪兽有卡名记述的「救祓少女」怪兽在自己的场上或墓地存在的场合，可以再把加入手卡的那只怪兽特殊召唤。
function c77913594.initial_effect(c)
	-- ①：自己·对方的主要阶段，支付800基本分才能发动。从卡组把「救祓少女和平问候」以外的1张「救祓少女」卡加入手卡。这个效果把怪兽加入手卡，有在那只怪兽有卡名记述的「救祓少女」怪兽在自己的场上或墓地存在的场合，可以再把加入手卡的那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77913594,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,77913594+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(c77913594.condition)
	e1:SetCost(c77913594.cost)
	e1:SetTarget(c77913594.target)
	e1:SetOperation(c77913594.operation)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，限制在双方的主要阶段发动
function c77913594.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 定义发动代价函数，需要支付800点基本分
function c77913594.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查玩家是否能够支付800点基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 扣除玩家800点基本分作为发动的代价
	Duel.PayLPCost(tp,800)
end
-- 过滤卡组中「救祓少女和平问候」以外的「救祓少女」卡片
function c77913594.thfilter(c)
	return c:IsSetCard(0x172) and not c:IsCode(77913594) and c:IsAbleToHand()
end
-- 定义效果的目标检查与连锁信息设置函数
function c77913594.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查卡组中是否存在可检索的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c77913594.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表明此效果包含从卡组将卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤场上或墓地中，卡名被检索怪兽所记述的「救祓少女」怪兽
function c77913594.spfilter(c,sc)
	-- 检查卡片是否为「救祓少女」怪兽，且其卡号被检索怪兽的效果文本所记述
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x172) and aux.IsCodeListed(sc,c:GetCode())
		and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 定义效果处理函数，执行检索及后续的特殊召唤处理
function c77913594.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足检索条件的「救祓少女」卡片
	local tc=Duel.SelectMatchingCard(tp,c77913594.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	local res=false
	-- 将选中的卡片加入手牌，并确认该卡已成功送达手牌
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
		res=true
	end
	-- 检查是否成功检索，且自己场上是否有空余的怪兽区域
	if res and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsType(TYPE_MONSTER) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己的场上或墓地是否存在该检索怪兽卡名记述的「救祓少女」怪兽
		and Duel.IsExistingMatchingCard(c77913594.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tc)
		-- 询问玩家是否选择将加入手牌的那只怪兽特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(77913594,1)) then  --"是否特殊召唤？"
		-- 中断当前效果处理，使后续的特殊召唤与加入手牌不视为同时处理
		Duel.BreakEffect()
		-- 将加入手牌的那只怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
