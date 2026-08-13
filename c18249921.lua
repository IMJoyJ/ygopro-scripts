--電脳堺門－玄武
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有其他的「电脑堺门」卡存在的场合，自己·对方的战斗阶段，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的表示形式变更。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「电脑堺」怪兽为对象才能发动。那只怪兽效果无效特殊召唤。那之后，选1张手卡送去墓地。
function c18249921.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,18249921+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- ①：自己场上有其他的「电脑堺门」卡存在的场合，自己·对方的战斗阶段，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18249921,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,18249922)
	e2:SetCondition(c18249921.cpcon)
	e2:SetTarget(c18249921.cptg)
	e2:SetOperation(c18249921.cpop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「电脑堺」怪兽为对象才能发动。那只怪兽效果无效特殊召唤。那之后，选1张手卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18249921,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,18249923)
	e3:SetCondition(c18249921.spcon)
	-- 设置②效果发动时需将墓地中的这张卡除外作为COST（aux.bfgcost 实现除外自身）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c18249921.sptg)
	e3:SetOperation(c18249921.spop)
	c:RegisterEffect(e3)
end
-- 定义过滤器：用于判断场上是否存在表侧表示且属于「电脑堺门」系列的卡，作为①效果的发动条件之一。
function c18249921.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114e)
end
-- ①效果的发动条件：当前为战斗阶段（开始到结束）且自己场上有其他表侧表示的「电脑堺门」卡存在。
function c18249921.cpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于后续判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前阶段是否在战斗阶段开始到战斗阶段结束之间，并且存在满足条件的「电脑堺门」卡；满足则①效果可发动。
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and Duel.IsExistingMatchingCard(c18249921.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 定义过滤器：选择场上表侧表示且可以变更表示形式的怪兽作为①效果的对象。
function c18249921.cpfilter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- ①效果的发动时选择对象处理：合法对象为场上表侧表示且可变更表示形式的怪兽，选择1只并设置操作信息为改变表示形式。
function c18249921.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c18249921.cpfilter(chkc) end
	-- 发动时确认是否存在至少1只符合条件的表侧表示怪兽可以成为对象。
	if chk==0 then return Duel.IsExistingTarget(c18249921.cpfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，让对方选择要变更表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从双方怪兽区域选择1只符合条件的表侧表示怪兽作为效果对象，并自动关联到当前连锁。
	local g=Duel.SelectTarget(tp,c18249921.cpfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 记录本次操作是改变表示形式，指定对象为刚选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ①效果处理：若对象仍与效果关联，则将其表示形式在表侧攻击/表侧守备之间互相转换（攻击表示变守备，守备表示变攻击）。
function c18249921.cpop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动①效果时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式由表侧攻击变为表侧守备，或由表侧守备变为表侧攻击（传入四个位置参数分别对应攻/守/攻/守的变更目标）。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- ②效果的发动条件：自己的主要阶段（主要阶段1或主要阶段2）且当前回合玩家是自己。
function c18249921.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否自己的主要阶段。
	local ph=Duel.GetCurrentPhase()
	-- 确认当前回合是自己且处于主要阶段1或主要阶段2，满足才能发动②效果。
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 定义过滤器：选择自己墓地中属于「电脑堺」系列、且可以被特殊召唤的怪兽作为②效果的对象。
function c18249921.spfilter(c,e,tp)
	return c:IsSetCard(0x14e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时选择对象处理：确认自己主要怪兽区有空位、墓地存在符合条件的「电脑堺」怪兽，且手牌至少1张卡可以送去墓地；随后选择对象并设置特殊召唤与送墓操作信息。
function c18249921.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c18249921.spfilter(chkc,e,tp) end
	-- ②效果发动条件检查：自己主要怪兽区有空位，且墓地存在1只符合条件的「电脑堺」怪兽作为特殊召唤对象。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c18249921.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- ②效果额外发动条件检查：手牌存在至少1张可以送去墓地的卡，用于后续“选1张手卡送去墓地”的处理。
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,nil) end
	-- 显示选择提示，让玩家选择要特殊召唤的墓地「电脑堺」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「电脑堺」怪兽作为特殊召唤对象，并关联到当前连锁。
	local g=Duel.SelectTarget(tp,c18249921.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 记录本次操作包含特殊召唤，指定对象为选择的墓地怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 记录本次操作还包含从手牌将1张卡送去墓地；具体手牌卡在效果处理时选择，因此目标暂不指定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- ②效果处理：若对象仍与效果关联，将其特殊召唤，并给它附加效果无效化状态（EFFECT_DISABLE和EFFECT_DISABLE_EFFECT）；特殊召唤完成后，若召唤成功则再从手牌选1张卡送去墓地。
function c18249921.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将对象怪兽以表侧表示特殊召唤到自己的主要怪兽区；返回是否召唤成功。
	local res=Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	if res then
		-- 那只怪兽效果无效特殊召唤（使特殊召唤的怪兽效果无效化）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽效果无效特殊召唤（使其效果无效化）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 结束分解式特殊召唤，完成特殊召唤处理并触发召唤成功的时点。
	Duel.SpecialSummonComplete()
	-- 获取当前手牌中所有可以送去墓地的卡，用于“选1张手卡送去墓地”的选择池。
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_HAND,0,nil)
	if res and #g>0 then
		-- 中断当前效果处理，使后续“选1张手卡送去墓地”作为独立处理，避免与特殊召唤同时处理而错过时点。
		Duel.BreakEffect()
		-- 显示选择提示，让玩家选择1张手牌送去墓地。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 将选择的手牌以效果原因送去墓地，完成“那之后，选1张手卡送去墓地”的处理。
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
