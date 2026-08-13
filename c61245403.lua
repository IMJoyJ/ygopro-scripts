--ネコーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，若自己的场地区域没有卡存在则能发动。从卡组把1张场地魔法卡加入手卡。
-- ②：这张卡被战斗·效果破坏送去墓地的场合，以自己墓地1张场地魔法卡为对象才能发动。把1张那张卡的同名卡从卡组加入手卡。
function c61245403.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合，若自己的场地区域没有卡存在则能发动。从卡组把1张场地魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,61245403)
	e1:SetCondition(c61245403.thcon1)
	e1:SetTarget(c61245403.thtg1)
	e1:SetOperation(c61245403.thop1)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏送去墓地的场合，以自己墓地1张场地魔法卡为对象才能发动。把1张那张卡的同名卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,61245404)
	e2:SetCondition(c61245403.thcon2)
	e2:SetTarget(c61245403.thtg2)
	e2:SetOperation(c61245403.thop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判断函数：检查自己的场地区域是否存在卡，若没有卡则条件成立。
function c61245403.thcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己的场地区域卡数为0的判断结果，作为①效果的发动条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_FZONE,0)==0
end
-- 定义①效果检索的过滤条件：卡片是场地魔法卡且能够被加入手卡。
function c61245403.thfilter1(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- ①效果发动时的目标设定：确认卡组存在符合条件的场地魔法卡，并设置效果处理时将执行从卡组加入手卡的操作信息。
function c61245403.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）检查卡组是否存在至少1张满足thfilter1条件的场地魔法卡，作为发动合法性判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c61245403.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，声明本效果涉及从卡组将1张卡加入手卡（检索类操作），目标位置是卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1张场地魔法卡加入手卡，并向对方确认。
function c61245403.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示“请选择要加入手牌的卡”，用于选择卡牌时的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足thfilter1条件的场地魔法卡。
	local tg=Duel.SelectMatchingCard(tp,c61245403.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if tg:GetCount()>0 then
		-- 将选择的那张卡加入其持有者手卡，原因视为效果发动。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的那张卡，完成检索确认。
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- ②效果的发动条件判断：这张卡被战斗或效果破坏并送去墓地。
function c61245403.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ②效果选择墓地对象及判定卡组是否存在同名可检索卡的过滤函数：对象必须是场地魔法卡，且卡组中存在与之同名的可加入手卡的卡。
function c61245403.thfilter2(c,tp)
	-- 判断墓地中的卡是场地魔法卡，并且卡组中存在满足codefilter条件的同名卡，确保②效果能够检索。
	return c:IsType(TYPE_FIELD) and Duel.IsExistingMatchingCard(c61245403.codefilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 定义同名卡检索的过滤条件：卡组中的卡与墓地对象卡的卡号相同（同名），且能够加入手卡。
function c61245403.codefilter(c,tc)
	return c:IsCode(tc:GetCode()) and c:IsAbleToHand()
end
-- ②效果发动时的目标选择：选择自己墓地1张场地魔法卡作为对象，并设置效果处理时将执行从卡组加入手卡的操作信息。
function c61245403.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c61245403.thfilter2(chkc,tp) end
	-- 效果发动时检查自己墓地是否存在至少1张满足thfilter2条件的场地魔法卡（即该卡是场地魔法卡且卡组有同名卡可检索）。
	if chk==0 then return Duel.IsExistingTarget(c61245403.thfilter2,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 弹出选择对象提示“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1张场地魔法卡作为效果对象，并自动设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c61245403.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置效果处理信息，声明本效果涉及从卡组将1张卡加入手卡（检索类操作），目标位置是卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：获取对象卡，若对象仍可被效果处理，则从卡组选择1张同名卡加入手卡并向对方确认。
function c61245403.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的对象卡（墓地里的场地魔法卡）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 弹出选择提示“请选择要加入手牌的卡”，用于选择要检索的同名卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张与墓地对象卡同名的场地魔法卡（通过codefilter过滤）。
	local tg=Duel.SelectMatchingCard(tp,c61245403.codefilter,tp,LOCATION_DECK,0,1,1,nil,tc)
	if tg:GetCount()>0 then
		-- 将选择的同名卡加入其持有者手卡，原因视为效果发动。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的那张卡，完成检索确认。
		Duel.ConfirmCards(1-tp,tg)
	end
end
