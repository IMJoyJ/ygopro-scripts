--トゥーン・ブラック・マジシャン
-- 效果：
-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
-- ②：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
-- ③：1回合1次，可以从手卡丢弃1张「卡通」卡，从以下效果选择1个发动。
-- ●从卡组把「卡通黑魔术师」以外的1只卡通怪兽无视召唤条件特殊召唤。
-- ●从卡组把1张「卡通」魔法·陷阱卡加入手卡。
function c21296502.initial_effect(c)
	-- 将「卡通世界」的卡名密码登记到这张卡的代码列表中，用于规则上视为记载该卡名。
	aux.AddCodeList(c,15259703)
	-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c21296502.atklimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c21296502.dircon)
	c:RegisterEffect(e4)
	-- ③：1回合1次，可以从手卡丢弃1张「卡通」卡，从以下效果选择1个发动。 ●从卡组把「卡通黑魔术师」以外的1只卡通怪兽无视召唤条件特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(21296502,0))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e5:SetCost(c21296502.cost)
	e5:SetTarget(c21296502.sptg)
	e5:SetOperation(c21296502.spop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetDescription(aux.Stringid(21296502,1))  --"卡组检索"
	e6:SetTarget(c21296502.thtg)
	e6:SetOperation(c21296502.thop)
	c:RegisterEffect(e6)
end
-- 在召唤、反转召唤或特殊召唤成功时，为这张卡附加不能攻击的效果，持续到结束阶段。
function c21296502.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 筛选条件：表侧表示且卡名为「卡通世界」的卡，用于确认自己场上是否有卡通世界。
function c21296502.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 筛选条件：表侧表示且为卡通怪兽的卡，用于确认对方场上是否有卡通怪兽。
function c21296502.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 直接攻击的满足条件：自己场上有「卡通世界」且对方场上没有表侧表示的卡通怪兽。
function c21296502.dircon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在表侧表示的「卡通世界」。
	return Duel.IsExistingMatchingCard(c21296502.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 同时检查对方场上不存在表侧表示的卡通怪兽。
		and not Duel.IsExistingMatchingCard(c21296502.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
-- 手卡中属于「卡通」字段且可以被丢弃的卡，作为发动代价的筛选条件。
function c21296502.costfilter(c)
	return c:IsSetCard(0x62) and c:IsDiscardable()
end
-- 发动代价处理：确认手卡有可丢弃的「卡通」卡，向对方提示效果选择，然后丢弃1张。
function c21296502.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查手卡是否存在可丢弃的「卡通」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c21296502.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向对方玩家提示自己选择发动的是哪个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 从手卡丢弃1张「卡通」卡作为发动代价。
	Duel.DiscardHand(tp,c21296502.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 卡组中属于「卡通」字段的魔法·陷阱卡且能够加入手卡的筛选条件。
function c21296502.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x62) and c:IsAbleToHand()
end
-- 检索效果发动条件：卡组存在符合条件的「卡通」魔法·陷阱卡；同时设置从卡组加入手卡的处理信息。
function c21296502.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否存在符合条件的「卡通」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c21296502.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时从卡组将1张卡加入手牌的操作信息，供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：从卡组挑选1张「卡通」魔法·陷阱卡加入手牌，并让对方确认。
function c21296502.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张符合条件的「卡通」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c21296502.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入持有者手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认被加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 可特殊召唤的卡组卡通怪兽筛选：是卡通怪兽、不是「卡通黑魔术师」、可被无视召唤条件特殊召唤。
function c21296502.spfilter(c,e,tp)
	return c:IsType(TYPE_TOON) and not c:IsCode(21296502) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤效果发动条件：自己场上存在可用的怪兽区域，且卡组存在符合条件的卡通怪兽；设置特殊召唤处理信息。
function c21296502.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在符合条件的卡通怪兽。
		and Duel.IsExistingMatchingCard(c21296502.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时从卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果处理：从卡组选择符合条件的卡通怪兽特殊召唤。
function c21296502.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己场上没有可用的怪兽区域，则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只符合条件的卡通怪兽。
	local g=Duel.SelectMatchingCard(tp,c21296502.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的卡通怪兽无视召唤条件以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
