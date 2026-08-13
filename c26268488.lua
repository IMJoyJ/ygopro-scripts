--聖珖神竜 スターダスト・シフル
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽2只以上
-- 这张卡不用同调召唤不能特殊召唤。
-- ①：自己场上的卡在1回合各有1次不会被战斗·效果破坏。
-- ②：1回合1次，对方把怪兽的效果发动时才能发动。那个效果无效，场上1张卡破坏。
-- ③：把墓地的这张卡除外，以自己墓地1只8星以下的「星尘」怪兽为对象才能发动。那只怪兽特殊召唤。
function c26268488.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整素材必须是同调怪兽调整，调整以外需要2只以上的同调怪兽，对应素材条件“同调怪兽调整＋调整以外的同调怪兽2只以上”。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),2)
	c:EnableReviveLimit()
	-- 这张卡不用同调召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定值为aux.synlimit，使得这张卡只能通过同调召唤方式特殊召唤。
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- ①：自己场上的卡在1回合各有1次不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetValue(c26268488.indct)
	c:RegisterEffect(e2)
	-- ②：1回合1次，对方把怪兽的效果发动时才能发动。那个效果无效，场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26268488,0))  --"效果无效，选场上1张卡破坏。"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c26268488.discon)
	e3:SetTarget(c26268488.distg)
	e3:SetOperation(c26268488.disop)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外，以自己墓地1只8星以下的「星尘」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(26268488,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置发动代价：把墓地的这张卡除外。
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c26268488.sptg)
	e4:SetOperation(c26268488.spop)
	c:RegisterEffect(e4)
end
c26268488.material_type=TYPE_SYNCHRO
c26268488.cosmic_quasar_dragon_summon=true
-- 判断破坏原因是否为战斗或效果破坏，若是则提供1次不会被破坏的次数，否则为0。
function c26268488.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
-- ②效果的发动条件：这张卡未被战斗破坏、且对方发动怪兽效果、且该效果在连锁中可被无效。
function c26268488.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：自身未被战斗破坏、对方发动、发动的是怪兽效果、且该连锁效果可以被无效。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- ②效果的发动时处理：确认可以发动并登记操作信息：使对方那个怪兽效果无效，并破坏场上1张卡。
function c26268488.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将当前发动的对方怪兽效果（eg）作为要被无效的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 获取场上所有卡片（双方场上）作为可被破坏的候选集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 登记操作信息：从场上候选集合中选择1张卡破坏，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：先无效对方效果；若无效成功，则从双方场上选择1张卡破坏。
function c26268488.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效对方那个连锁效果；若无效失败则中止后续处理。
	if not Duel.NegateEffect(ev) then return end
	-- 向当前玩家显示选择提示，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 在双方场上选择1张任意卡作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 给选中的破坏对象显示“被选择”的动画提示。
		Duel.HintSelection(g)
		-- 以效果破坏的方式将选中的卡破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 墓地特召对象的过滤条件：卡名属于「星尘」系列、等级8以下、且可以被特殊召唤。
function c26268488.spfilter(c,e,tp)
	return c:IsSetCard(0xa3) and c:IsLevelBelow(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动条件与取对象处理：确认有可用怪兽区且墓地存在满足条件的对象，然后选择1只对象。
function c26268488.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c26268488.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可以特殊召唤的主要怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查墓地中是否存在1张满足spfilter过滤条件且可作为效果对象的卡（排除自身）。
		and Duel.IsExistingTarget(c26268488.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 向当前玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的「星尘」怪兽作为特殊召唤的对象。
	local g=Duel.SelectTarget(tp,c26268488.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次处理将进行特殊召唤，对象为已选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果处理：将选中的墓地「星尘」怪兽特殊召唤到自己场上。
function c26268488.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得通过效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
