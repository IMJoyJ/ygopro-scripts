--くず鉄の像
-- 效果：
-- 「废铁像」的①②的效果1回合各能使用1次。
-- ①：对方场上的已是表侧表示存在的魔法·陷阱卡把那个效果发动时才能发动。那张卡破坏。发动后这张卡不送去墓地，直接盖放。
-- ②：这张卡被送去墓地的场合，以自己墓地1只「废品」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c48497555.initial_effect(c)
	-- ①：对方场上的已是表侧表示存在的魔法·陷阱卡把那个效果发动时才能发动。那张卡破坏。发动后这张卡不送去墓地，直接盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,48497555)
	e1:SetCondition(c48497555.condition)
	e1:SetTarget(c48497555.target)
	e1:SetOperation(c48497555.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以自己墓地1只「废品」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,48497556)
	e2:SetTarget(c48497555.sptg)
	e2:SetOperation(c48497555.spop)
	c:RegisterEffect(e2)
end
-- 发动条件判定：仅在对方场上的表侧表示的魔法·陷阱卡发动其效果（非该卡作为魔法·陷阱卡的通常发动）时，本卡的发动条件成立。
function c48497555.condition(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsOnField() and rc:IsControler(1-tp) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 发动时的合法性检查：若对方发动的效果的那张魔法·陷阱卡可以被破坏，则满足发动条件，并将破坏对象信息登记为连锁中的那张卡。
function c48497555.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 设置连锁操作信息：声明本次效果处理将破坏1张卡，即对方发动效果的那张魔法·陷阱卡（eg），用于其他效果连锁时的判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 效果处理：若对方那张魔法·陷阱卡仍与效果关联则将其破坏；之后若本卡仍与效果关联且可变为里侧表示，则错开时点，取消本卡因发动而送去墓地的处理，直接将其变为里侧表示盖放，并触发盖放时点。
function c48497555.activate(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 以效果破坏对方发动效果的那张魔法·陷阱卡（eg）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsCanTurnSet() then
		-- 中断当前效果的连续处理，使接下来的盖放操作与之前的破坏处理分为不同时点，以正确触发时点（避免错过时点）。
		Duel.BreakEffect()
		c:CancelToGrave()
		-- 将本卡变为里侧表示，即直接盖放到魔法与陷阱区域。
		Duel.ChangePosition(c,POS_FACEDOWN)
		-- 手动触发一次“放置魔法·陷阱卡”的事件时点，让其他卡能够对这次盖放进行响应。
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
-- 筛选条件：自己墓地的卡名含有「废品」字段、且可以被表侧守备表示特殊召唤的怪兽（同时检查苏生限制）。
function c48497555.spfilter(c,e,tp)
	return c:IsSetCard(0x43) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的目标判定：若是在检查已选对象则要求该卡是自己墓地的「废品」怪兽且可表侧守备特殊召唤；若是在发动合法性检查则要求自己场上有空位且墓地存在至少1只符合条件的对象。
function c48497555.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c48497555.spfilter(chkc,e,tp) end
	-- 发动合法性检查：确认自己场上有可用的主要怪兽区域空格，用于放置特殊召唤的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认自己墓地存在至少1只符合条件的「废品」怪兽，可以作为特殊召唤的对象。
		and Duel.IsExistingTarget(c48497555.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「废品」怪兽，并将其登记为本次连锁的对象（取对象）。
	local g=Duel.SelectTarget(tp,c48497555.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次效果将特殊召唤1只怪兽，对象为已选择的g。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得对象怪兽，若该对象仍与效果关联，则将其以表侧守备表示特殊召唤到自己场上。
function c48497555.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象怪兽（即发动时选择的那1只墓地「废品」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到其持有者（也是使用者tp）的场上；检查召唤条件和苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
