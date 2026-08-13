--百鬼羅刹 特攻ダグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。场上1个超量素材取除，这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「哥布林骑手」魔法·陷阱卡加入手卡。
function c24079759.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在的场合才能发动。场上1个超量素材取除，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24079759,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,24079759)
	e1:SetTarget(c24079759.sptg)
	e1:SetOperation(c24079759.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「哥布林骑手」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24079759,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,24079759+1)
	e2:SetTarget(c24079759.thtg)
	e2:SetOperation(c24079759.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 目标判定：确认自己场上存在可去除的超量素材、自己主要怪兽区有空位且这张卡能够被特殊召唤，以此判断效果能否发动。
function c24079759.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上（我方与对方）是否存在至少1个可因效果去除的超量素材，且自己主要怪兽区有空位。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息：将这张卡作为特殊召唤的对象，数量为1，为后续特殊召唤相关检测做准备。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理效果：去除场上1个超量素材，若去除成功且这张卡仍与效果关联，则将这张卡以表侧表示特殊召唤。
function c24079759.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 实际去除场上1个超量素材（双方各算1区域），并确认这张卡仍然存在于合法区域且与效果有联系。
	if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到其持有者的主要怪兽区（不检查召唤条件、不检查苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义检索过滤条件：该卡必须是卡名含有「哥布林骑手」的魔法·陷阱卡，并且能够加入手卡。
function c24079759.thfilter(c)
	return c:IsSetCard(0x10ac) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 目标判定：检查卡组中是否存在符合条件的「哥布林骑手」魔法·陷阱卡，存在则设置从卡组将1张卡加入手卡的操作信息。
function c24079759.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方的卡组中是否存在至少1张满足thfilter条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c24079759.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：不指定具体卡片，从卡组将1张卡加入持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果：提示玩家从卡组选择1张符合条件的「哥布林骑手」魔法·陷阱卡，将其加入手卡，并让对手确认。
function c24079759.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家发出选择提示消息，要求其选择1张要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组中选择1张满足thfilter条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c24079759.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选卡片加入其持有者的手卡（REASON_EFFECT表示因效果加入手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的这张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
