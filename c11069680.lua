--ジャンク・コンバーター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡和1只调整丢弃才能发动。从卡组把1只「同调士」怪兽加入手卡。
-- ②：这张卡作为同调素材送去墓地的场合，以自己墓地1只调整为对象才能发动。那只怪兽守备表示特殊召唤。这个回合，这个效果特殊召唤的怪兽的效果不能发动。
function c11069680.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从手卡把这张卡和1只调整丢弃才能发动。从卡组把1只「同调士」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11069680,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,11069680)
	e1:SetCost(c11069680.thcost)
	e1:SetTarget(c11069680.thtg)
	e1:SetOperation(c11069680.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为同调素材送去墓地的场合，以自己墓地1只调整为对象才能发动。那只怪兽守备表示特殊召唤。这个回合，这个效果特殊召唤的怪兽的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11069680,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11069681)
	e2:SetCondition(c11069680.spcon)
	e2:SetTarget(c11069680.sptg)
	e2:SetOperation(c11069680.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断一张卡是否是调整且可以被丢弃，用于选择从手牌丢弃的调整怪兽。
function c11069680.dfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsDiscardable()
end
-- 代价检查阶段：确认这张卡本身可以丢弃，并且手牌中存在其他可丢弃的调整怪兽，以满足①的发动代价。
function c11069680.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		-- 追加判断：手牌中是否存在1只满足dfilter条件（调整且可丢弃）的调整怪兽，且不能选择这张卡自身。
		and Duel.IsExistingMatchingCard(c11069680.dfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 向玩家显示选择丢弃手牌的提示消息（HINTMSG_DISCARD）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌选择1只可丢弃的调整怪兽（不包含这张卡自身）作为发动①的代价。
	local g=Duel.SelectMatchingCard(tp,c11069680.dfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选择的调整怪兽和这张卡自身作为代价丢弃（REASON_COST+REASON_DISCARD）送入墓地。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：判断卡组中的卡是否为「同调士」怪兽（SetCard 0x1017）、怪兽卡且可以加入手牌，用于检索。
function c11069680.thfilter(c)
	return c:IsSetCard(0x1017) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①的发动目标检查：确认卡组中存在可检索的「同调士」怪兽，并设置“从卡组加入手牌”的操作信息。
function c11069680.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足thfilter条件的「同调士」怪兽，若不存在则无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c11069680.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统通告本次效果将把1张卡从卡组加入手牌（CATEGORY_TOHAND，处理位置为卡组），用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选1只「同调士」怪兽加入手牌，并向对方展示，完成检索。
function c11069680.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择要加入手牌的卡的提示消息（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足thfilter条件的「同调士」怪兽。
	local g=Duel.SelectMatchingCard(tp,c11069680.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者的手牌（REASON_EFFECT，效果处理）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对方玩家确认，保证信息透明。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②的发动条件：这张卡作为同调素材被使用并已送去墓地，且送入墓地的原因为同调召唤（REASON_SYNCHRO）。
function c11069680.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤函数：判断墓地中的卡是否为调整，并且能否以表侧守备表示被当前效果特殊召唤。
function c11069680.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②的目标选择与发动检查：需要自己场上存在可用的怪兽区域，且墓地存在1只可特殊召唤的调整作为取对象目标。
function c11069680.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c11069680.spfilter(chkc,e,tp) end
	-- 检查自己场上的主要怪兽区是否有空位（墓地特殊召唤必须要有可用区域）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在1只满足spfilter条件的调整怪兽，可以作为效果对象。
		and Duel.IsExistingTarget(c11069680.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择要特殊召唤的卡的提示消息（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只可特殊召唤的调整怪兽作为效果对象（取对象效果）。
	local g=Duel.SelectTarget(tp,c11069680.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向系统通告本次效果将以确定的1个对象进行特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将对象怪兽以表侧守备表示特殊召唤，并对其附加“这个回合效果不能发动”的无效化效果。
function c11069680.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的墓地调整怪兽（对象卡）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果相关后，以表侧守备表示将其特殊召唤（使用SpecialSummonStep分步特殊召唤）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个回合，这个效果特殊召唤的怪兽的效果不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤处理（SpecialSummonComplete），结束分步特殊召唤过程。
	Duel.SpecialSummonComplete()
end
