--ネメシス・フラッグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「星义旗舰兽」以外的除外的1只自己怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
-- ②：自己主要阶段才能发动。从卡组把「星义旗舰兽」以外的1只「星义」怪兽加入手卡。
function c19211362.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在的场合，以「星义旗舰兽」以外的自己的除外状态的1只怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19211362,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,19211362)
	e1:SetTarget(c19211362.sptg)
	e1:SetOperation(c19211362.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把「星义旗舰兽」以外的1只「星义」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19211362,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,19211363)
	e2:SetTarget(c19211362.srtg)
	e2:SetOperation(c19211362.srop)
	c:RegisterEffect(e2)
end
-- 筛选效果①的对象：必须是我方除外区表侧表示的怪兽，卡名不为「星义旗舰兽」，且满足能被送回卡组的条件。
function c19211362.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsCode(19211362) and c:IsAbleToDeck()
end
-- 效果①的发动条件和取对象合法性判定：指定对象必须是我方除外区满足tdfilter的怪兽；同时在发动时确认自己场上主要怪兽区有空位、此卡可以特殊召唤、且存在合法对象。
function c19211362.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c19211362.tdfilter(chkc) end
	-- 检查我方主要怪兽区是否有可用空格，用于特殊召唤此卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否存在满足条件的对象，即我方除外区表侧表示、卡名不是「星义旗舰兽」且可返回卡组的怪兽。
		and Duel.IsExistingTarget(c19211362.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 发出选择提示消息，提示玩家选择要返回卡组的对象卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从我方除外区选择1只满足tdfilter的怪兽作为该效果的对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c19211362.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：本次效果包含特殊召唤，处理时特殊召唤的对象为此卡（e:GetHandler()），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：本次效果包含返回卡组，处理时返回卡组的对象为已选择的目标g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果①处理时：若此卡仍与效果关联，则将其表侧表示特殊召唤；若特殊召唤成功且对象卡仍与效果关联，则将对象怪兽送回持有者卡组并洗牌。
function c19211362.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若此卡仍与该效果关联，则尝试将其表侧表示特殊召唤到我的主要怪兽区；若特殊召唤成功且对象卡仍与效果关联，才继续执行送回卡组的处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsRelateToEffect(e) then
		-- 将对象怪兽送回持有者卡组并洗牌，处理原因为效果。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 筛选效果②检索的卡：必须是「星义」系列怪兽，卡名不为「星义旗舰兽」，且能够被加入手卡。
function c19211362.srfilter(c)
	return c:IsSetCard(0x13d) and c:IsType(TYPE_MONSTER) and not c:IsCode(19211362) and c:IsAbleToHand()
end
-- 效果②的发动条件检查与操作信息设置：确认卡组中存在满足条件的「星义」怪兽，并设置效果处理时从卡组将1张卡加入手卡的操作信息。
function c19211362.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：检查卡组中是否存在至少1只满足srfilter的「星义」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c19211362.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果包含从卡组将卡片加入手卡，因为检索目标在处理时选择，故对象暂设为nil，数量为1，目标玩家为tp，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②处理时：玩家从卡组选择1只满足srfilter的「星义」怪兽加入手卡，然后让对方确认该卡。
function c19211362.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 发出选择提示消息，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1只满足srfilter的「星义」怪兽（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c19211362.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者的手卡，处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡，以公开检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
