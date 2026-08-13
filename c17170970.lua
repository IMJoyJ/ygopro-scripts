--アーマード・ホワイトベア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上有同调怪兽存在，这张卡召唤·特殊召唤成功的场合，以自己墓地1张场地魔法卡为对象才能发动。那张卡加入手卡。
-- ②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从自己的卡组·墓地选「铠装白熊」以外的1只4星以下的兽族怪兽特殊召唤。
function c17170970.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：场上有同调怪兽存在，这张卡召唤·特殊召唤成功的场合，以自己墓地1张场地魔法卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,17170970)
	e1:SetCondition(c17170970.thcon)
	e1:SetTarget(c17170970.thtg)
	e1:SetOperation(c17170970.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从自己的卡组·墓地选「铠装白熊」以外的1只4星以下的兽族怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,17170971)
	e3:SetCondition(c17170970.spcon)
	e3:SetTarget(c17170970.sptg)
	e3:SetOperation(c17170970.spop)
	c:RegisterEffect(e3)
end
-- 过滤出场上表侧表示且为同调怪兽的卡，用于①效果的发动条件判断。
function c17170970.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- ①效果的发动条件：场上存在至少1只表侧表示的同调怪兽。
function c17170970.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1只表侧表示的同调怪兽，满足则①效果条件成立。
	return Duel.IsExistingMatchingCard(c17170970.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤出自己墓地的场地魔法卡且能够加入手牌的卡，作为①效果的对象候选。
function c17170970.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- ①效果发动时的目标选择处理：取对象选择自己墓地1张场地魔法卡，并设置加入手牌的操作信息。
function c17170970.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c17170970.filter(chkc) end
	-- 效果发动时确认自己墓地是否存在1张可加入手牌的场地魔法卡作为对象。
	if chk==0 then return Duel.IsExistingTarget(c17170970.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出“请选择要加入手牌的卡”的选择提示，让玩家选择①效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张符合条件的场地魔法卡作为效果对象，并自动登记为连锁对象。
	local g=Duel.SelectTarget(tp,c17170970.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁要执行的操作为“将对象卡加入手牌”，指定对象组及数量，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：将选择的对象卡加入持有者手牌（若仍与效果关联）。
function c17170970.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出效果发动时选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回持有者手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡被战斗破坏，或被对方的效果破坏送去墓地且之前由自己控制时才能发动。
function c17170970.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp))
end
-- 过滤出符合条件的特殊召唤候选：兽族、4星以下、不是「铠装白熊」本身，且可以被特殊召唤。
function c17170970.spfilter(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:IsLevelBelow(4) and not c:IsCode(17170970) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时的条件确认：自己主要怪兽区有空位，且卡组·墓地存在符合条件的兽族怪兽，并设置特殊召唤的操作信息。
function c17170970.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时确认自己主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组或墓地存在至少1只满足条件的兽族怪兽作为特殊召唤候选。
		and Duel.IsExistingMatchingCard(c17170970.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置本次连锁要执行的操作为“从卡组·墓地特殊召唤1只兽族怪兽”，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果处理：若仍有可用怪兽区空格，则从卡组·墓地选1只符合条件的兽族怪兽表侧表示特殊召唤到自己场上。
function c17170970.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的主要怪兽区空格，则终止②效果的处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出“请选择要特殊召唤的卡”的选择提示，让玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组·墓地中选择1只满足条件且不受王家长眠之谷影响的兽族怪兽，作为②效果的特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c17170970.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
