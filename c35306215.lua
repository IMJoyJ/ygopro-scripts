--失楽の堕天使
-- 效果：
-- 天使族怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己作需要怪兽2只解放的天使族怪兽的上级召唤的场合，可以不把怪兽2只解放而从自己墓地把2只怪兽除外来上级召唤。
-- ②：丢弃1张手卡才能发动。从卡组选1只「堕天使」怪兽加入手卡或送去墓地。
-- ③：自己结束阶段发动。自己回复场上的天使族怪兽数量×500基本分。
function c35306215.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「失乐之堕天使」添加连接召唤手续，要求用2只天使族怪兽作为连接素材（对应卡名下方“天使族怪兽2只”的召唤条件）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_FAIRY),2,2)
	-- ①：只要这张卡在怪兽区域存在，自己作需要怪兽2只解放的天使族怪兽的上级召唤的场合，可以不把怪兽2只解放而从自己墓地把2只怪兽除外来上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35306215,0))  --"把墓地2只怪兽除外上级召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c35306215.otcon)
	e1:SetTarget(c35306215.ottg)
	e1:SetOperation(c35306215.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e4)
	-- 这个卡名的②的效果1回合只能使用1次。②：丢弃1张手卡才能发动。从卡组选1只「堕天使」怪兽加入手卡或送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35306215,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,35306215)
	e2:SetCost(c35306215.thcost)
	e2:SetTarget(c35306215.thtg)
	e2:SetOperation(c35306215.thop)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段发动。自己回复场上的天使族怪兽数量×500基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35306215,2))  --"回复基本分"
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c35306215.reccon)
	e3:SetTarget(c35306215.rectg)
	e3:SetOperation(c35306215.recop)
	c:RegisterEffect(e3)
end
-- 筛选可作为cost除外的怪兽：该卡必须是怪兽且可以被除外作为cost，用于从墓地选作代替解放的素材。
function c35306215.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 该上级召唤手续的条件：所需解放数不超过2、自己主要怪兽区有空位、且墓地存在至少2只可除外的怪兽。
function c35306215.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认这次上级召唤要求的解放数量不超过2，并且自己场上有空余的主要怪兽区可供召唤怪兽出场。
	return minc<=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 额外要求自己墓地存在至少2只满足rmfilter的怪兽，保证能除外2只来代替解放。
		and Duel.IsExistingMatchingCard(c35306215.rmfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 限定可适用的上级召唤对象：该怪兽原本需要2只解放（解放要求最低2且最高至少2），并且种族为天使族。
function c35306215.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=2 and ma>=2 and c:IsRace(RACE_FAIRY)
end
-- 执行代替解放的上级召唤操作：提示玩家从自己墓地选择2只怪兽表侧除外作为cost，从而代替2只解放；召唤后清空素材记录。
function c35306215.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 弹出选择提示，要求玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择2张满足rmfilter的怪兽卡作为除外的对象。
	local g=Duel.SelectMatchingCard(tp,c35306215.rmfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的2张怪兽卡表侧表示除外，除外原因是作为上级召唤手续的cost。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	c:SetMaterial(nil)
end
-- ②效果的发动代价：丢弃1张手卡才能发动；先检查手牌中是否有可丢弃的卡，实际丢弃1张作为cost。
function c35306215.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果cost检查：自己手牌中是否存在至少1张可丢弃的卡（满足Card.IsDiscardable）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际从手牌丢弃1张卡，作为发动cost，丢弃原因标记为COST和DISCARD。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选卡组中属于「堕天使」字段的怪兽，并且该怪兽可选择加入手牌或送去墓地（至少有一种可行）。
function c35306215.thfilter(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- ②效果发动时的合法性检查与操作信息登记：卡组有符合条件的「堕天使」怪兽；因可能回手牌也可能送墓地，所以同时登记两类操作信息。
function c35306215.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中是否存在至少1张满足thfilter的「堕天使」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c35306215.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记效果将处理“从卡组把卡加入手牌”的操作信息（不取对象，预计处理1张）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 登记效果将处理“从卡组把卡送去墓地”的操作信息（不取对象，预计处理1张）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只符合条件的「堕天使」怪兽，若选择加入手牌则加入手牌并让对方确认，否则送去墓地；两种都可行时由玩家选择。
function c35306215.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1张满足thfilter的「堕天使」怪兽。
	local g=Duel.SelectMatchingCard(tp,c35306215.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 判断选中的卡能否加入手牌，以及是否选择加入手牌：若该卡不能送去墓地，或玩家在“加入手牌/送去墓地”中选择加入手牌，则执行加入手牌；否则送去墓地。
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将选中的「堕天使」怪兽加入其持有者的手牌，处理原因为效果。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 让对方玩家确认被加入手牌的卡片。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的「堕天使」怪兽送去墓地，处理原因为效果。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- ③效果的发动条件：必须是在自己的结束阶段，即当前回合玩家是自己。
function c35306215.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，从而确定现在是自己的结束阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 筛选场上的表侧表示天使族怪兽，用于计算回复数值。
function c35306215.recfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY)
end
-- ③效果发动时选定回复对象并登记操作信息：计算自己场上表侧天使族怪兽数量×500的数值，将回复对象设为自己，并登记回复效果。
function c35306215.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算自己场上表侧表示天使族怪兽数量乘以500，作为回复基本分的数值。
	local rec=Duel.GetMatchingGroupCount(c35306215.recfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*500
	-- 将回复效果的对象玩家设为自己。
	Duel.SetTargetPlayer(tp)
	-- 将计算出的回复数值作为连锁对象参数保存，供处理时使用。
	Duel.SetTargetParam(rec)
	-- 登记效果将处理回复基本分的操作信息，数值为rec。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- ③效果处理：重新计算场上的天使族数量×500，获取之前记录的回复对象玩家，并执行基本分回复。
function c35306215.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新计算回复数值，避免发动后场上的天使族数量发生变化导致数值过时。
	local rec=Duel.GetMatchingGroupCount(c35306215.recfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*500
	-- 从当前连锁信息中取出之前设置的对象玩家（即自己）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 为对象玩家p回复rec点基本分，回复原因为效果。
	Duel.Recover(p,rec,REASON_EFFECT)
end
