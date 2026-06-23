--光波複葉機
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有「光波」怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，以自己场上2只「光波」怪兽为对象才能发动。那些怪兽的等级直到回合结束时变成8星。
-- ③：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只「光波」怪兽加入手卡。
function c29092121.initial_effect(c)
	-- ①：自己场上有「光波」怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
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
	-- 将这张卡除外作为cost
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c29092121.thtg)
	e4:SetOperation(c29092121.thop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上是否存在「光波」怪兽
function c29092121.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0xe5)
end
-- 效果条件：确认是否有「光波」怪兽被召唤或特殊召唤
function c29092121.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c29092121.cfilter,1,nil,tp)
end
-- 效果处理准备：判断是否可以特殊召唤此卡
function c29092121.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡特殊召唤到场上
function c29092121.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断是否为「光波」怪兽且等级不是8
function c29092121.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe5) and not c:IsLevel(8) and c:IsLevelAbove(1)
end
-- 效果处理准备：选择2只「光波」怪兽作为对象
function c29092121.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c29092121.lvfilter(chkc) end
	-- 判断场上是否存在2只符合条件的「光波」怪兽
	if chk==0 then return Duel.IsExistingTarget(c29092121.lvfilter,tp,LOCATION_MZONE,0,2,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择2只「光波」怪兽作为对象
	Duel.SelectTarget(tp,c29092121.lvfilter,tp,LOCATION_MZONE,0,2,2,nil)
end
-- 过滤函数，用于判断对象怪兽是否表侧表示且与效果相关
function c29092121.tgfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 效果处理：将选中的怪兽等级变为8
function c29092121.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c29092121.tgfilter,nil,e)
	if g:GetCount()<=0 then return end
	-- 遍历所有被选择的怪兽
	for tc in aux.Next(g) do
		-- 给对象怪兽设置等级变为8的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 效果条件：确认此卡被战斗或效果破坏并送入墓地
function c29092121.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤函数，用于检索卡组中的「光波」怪兽
function c29092121.thfilter(c)
	return c:IsSetCard(0xe5) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理准备：检索卡组中的「光波」怪兽
function c29092121.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在「光波」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c29092121.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：将1张「光波」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组检索1只「光波」怪兽加入手牌
function c29092121.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张「光波」怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,c29092121.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
