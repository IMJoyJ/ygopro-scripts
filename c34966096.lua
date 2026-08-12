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
-- 过滤满足条件的墓地怪兽：能除外、光属性或暗属性、不是混沌叛徒
function c34966096.cfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and not c:IsCode(34966096)
end
-- 检查当前组中是否存在光属性怪兽，并且该组中存在暗属性怪兽
function c34966096.cfilter1(c,g)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and g:IsExists(Card.IsAttribute,1,c,ATTRIBUTE_DARK)
end
-- 检查给定的怪兽组中是否存在满足cfilter1条件的组合
function c34966096.check(g)
	return g:IsExists(c34966096.cfilter1,1,nil,g)
end
-- 效果处理：检索满足条件的墓地怪兽组，选择其中2只除外作为代价
function c34966096.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检索满足cfilter条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(c34966096.cfilter,tp,LOCATION_GRAVE,0,c)
	if chk==0 then return g:CheckSubGroup(c34966096.check,2,2) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c34966096.check,false,2,2)
	-- 将选择的卡除外作为代价
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 效果处理：判断是否可以将此卡特殊召唤
function c34966096.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡特殊召唤到场上，并设置其离场时除外的效果
function c34966096.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否能被特殊召唤并成功召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		-- 设置特殊召唤后此卡离场时除外的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 效果处理：选择对方墓地一张卡作为对象
function c34966096.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 判断对方墓地是否存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地一张卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置除外的处理信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 效果处理：将选择的对方墓地卡除外
function c34966096.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
