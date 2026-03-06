--聖珖神竜 スターダスト・シフル
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽2只以上
-- 这张卡不用同调召唤不能特殊召唤。
-- ①：自己场上的卡在1回合各有1次不会被战斗·效果破坏。
-- ②：1回合1次，对方把怪兽的效果发动时才能发动。那个效果无效，场上1张卡破坏。
-- ③：把墓地的这张卡除外，以自己墓地1只8星以下的「星尘」怪兽为对象才能发动。那只怪兽特殊召唤。
function c26268488.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和2只以上调整以外的同调怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),2)
	c:EnableReviveLimit()
	-- 这张卡不用同调召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡的特殊召唤条件为必须通过同调召唤
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
	-- 支付将此卡除外的费用
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c26268488.sptg)
	e4:SetOperation(c26268488.spop)
	c:RegisterEffect(e4)
end
c26268488.material_type=TYPE_SYNCHRO
c26268488.cosmic_quasar_dragon_summon=true
-- 当受到战斗或效果破坏时，该卡不会被破坏
function c26268488.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
-- 连锁发动条件：此卡未因战斗破坏，对方发动怪兽效果，且该效果可被无效
function c26268488.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动怪兽效果且该效果可被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 设置连锁发动的处理信息，包括无效效果和破坏场上一张卡
function c26268488.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁发动的处理信息，将要无效的效果对象
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 获取场上所有满足条件的卡作为破坏目标
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁发动的处理信息，将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行连锁发动效果，使对方效果无效并选择场上一张卡破坏
function c26268488.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使对方效果无效，若无效失败则返回
	if not Duel.NegateEffect(ev) then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张卡作为破坏对象
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显示所选卡被选为对象的动画
		Duel.HintSelection(g)
		-- 将所选卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 过滤满足条件的「星尘」怪兽，等级不超过8级
function c26268488.spfilter(c,e,tp)
	return c:IsSetCard(0xa3) and c:IsLevelBelow(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择条件
function c26268488.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c26268488.spfilter(chkc,e,tp) end
	-- 判断是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否有满足条件的墓地怪兽
		and Duel.IsExistingTarget(c26268488.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中的目标怪兽
	local g=Duel.SelectTarget(tp,c26268488.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤效果，将目标怪兽特殊召唤
function c26268488.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
