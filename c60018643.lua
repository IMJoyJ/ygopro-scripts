--サイバネット・コーデック
-- 效果：
-- 这个卡名的效果在同一连锁上只能发动1次。
-- ①：「码语者」怪兽从额外卡组往自己场上特殊召唤的场合，以那之内的1只为对象才能发动。属性和那只怪兽相同的1只电子界族怪兽从卡组加入手卡。这个回合，相同属性的怪兽不能用自己的「电脑网编解码」的效果加入手卡。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤。
function c60018643.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的效果在同一连锁上只能发动1次。①：「码语者」怪兽从额外卡组往自己场上特殊召唤的场合，以那之内的1只为对象才能发动。属性和那只怪兽相同的1只电子界族怪兽从卡组加入手卡。这个回合，相同属性的怪兽不能用自己的「电脑网编解码」的效果加入手卡。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60018643,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,60018643+EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c60018643.thcon)
	e2:SetTarget(c60018643.thtg)
	e2:SetOperation(c60018643.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查是否为自己场上从额外卡组表侧表示特殊召唤的「码语者」怪兽。
function c60018643.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x101) and c:IsControler(tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 发动条件：自己场上有「码语者」怪兽从额外卡组特殊召唤的场合。
function c60018643.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c60018643.cfilter,1,nil,tp)
end
-- 过滤条件：检查特殊召唤的怪兽中，是否存在卡组中拥有相同属性且可检索的电子界族怪兽。
function c60018643.tgfilter(c,tp,eg)
	-- 检查该怪兽是否在本次特殊召唤的怪兽中，且卡组中是否存在相同属性的电子界族怪兽。
	return eg:IsContains(c) and Duel.IsExistingMatchingCard(c60018643.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
-- 过滤条件：卡组中与目标怪兽相同属性且可以加入手卡的电子界族怪兽。
function c60018643.thfilter(c,att)
	return c:IsRace(RACE_CYBERSE) and c:IsAttribute(att) and c:IsAbleToHand()
end
-- 效果的目标选择与发动准备：选择1只符合条件的「码语者」怪兽作为对象，并声明检索效果。
function c60018643.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c60018643.tgfilter(chkc,tp,eg) end
	-- 检查场上是否存在可以作为效果对象的符合条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c60018643.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp,eg) end
	if eg:GetCount()==1 then
		-- 当特殊召唤的怪兽只有1只时，直接将其设为效果的对象。
		Duel.SetTargetCard(eg)
	else
		-- 提示玩家选择表侧表示的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家选择1只符合条件的怪兽作为效果的对象。
		Duel.SelectTarget(tp,c60018643.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,eg)
	end
	-- 设置连锁信息，表明该效果包含从卡组将1张卡加入手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：将相同属性的电子界族怪兽加入手卡，并适用后续的检索限制与额外卡组特殊召唤限制。
function c60018643.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local att=tc:GetAttribute()
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1只与对象怪兽相同属性的电子界族怪兽。
		local g=Duel.SelectMatchingCard(tp,c60018643.thfilter,tp,LOCATION_DECK,0,1,1,nil,att)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡。
			Duel.ConfirmCards(1-tp,g)
			-- 这个回合，相同属性的怪兽不能用自己的「电脑网编解码」的效果加入手卡。
			local e0=Effect.CreateEffect(c)
			e0:SetType(EFFECT_TYPE_FIELD)
			e0:SetCode(EFFECT_CANNOT_TO_HAND)
			e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e0:SetTargetRange(1,0)
			e0:SetTarget(c60018643.thlimit)
			e0:SetLabel(att)
			e0:SetReset(RESET_PHASE+PHASE_END)
			-- 注册该回合内不能用「电脑网编解码」将相同属性怪兽加入手卡的限制效果。
			Duel.RegisterEffect(e0,tp)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c60018643.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤的限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能用「电脑网编解码」的效果将相同属性的怪兽加入手卡。
function c60018643.thlimit(e,c,tp,re)
	return c:IsAttribute(e:GetLabel()) and re and re:GetHandler():IsCode(60018643)
end
-- 限制条件：不能从额外卡组特殊召唤电子界族以外的怪兽。
function c60018643.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE) and c:IsLocation(LOCATION_EXTRA)
end
