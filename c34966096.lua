--カオス・ベトレイヤー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的场合，从自己墓地把「混沌叛徒」以外的光属性和暗属性的怪兽各1只除外才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡特殊召唤成功的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
function c34966096.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，从自己墓地把「混沌叛徒」以外的光属性和暗属性的怪兽各1只除外才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34966096,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,34966096)
	e1:SetCost(c34966096.spcost)
	e1:SetTarget(c34966096.sptg)
	e1:SetOperation(c34966096.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34966096,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,34966097)
	e2:SetTarget(c34966096.rmtg)
	e2:SetOperation(c34966096.rmop)
	c:RegisterEffect(e2)
end
-- 筛选可作为代价除外、属性为光属性或暗属性、且卡名不是「混沌叛徒」的墓地怪兽，作为①效果代价素材的候选集。
function c34966096.cfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and not c:IsCode(34966096)
end
-- 判定怪兽c是否为光属性，并确认候选组g中除c外存在暗属性怪兽，用于保证光/暗各1只的搭配成立。
function c34966096.cfilter1(c,g)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and g:IsExists(Card.IsAttribute,1,c,ATTRIBUTE_DARK)
end
-- 检查选出的卡组g是否同时含有光属性与暗属性怪兽（至少存在一组光暗搭配），作为选择代价素材的完成条件。
function c34966096.check(g)
	return g:IsExists(c34966096.cfilter1,1,nil,g)
end
-- ①效果的代价处理：在满足条件时，从自己墓地选择「混沌叛徒」以外的光属性和暗属性怪兽各1只，并表侧表示除外作为发动代价。
function c34966096.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己墓地中可作为代价除外、光暗属性且不是「混沌叛徒」的怪兽集合，作为后续选择光暗各1只的候选组。
	local g=Duel.GetMatchingGroup(c34966096.cfilter,tp,LOCATION_GRAVE,0,c)
	if chk==0 then return g:CheckSubGroup(c34966096.check,2,2) end
	-- 弹出选择提示，要求玩家选择要除外的卡（此处用于代价选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c34966096.check,false,2,2)
	-- 将选中的光属性和暗属性怪兽各1只以表侧表示除外，作为发动①效果的COST。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- ①效果的发动条件检查：自己主要怪兽区有空位，且这张卡能够以表侧守备表示特殊召唤。
function c34966096.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否存在可用的空格，作为此卡特殊召唤的发动前提。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 向系统登记本效果的处理为特殊召唤这张卡，供后续连锁和相关效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：将这张卡以表侧守备表示特殊召唤；若特殊召唤成功，则给它附加一个离场时不去墓地而是除外的效果。
function c34966096.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与发动时的效果关联，并成功以表侧守备表示特殊召唤到场上（返回成功数量大于0）。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		-- 「这个效果特殊召唤的这张卡从场上离开的场合除外。」以及「②：这张卡特殊召唤成功的场合，以对方墓地1张卡为对象才能发动。那张卡除外。」
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- ②效果发动时的目标选择处理：选择对方墓地1张可除外的卡作为对象，并登记除外相关信息。
function c34966096.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在至少1张可以除外的卡，作为②效果的发动条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 弹出选择提示，要求玩家选择要除外的卡（此处用于选择效果对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地选择1张可除外的卡作为效果对象，并由系统自动记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 向系统登记本效果将除外1张对方墓地的卡（对象已确定），供后续时点和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- ②效果处理：取得发动时选择的对象卡，若该卡仍与效果关联，则将其表侧表示除外。
function c34966096.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的那张对方墓地卡片，作为本次除外处理的对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示除外，实际执行除外操作。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
