--天極輝艦－熊斗竜巧
-- 效果：
-- 这个卡名在规则上也当作「北极天熊」卡、「龙辉巧」卡使用。这张卡用「天斗辉巧极」的效果才能特殊召唤。
-- ①：1回合1次，自己场上有其他的效果怪兽特殊召唤的场合才能发动。从卡组把1只「北极天熊」怪兽或者「龙辉巧」怪兽加入手卡。
-- ②：1回合1次，以除外的1只自己的「北极天熊」怪兽或者「龙辉巧」怪兽为对象才能发动。那只怪兽加入手卡。
function c33250142.initial_effect(c)
	c:EnableReviveLimit()
	-- 这个卡名在规则上也当作「北极天熊」卡、「龙辉巧」卡使用。这张卡用「天斗辉巧极」的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(c33250142.splimit)
	c:RegisterEffect(e0)
	-- ①：1回合1次，自己场上有其他的效果怪兽特殊召唤的场合才能发动。从卡组把1只「北极天熊」怪兽或者「龙辉巧」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33250142,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c33250142.thcon1)
	e1:SetTarget(c33250142.thtg1)
	e1:SetOperation(c33250142.thop1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以除外的1只自己的「北极天熊」怪兽或者「龙辉巧」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33250142,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c33250142.thtg2)
	e2:SetOperation(c33250142.thop2)
	c:RegisterEffect(e2)
end
-- 特殊召唤限制的判定函数：仅当特殊召唤的发动源是「天斗辉巧极」（卡号89771220）时，这张卡才能被特殊召唤。
function c33250142.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(89771220)
end
-- ①效果的触发条件过滤：判断卡片是否为表侧表示、效果怪兽并且由我方控制，用于检测“自己场上有其他的效果怪兽特殊召唤”。
function c33250142.cfilter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsControler(tp)
end
-- ①效果的发动条件：本次特殊召唤成功的怪兽组中不包含这张卡自身，并且其中存在至少1只我方控制的其他表侧效果怪兽。
function c33250142.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c33250142.cfilter1,1,nil,tp)
end
-- ①效果的检索过滤器：卡片必须是「北极天熊」（0x163）或「龙辉巧」（0x154）怪兽，并且能够加入手卡。
function c33250142.thfilter1(c)
	return c:IsSetCard(0x163,0x154) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的目标/发动判定：在发动时（chk==0）确认卡组中有符合条件的检索目标，并设置本连锁将执行“从卡组加入手卡”的操作信息。
function c33250142.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查我方卡组是否存在至少1张满足 thfilter1 条件的「北极天熊」/「龙辉巧」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c33250142.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息：本效果将把卡组的1张卡加入手卡（不取对象，预计数量1，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理函数：从卡组选1只符合条件的「北极天熊」或「龙辉巧」怪兽加入手卡，并向对方展示。
function c33250142.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出卡片选择提示，提示我方选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 我方从自己卡组选择1张满足 thfilter1 的卡，作为检索加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,c33250142.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去持有者的手卡（实际加入手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的取对象过滤器：卡片必须满足①的检索条件（「北极天熊」或「龙辉巧」怪兽且能加入手卡），并且是表侧表示。
function c33250142.thfilter2(c)
	return c33250142.thfilter1(c) and c:IsFaceup()
end
-- ②效果的目标/发动判定：在发动时确认对象卡是否合法，在除外区选择1张自己的符合条件的表侧怪兽，并设置操作信息为加入手卡。
function c33250142.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c33250142.thfilter2(chkc) end
	-- 在效果发动时检查除外区是否存在至少1张我方控制的、满足 thfilter2 的表侧「北极天熊」/「龙辉巧」怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c33250142.thfilter2,tp,LOCATION_REMOVED,0,1,nil) end
	-- 弹出卡片选择提示，提示我方选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 我方从除外区选择1张符合条件的自己的怪兽作为效果对象，同时将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c33250142.thfilter2,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置当前连锁的操作信息：将已确定的对象卡加入手卡（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理函数：取得之前选择的对象，若对象仍与效果关联，则将其加入手卡。
function c33250142.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡，即被选择的那张除外区怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果原因加入持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
