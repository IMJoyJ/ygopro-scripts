--光波複葉機
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有「光波」怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，以自己场上2只「光波」怪兽为对象才能发动。那些怪兽的等级直到回合结束时变成8星。
-- ③：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只「光波」怪兽加入手卡。
function c29092121.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：自己场上有「光波」怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29092121,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,29092121)
	e1:SetCondition(c29092121.spcon)
	e1:SetTarget(c29092121.sptg)
	e1:SetOperation(c29092121.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己场上2只「光波」怪兽为对象才能发动。那些怪兽的等级直到回合结束时变成8星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29092121,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c29092121.lvtg)
	e3:SetOperation(c29092121.lvop)
	c:RegisterEffect(e3)
	-- ③：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只「光波」怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29092121,2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,29092122)
	e4:SetCondition(c29092121.thcon)
	-- 设置③效果的发动代价：把墓地中的这张卡除外。
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c29092121.thtg)
	e4:SetOperation(c29092121.thop)
	c:RegisterEffect(e4)
end
-- 过滤条件：卡为表侧表示、控制者为发动方且属于「光波」系列。
function c29092121.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0xe5)
end
-- 判定满足触发条件：召唤·特殊召唤成功的怪兽群中存在至少1只表侧表示且由自己控制的「光波」怪兽。
function c29092121.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c29092121.cfilter,1,nil,tp)
end
-- 效果发动目标检查：自己主要怪兽区有空位，且这张卡能够被特殊召唤。
function c29092121.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，宣告将这张卡特殊召唤的处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，则将其特殊召唤。
function c29092121.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选可作为对象的怪兽：表侧表示、「光波」系列、等级不是8且原等级在1以上。
function c29092121.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe5) and not c:IsLevel(8) and c:IsLevelAbove(1)
end
-- 取对象效果的目标处理：验证对象合法性、检查是否存在2只符合条件的怪兽、提示并选择2只对象。
function c29092121.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c29092121.lvfilter(chkc) end
	-- 检查场上是否存在至少2只符合条件的「光波」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c29092121.lvfilter,tp,LOCATION_MZONE,0,2,nil) end
	-- 弹出“请选择表侧表示的卡”的提示信息，用于对象选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上2只符合条件的「光波」怪兽作为效果对象。
	Duel.SelectTarget(tp,c29092121.lvfilter,tp,LOCATION_MZONE,0,2,2,nil)
end
-- 过滤已选择的对象：只保留仍与效果关联且表侧表示的表侧怪兽。
function c29092121.tgfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 效果处理：取得对象并对其各赋予一个改变等级为8的持续效果，直到回合结束。
function c29092121.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得对象卡组，并过滤出仍与效果关联的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c29092121.tgfilter,nil,e)
	if g:GetCount()<=0 then return end
	-- 遍历对象卡组中的每一张卡。
	for tc in aux.Next(g) do
		-- 那些怪兽的等级直到回合结束时变成8星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 发动条件：这张卡被战斗或效果破坏并送去墓地。
function c29092121.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 检索条件：卡组中「光波」系列怪兽且可以加入手卡。
function c29092121.thfilter(c)
	return c:IsSetCard(0xe5) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 目标检查：卡组中存在符合条件的「光波」怪兽，并设置加入手卡的操作信息。
function c29092121.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张符合条件的「光波」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c29092121.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，宣告从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：提示选择，从卡组选择1张符合条件的「光波」怪兽加入手卡，并向对方展示。
function c29092121.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的提示信息，用于检索选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的「光波」怪兽。
	local g=Duel.SelectMatchingCard(tp,c29092121.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
