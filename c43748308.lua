--微炎星－リュウシシン
-- 效果：
-- 1回合1次，自己把名字带有「炎舞」的魔法·陷阱卡发动的场合，可以从卡组选1张名字带有「炎舞」的陷阱卡在自己场上盖放。此外，1回合1次，把自己场上表侧表示存在的2张名字带有「炎舞」的魔法·陷阱卡送去墓地才能发动。从自己墓地选择「微炎星-龙史进」以外的1只名字带有「炎星」的怪兽特殊召唤。
function c43748308.initial_effect(c)
	-- 1回合1次，自己把名字带有「炎舞」的魔法·陷阱卡发动的场合，可以从卡组选1张名字带有「炎舞」的陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43748308,0))  --"盖放"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c43748308.setcon)
	e2:SetTarget(c43748308.settg)
	e2:SetOperation(c43748308.setop)
	c:RegisterEffect(e2)
	-- 此外，1回合1次，把自己场上表侧表示存在的2张名字带有「炎舞」的魔法·陷阱卡送去墓地才能发动。从自己墓地选择「微炎星-龙史进」以外的1只名字带有「炎星」的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43748308,1))  --"特殊召唤"
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c43748308.spcost)
	e3:SetTarget(c43748308.sptg)
	e3:SetOperation(c43748308.spop)
	c:RegisterEffect(e3)
end
-- 第一个效果的发动条件：仅当己方玩家发动了名字带有「炎舞」的魔法·陷阱卡时才能触发，且该发动是魔法·陷阱卡的卡的发动（EFFECT_TYPE_ACTIVATE），不是效果发动。
function c43748308.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and re:GetHandler():IsSetCard(0x7c)
end
-- 检索过滤器：选择卡组中名字带有「炎舞」（0x7c）的陷阱卡，且该卡当前可以被盖放到魔陷区。
function c43748308.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 第一个效果发动时的合法性检查：本卡不在连锁处理中（避免同一连锁内无限自触发）、己方魔陷区有空位、且卡组中存在至少1张符合条件的「炎舞」陷阱卡。
function c43748308.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本卡当前不在连锁处理中（即不是作为连锁串中的正在处理的效果），同时检查己方魔陷区是否存在空闲格子。
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在至少1张满足filter条件的「炎舞」陷阱卡，作为发动时确定能否检索的依据。
		and Duel.IsExistingMatchingCard(c43748308.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 第一个效果的处理操作：若魔陷区仍有空位，则从卡组选出1张符合条件的「炎舞」陷阱卡，由己方盖放到魔陷区。
function c43748308.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认魔陷区有空位，否则直接结束本次效果处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 给玩家显示选择提示信息，提示内容为“请选择要盖放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从己方卡组中选择1张满足filter条件的「炎舞」陷阱卡（filter：炎舞字段、陷阱卡、可盖放）。
	local g=Duel.SelectMatchingCard(tp,c43748308.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的那张「炎舞」陷阱卡盖放到己方的魔法与陷阱区域。
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 代价过滤器：选择己方场上表侧表示存在的名字带有「炎舞」的魔法·陷阱卡，且该卡可以作为代价被送去墓地。
function c43748308.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 代价判定：若己方场上存在至少2张符合条件的表侧表示炎舞魔陷，或者己方受到炎星仙-鹫真人效果影响（允许不送墓发动），则满足发动代价条件；若两个条件都不满足则不能发动。
function c43748308.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否存在至少2张符合条件的表侧表示炎舞魔法·陷阱卡，用于正常支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c43748308.cfilter,tp,LOCATION_ONFIELD,0,2,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		or Duel.IsPlayerAffectedByEffect(tp,46241344) end
	-- 实际支付代价时：若场上存在至少2张符合条件的卡，并且（没有鹫真人替代效果或玩家选择不免费发动），则必须选择2张炎舞魔陷送去墓地作为代价。
	if Duel.IsExistingMatchingCard(c43748308.cfilter,tp,LOCATION_ONFIELD,0,2,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		and (not Duel.IsPlayerAffectedByEffect(tp,46241344) or not Duel.SelectYesNo(tp,aux.Stringid(46241344,0))) then  --"是否不把卡送去墓地发动？"
		-- 给玩家显示选择提示信息，提示内容为“请选择要送去墓地的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从己方场上表侧表示的符合条件的炎舞魔陷中，选择2张作为代价。
		local g=Duel.SelectMatchingCard(tp,c43748308.cfilter,tp,LOCATION_ONFIELD,0,2,2,nil)
		-- 将选中的2张炎舞魔陷以代价（REASON_COST）形式送入墓地。
		Duel.SendtoGrave(g,REASON_COST)
	end
end
-- 特殊召唤对象过滤器：选择墓地中名字带有「炎星」（0x79）的怪兽，且不能是「微炎星-龙史进」自身，并且该怪兽可以被特殊召唤。
function c43748308.spfilter(c,e,tp)
	return c:IsSetCard(0x79) and not c:IsCode(43748308) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 第二个效果的发动目标检查：己方主要怪兽区有空位，且墓地存在至少1只符合条件的炎星怪兽，并指定其为效果对象。
function c43748308.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c43748308.spfilter(chkc,e,tp) end
	-- 检查己方的主要怪兽区域是否有可用的空格，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在至少1只满足spfilter条件的炎星怪兽，可以作为取对象特殊召唤的对象。
		and Duel.IsExistingTarget(c43748308.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家显示选择提示信息，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方墓地选择1只满足spfilter条件的「炎星」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c43748308.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，向系统声明本次效果处理包含特殊召唤，指定对象g中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 第二个效果的处理操作：取得对象卡，若对象仍与该效果关联，则将其表侧表示特殊召唤到己方场上。
function c43748308.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取得被选择为对象的怪兽卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上，不检查召唤条件，也不检查苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
