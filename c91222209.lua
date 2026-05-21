--R－ACEイントルーダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「救援ACE队」陷阱卡加入手卡。
-- ②：对方把场上的怪兽的效果发动时，把手卡·场上的这张卡解放，以「救援ACE队 双脉冲炮灭火员」以外的自己墓地1只「救援ACE队」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①召唤·特殊召唤成功时检索「救援ACE队」陷阱卡；②对方场上怪兽发动效果时解放自身特召墓地「救援ACE队」怪兽。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「救援ACE队」陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：对方把场上的怪兽的效果发动时，把手卡·场上的这张卡解放，以「救援ACE队 双脉冲炮灭火员」以外的自己墓地1只「救援ACE队」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组中属于「救援ACE队」且是陷阱卡、能加入手牌的卡。
function s.thfilter(c)
	return c:IsSetCard(0x18b) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- ①号效果的发动准备（检查卡组是否存在符合条件的卡，并设置检索的操作信息）。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「救援ACE队」陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的处理（从卡组选择1张「救援ACE队」陷阱卡加入手牌并给对方确认）。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「救援ACE队」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②号效果的发动条件：对方发动了场上的怪兽的效果。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end
-- ②号效果的发动代价（检查自身是否能解放、怪兽区域是否有空位，并解放自身）。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查此卡是否能被解放，且解放此卡后是否有可用的怪兽区域。
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 解放此卡作为发动的代价。
	Duel.Release(c,REASON_COST)
end
-- 过滤条件：自己墓地中「救援ACE队 双脉冲炮灭火员」以外的、可以特殊召唤的「救援ACE队」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x18b) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②号效果的发动准备（选择墓地中的目标怪兽，并设置特殊召唤的操作信息）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	-- 检查自己墓地是否存在至少1只满足过滤条件的「救援ACE队」怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足过滤条件的「救援ACE队」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将选中的对象怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②号效果的处理（将选中的墓地怪兽特殊召唤到场上）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，且不受「王家长眠之谷」的影响。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
