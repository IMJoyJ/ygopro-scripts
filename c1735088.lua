--発条補修ゼンマイコン
-- 效果：
-- 「发条」怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「发条」卡加入手卡。
-- ②：把自己场上1只表侧表示的「发条」怪兽里侧表示除外才能发动。把1只和那只是同名的怪兽从卡组特殊召唤。
-- ③：这张卡被破坏送去墓地的场合，以自己场上1只「发条」超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。
function c1735088.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2只以上满足过滤条件的「发条」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x58),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「发条」卡加入手卡。
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
-- 效果条件：判断此卡是否为连接召唤方式特殊召唤成功
function c1735088.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤器：筛选出卡组中满足「发条」属性且能加入手牌的卡
function c1735088.thfilter(c)
	return c:IsSetCard(0x58) and c:IsAbleToHand()
end
-- 效果目标设置：检查场上是否存在满足条件的「发条」卡，若存在则设置将卡加入手牌的操作信息
function c1735088.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查场上是否存在满足条件的「发条」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1735088.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：设置将1张卡从卡组加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：提示玩家选择一张卡加入手牌，并将该卡送入手牌，同时确认对方看到该卡
function c1735088.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择：提示玩家选择一张卡加入手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择卡组中的卡：从卡组中选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c1735088.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡送入手牌：将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认卡牌：向对方确认所选卡牌
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果费用：设置标签为100，表示可以发动此效果
function c1735088.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 特殊召唤费用过滤器：筛选出满足条件的「发条」怪兽，包括其能被除外、能特殊召唤同名卡等条件
function c1735088.cfilter(c,e,tp)
	-- 条件判断：判断怪兽是否为表侧表示、是否为「发条」属性、是否能被除外
	return c:IsFaceup() and c:IsSetCard(0x58) and c:IsAbleToRemoveAsCost(POS_FACEDOWN) and Duel.GetMZoneCount(tp,c)>0
		-- 条件判断：判断是否卡组中存在与所选怪兽同名的卡
		and Duel.IsExistingMatchingCard(c1735088.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 特殊召唤过滤器：筛选出满足条件的同名卡，可被特殊召唤
function c1735088.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标设置：检查是否满足发动条件，若满足则提示玩家选择要除外的怪兽，并设置特殊召唤操作信息
function c1735088.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 条件判断：检查场上是否存在满足条件的「发条」怪兽
		return Duel.IsExistingMatchingCard(c1735088.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 提示选择：提示玩家选择一张怪兽除外
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择怪兽除外：从场上选择一张满足条件的怪兽除外
	local g=Duel.SelectMatchingCard(tp,c1735088.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetCode())
	-- 将怪兽除外：将选中的怪兽以除外形式移除
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	-- 设置操作信息：设置将1张卡从卡组特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：提示玩家选择一张卡特殊召唤，并将该卡特殊召唤
function c1735088.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：检查场上是否有足够的怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择：提示玩家选择一张卡特殊召唤
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择卡组中的卡：从卡组中选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c1735088.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		-- 特殊召唤卡牌：将选中的卡以特殊召唤方式召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果条件：判断此卡是否因破坏而进入墓地
function c1735088.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 叠放过滤器：筛选出满足条件的「发条」超量怪兽
function c1735088.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x58) and c:IsType(TYPE_XYZ)
end
-- 效果目标设置：检查场上是否存在满足条件的「发条」超量怪兽，并判断此卡是否能叠放
function c1735088.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c1735088.matfilter(chkc) end
	-- 条件判断：检查场上是否存在满足条件的「发条」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c1735088.matfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 提示选择：提示玩家选择一张怪兽作为效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽：从场上选择一张满足条件的怪兽作为目标
	Duel.SelectTarget(tp,c1735088.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：设置将此卡从墓地叠放的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡叠放到目标怪兽下方作为超量素材
function c1735088.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取目标怪兽：获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 叠放卡牌：将此卡叠放到目标怪兽下方
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
