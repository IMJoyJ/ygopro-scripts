--オルフェゴール・ガラテアi
-- 效果：
-- 「自奏圣乐」怪兽或「星遗物」怪兽1只
-- 自己对「自奏圣乐·伽拉忒亚i」1回合只能有1次连接召唤。这张卡不能作为超量召唤的素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：把1张手卡送去墓地才能发动。从自己的卡组·墓地把1只「星遗物」怪兽或1张「自奏圣乐的通天塔」加入手卡。
-- ②：这张卡在墓地存在的场合，从自己墓地把1张其他的「自奏圣乐」卡除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 该函数是此卡所有效果的注册入口，依次完成连接素材规则、苏生限制、超量素材禁止、连接召唤次数限制，并将①②效果及其在“自奏圣乐的通天塔”影响下的二速版本注册给卡片。
function s.initial_effect(c)
	-- 将卡号90351981（自奏圣乐的通天塔）记录为这张卡文本中记载的卡名，供规则检索与关联判断使用。
	aux.AddCodeList(c,90351981)
	-- 设定此卡的连接召唤素材为1只满足s.matfilter的怪兽（即“自奏圣乐”怪兽或“星遗物”怪兽）。
	aux.AddLinkProcedure(c,s.matfilter,1,1)
	c:EnableReviveLimit()
	-- 这张卡不能作为超量召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 自己对「自奏圣乐·伽拉忒亚i」1回合只能有1次连接召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把1张手卡送去墓地才能发动。从自己的卡组·墓地把1只「星遗物」怪兽或1张「自奏圣乐的通天塔」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.accon1)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCondition(s.accon2)
	c:RegisterEffect(e4)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡在墓地存在的场合，从自己墓地把1张其他的「自奏圣乐」卡除外才能发动。这张卡特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"墓地特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,id+o)
	e5:SetCondition(s.accon1)
	e5:SetCost(s.spcost)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetCondition(s.accon2)
	c:RegisterEffect(e6)
end
-- 判定连接素材是否为“自奏圣乐”或“星遗物”系列的怪兽（以此决定是否符合素材要求）。
function s.matfilter(c)
	return c:IsLinkSetCard(0x11b,0xfe)
end
-- 连接召唤成功时触发条件：只有这张卡以连接召唤方式特殊召唤成功时才触发后续限制效果。
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 在此卡连接召唤成功时，给当前玩家附加一个限制效果：结束阶段前不能再以连接召唤方式特殊召唤这张卡，从而实现“自己对这张卡1回合只能有1次连接召唤”。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 对应效果原文：‘自己对「自奏圣乐·伽拉忒亚i」1回合只能有1次连接召唤。这个卡名的①②的效果1回合各能使用1次。①：把1张手卡送去墓地才能发动。从自己的卡组·墓地把1只「星遗物」怪兽或1张「自奏圣乐的通天塔」加入手卡。②：这张卡在墓地存在的场合，从自己墓地把1张其他的「自奏圣乐」卡除外才能发动。这张卡特殊召唤。’
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	-- 将上述“不能连接召唤同名卡”的限制效果注册给当前玩家，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 限制的具体条件：若试图以连接召唤方式特殊召唤这张卡（卡号id），则不允许该特殊召唤。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- 一速版本效果的发动条件：当“自奏圣乐的通天塔”没有让此卡效果变成二速时（即不满足二速化条件），才可作为通常起动效果发动。
function s.accon1(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真表示当前不能作为诱发即时效果发动，因此使用一速的①②效果。
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 二速版本效果的发动条件：当“自奏圣乐的通天塔”效果适用时，允许此卡①②效果在对方回合作为诱发即时效果发动。
function s.accon2(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真表示当前满足通天塔的二速化条件，可以使用二速的①②效果。
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- ①效果的cost：选择1张手卡送去墓地作为发动代价。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：手牌中是否存在1张可以送去墓地作为cost的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 显示‘请选择要送去墓地的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手牌选择1张卡作为cost（必须可送去墓地，且不是此卡自身）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手卡送去墓地，完成cost支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检索过滤条件：可以是“自奏圣乐的通天塔”，也可以是“星遗物”系列的怪兽，且该卡能够加入手卡。
function s.thfilter(c)
	return c:IsAbleToHand() and (c:IsCode(90351981) or (c:IsSetCard(0xfe) and c:IsType(TYPE_MONSTER)))
end
-- ①效果的发动目标：检查卡组·墓地中是否存在满足s.thfilter的卡，并登记本次操作将加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标合法性检查：卡组·墓地中至少存在1张符合条件的检索对象。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 登记操作信息：本次效果会把1张卡从卡组·墓地带回手牌（目标位置为卡组+墓地）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理：从卡组·墓地选择1张符合条件的“星遗物”怪兽或“自奏圣乐的通天塔”加入手牌，并让对手确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示‘请选择要加入手牌的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 使用王家长眠之谷过滤后的条件，从卡组·墓地选择1张符合条件的卡（若从墓地取则需不受王谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，完成检索。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的cost过滤：自己墓地的“自奏圣乐”系列卡，且可以除外作为cost。
function s.costfilter(c)
	return c:IsSetCard(0x11b) and c:IsAbleToRemoveAsCost()
end
-- ②效果的cost：从自己墓地选择1张“自奏圣乐”卡（不含自身）除外作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：自己墓地中是否存在1张可除外的“自奏圣乐”卡（排除自身后仍有）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 显示‘请选择要除外的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1张满足s.costfilter的“自奏圣乐”卡（排除此卡自身）作为除外cost。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的卡表侧除外，完成cost支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标检查：主要怪兽区有空位，且这张卡能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区的可用空格数大于0（保证有位置可供特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次效果将特殊召唤这张卡（e:GetHandler()），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若此卡仍与效果关联且墓地中的它不受王家长眠之谷等影响，则将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 特殊召唤前判定：这张卡没有因效果处理而离场/失去联系，并且不受王家长眠之谷等“不能从墓地特殊召唤”的限制。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 以表侧表示将这张卡特殊召唤到自己的主要怪兽区，完成②效果。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
