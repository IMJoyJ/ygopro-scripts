--発条補修ゼンマイコン
-- 效果：
-- 「发条」怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「发条」卡加入手卡。
-- ②：把自己场上1只表侧表示的「发条」怪兽里侧表示除外才能发动。把1只和那只是同名的怪兽从卡组特殊召唤。
-- ③：这张卡被破坏送去墓地的场合，以自己场上1只「发条」超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。
function c1735088.initial_effect(c)
	-- 为这张卡添加连接召唤手续：使用2只「发条」怪兽作为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x58),2,2)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡连接召唤成功的场合才能发动。从卡组把1张「发条」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1735088,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,1735088)
	e1:SetCondition(c1735088.thcon)
	e1:SetTarget(c1735088.thtg)
	e1:SetOperation(c1735088.thop)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只表侧表示的「发条」怪兽里侧表示除外才能发动。把1只和那只是同名的怪兽从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1735088,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,1735089)
	e2:SetCost(c1735088.spcost)
	e2:SetTarget(c1735088.sptg)
	e2:SetOperation(c1735088.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏送去墓地的场合，以自己场上1只「发条」超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1735088,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c1735088.matcon)
	e3:SetTarget(c1735088.mattg)
	e3:SetOperation(c1735088.matop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：这张卡以连接召唤方式特殊召唤成功时才能发动。
function c1735088.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 定义效果①检索卡的过滤条件：必须是「发条」字段的卡，且能被加入手卡。
function c1735088.thfilter(c)
	return c:IsSetCard(0x58) and c:IsAbleToHand()
end
-- 效果①的发动时处理：检查卡组是否存在符合条件的「发条」卡，并设置将1张卡加入手卡的操作信息。
function c1735088.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：确认卡组中存在至少1张满足条件的「发条」卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c1735088.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要从卡组将1张卡加入手卡的操作信息（用于连锁判定等）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理时：从卡组选1张「发条」卡加入手卡，并让对方确认。
function c1735088.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示当前玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的「发条」卡。
	local g=Duel.SelectMatchingCard(tp,c1735088.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡（因为从卡组检索，需要公开）。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的代价函数：仅设置标签标记，实际代价检查和支付在目标选择阶段完成。
function c1735088.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 选择要除外的「发条」怪兽的过滤条件：表侧表示、「发条」字段、可作为里侧表示除外代价，且除外后自己有怪兽区空位，同时卡组中存在同名可特殊召唤的怪兽。
function c1735088.cfilter(c,e,tp)
	-- 被选为代价的怪兽必须是表侧表示的「发条」怪兽，可被里侧表示除外，且除外后自己场上仍有可用怪兽区域。
	return c:IsFaceup() and c:IsSetCard(0x58) and c:IsAbleToRemoveAsCost(POS_FACEDOWN) and Duel.GetMZoneCount(tp,c)>0
		-- 还要求卡组中存在与候选怪兽同名的、可以特殊召唤的怪兽，以保证代价支付后效果能够处理。
		and Duel.IsExistingMatchingCard(c1735088.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 定义卡组中要特殊召唤的怪兽的条件：卡名与除外的怪兽相同，且可以被当前效果特殊召唤。
function c1735088.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动时/选择时处理：确认代价条件后，选择自己场上1只表侧表示的「发条」怪兽里侧表示除外，记录其卡名，并设置从卡组特殊召唤同名怪兽的操作信息。
function c1735088.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 合法性检查：确认自己场上存在满足代价条件的「发条」怪兽（且卡组中存在同名可特殊召唤的怪兽）。
		return Duel.IsExistingMatchingCard(c1735088.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 提示当前玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的「发条」怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c1735088.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetCode())
	-- 将选择的怪兽里侧表示除外，作为效果的代价。
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	-- 设置效果处理时从卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②处理时：确认己方怪兽区域有空位后，从卡组选择1只与除外怪兽同名的怪兽表侧表示特殊召唤。
function c1735088.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前检查：自己场上必须有可用的怪兽区域，否则特殊召唤处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示当前玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件（与除外怪兽同名且可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c1735088.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的发动条件：这张卡被破坏并送去墓地时才能发动。
function c1735088.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 效果③选择对象的过滤条件：自己场上的表侧表示「发条」超量怪兽。
function c1735088.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x58) and c:IsType(TYPE_XYZ)
end
-- 效果③的发动时处理：取自己场上1只表侧表示「发条」超量怪兽为对象，并确认这张卡可以作为超量素材叠放。
function c1735088.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c1735088.matfilter(chkc) end
	-- 合法性检查：自己场上存在可作为对象的表侧表示「发条」超量怪兽，并且这张卡可以作为超量素材。
	if chk==0 then return Duel.IsExistingTarget(c1735088.matfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 提示当前玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只符合条件的「发条」超量怪兽作为效果对象。
	Duel.SelectTarget(tp,c1735088.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表明这张卡将离开墓地（用于给超量怪兽叠放）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果③处理时：若这张卡仍在墓地且与效果关联，对象怪兽仍在场上且不免疫此效果，则将这张卡叠放在对象超量怪兽下面作为超量素材。
function c1735088.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果③选择的对象超量怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 把墓地的这张卡叠放在对象超量怪兽下面作为超量素材。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
