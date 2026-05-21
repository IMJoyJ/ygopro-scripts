--アマゾネス霊術師
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以「亚马逊灵术师」以外的自己场上1张「亚马逊」卡为对象才能发动。那张卡回到持有者手卡，这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「亚马逊」怪兽不能从额外卡组特殊召唤。
-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1张「融合」加入手卡。
function c97870394.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，以「亚马逊灵术师」以外的自己场上1张「亚马逊」卡为对象才能发动。那张卡回到持有者手卡，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,97870394)
	e1:SetTarget(c97870394.sptg)
	e1:SetOperation(c97870394.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1张「融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,97870395)
	e2:SetTarget(c97870394.thtg)
	e2:SetOperation(c97870394.thop)
	c:RegisterEffect(e2)
end
-- 过滤「亚马逊灵术师」以外的自己场上表侧表示且能回到手牌的「亚马逊」卡
function c97870394.filter(c,tp)
	-- 检查卡片是否为「亚马逊」卡、不是「亚马逊灵术师」、表侧表示、能回到手牌，且该卡离场后有可用的怪兽区域
	return c:IsSetCard(0x4) and not c:IsCode(97870394) and c:IsFaceup() and c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的发动准备与对象选择
function c97870394.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and c97870394.filter(chkc,tp) end
	-- 检查场上是否存在符合条件的「亚马逊」卡作为对象，且手卡·墓地的此卡可以特殊召唤
	if chk==0 then return Duel.IsExistingTarget(c97870394.filter,tp,LOCATION_ONFIELD,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1张「亚马逊」卡作为对象
	local g=Duel.SelectTarget(tp,c97870394.filter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置连锁信息，包含将选定对象卡送回手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置连锁信息，包含将此卡特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理
function c97870394.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 检查对象卡是否仍适用效果，并将其送回手牌，确认成功回到手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
		and c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「亚马逊」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c97870394.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内限制从额外卡组特殊召唤非「亚马逊」怪兽的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能从额外卡组特殊召唤非「亚马逊」怪兽
function c97870394.splimit(e,c)
	return not c:IsSetCard(0x4) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤卡组中的「融合」
function c97870394.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果②的发动准备
function c97870394.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c97870394.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，包含从卡组将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理
function c97870394.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「融合」
	local g=Duel.SelectMatchingCard(tp,c97870394.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
