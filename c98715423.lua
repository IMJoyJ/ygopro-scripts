--墓守の罠
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己墓地有「现世与冥界的逆转」存在，对方不能把墓地的卡的效果发动，不能把墓地的怪兽特殊召唤。
-- ②：双方的主要阶段，丢弃1张手卡才能发动。从卡组把1只「守墓」怪兽或者天使族·地属性怪兽加入手卡。
-- ③：这张卡表侧表示存在的场合，对方抽卡阶段的抽卡前，宣言1个卡名发动。把通常抽卡的卡确认，宣言的卡的场合，送去墓地。
function c98715423.initial_effect(c)
	-- 记录这张卡记有「现世与冥界的逆转」的卡名。
	aux.AddCodeList(c,17484499)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要自己墓地有「现世与冥界的逆转」存在，对方不能把墓地的卡的效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c98715423.actcon)
	e1:SetValue(c98715423.aclimit)
	c:RegisterEffect(e1)
	-- ①：只要自己墓地有「现世与冥界的逆转」存在，对方不能把墓地的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c98715423.actcon)
	e2:SetTarget(c98715423.sumlimit)
	c:RegisterEffect(e2)
	-- ②：双方的主要阶段，丢弃1张手卡才能发动。从卡组把1只「守墓」怪兽或者天使族·地属性怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,98715423)
	e3:SetCondition(c98715423.thcon)
	e3:SetCost(c98715423.thcost)
	e3:SetTarget(c98715423.thtg)
	e3:SetOperation(c98715423.thop)
	c:RegisterEffect(e3)
	-- ③：这张卡表侧表示存在的场合，对方抽卡阶段的抽卡前，宣言1个卡名发动。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ANNOUNCE+CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PREDRAW)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,98715424)
	e4:SetCondition(c98715423.cfcon)
	e4:SetTarget(c98715423.cftg)
	e4:SetOperation(c98715423.cfop)
	c:RegisterEffect(e4)
end
-- 永续效果的适用条件：自己墓地存在「现世与冥界的逆转」。
function c98715423.actcon(e)
	-- 检查自己墓地是否存在卡名为「现世与冥界的逆转」的卡。
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,17484499)
end
-- 限制对方发动的效果：发动地点在墓地的效果。
function c98715423.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE
end
-- 限制对方特殊召唤的怪兽：从墓地特殊召唤的怪兽。
function c98715423.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)
end
-- 检索效果的发动条件：双方的主要阶段。
function c98715423.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 检索效果的发动代价：丢弃1张手卡。
function c98715423.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡作为发动代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索卡片的过滤条件：卡组中的「守墓」怪兽或者地属性·天使族怪兽。
function c98715423.thfilter(c)
	return (c:IsSetCard(0x2e) and c:IsType(TYPE_MONSTER) or c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_EARTH))
		and c:IsAbleToHand()
end
-- 检索效果的发动准备：检查卡组中是否存在符合条件的卡，并设置检索的操作信息。
function c98715423.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在符合检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c98715423.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的1张卡加入手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：从卡组选择1张符合条件的卡加入手牌并给对方确认。
function c98715423.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合检索条件的卡。
	local g=Duel.SelectMatchingCard(tp,c98715423.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 宣言效果的发动条件：对方抽卡阶段的抽卡前，且对方卡组有卡、有通常抽卡机会，且此卡在场上表侧表示存在。
function c98715423.cfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合，且对方卡组中存在卡片。
	return Duel.GetTurnPlayer()==1-tp and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0
		-- 检查对方是否有通常抽卡机会，且此卡处于已成功发动的状态。
		and Duel.GetDrawCount(1-tp)>0 and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 宣言效果的发动准备：让玩家宣言一个卡名（排除额外卡组怪兽类型），并保存宣言的卡名。
function c98715423.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家宣言一个卡名。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让玩家宣言一个卡名（过滤掉融合、同调、超量、连接怪兽）。
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡名保存为效果的目标参数。
	Duel.SetTargetParam(ac)
	-- 设置宣言卡名的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 宣言效果的处理：获取宣言的卡名，并注册一个在抽卡时触发的单回合时效的延迟效果。
function c98715423.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前宣言并保存的卡名。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- ③：把通常抽卡的卡确认，宣言的卡的场合，送去墓地。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetLabel(ac)
	e1:SetOperation(c98715423.disop)
	e1:SetReset(RESET_PHASE+PHASE_DRAW)
	-- 注册该抽卡确认与送墓的延迟效果。
	Duel.RegisterEffect(e1,tp)
end
-- 抽卡确认与送墓的具体处理：确认通常抽卡的卡，如果是宣言的卡则送去墓地，最后洗切手牌。
function c98715423.disop(e,tp,eg,ep,ev,re,r,rp)
	if r~=REASON_RULE then return end
	-- 确认对方抽到的卡。
	Duel.ConfirmCards(tp,eg)
	local g=eg:Filter(Card.IsCode,nil,e:GetLabel())
	-- 将抽到的卡中与宣言卡名相同的卡送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
	-- 洗切对方的手牌。
	Duel.ShuffleHand(1-tp)
end
