--ヴァレット・リチャージャー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从额外卡组特殊召唤的自己场上的表侧表示的暗属性怪兽被战斗·效果破坏的场合，把手卡·场上的这张卡送去墓地，以那些破坏的怪兽之内的1只为对象才能发动。原本卡名和那只怪兽不同的1只暗属性怪兽从自己墓地特殊召唤。
-- ②：只要从额外卡组特殊召唤的暗属性怪兽在自己场上存在，对方怪兽不能选择这张卡作为攻击对象。
function c5969957.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：从额外卡组特殊召唤的自己场上的表侧表示的暗属性怪兽被战斗·效果破坏的场合，把手卡·场上的这张卡送去墓地，以那些破坏的怪兽之内的1只为对象才能发动。原本卡名和那只怪兽不同的1只暗属性怪兽从自己墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5969957,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,5969957)
	e1:SetCondition(c5969957.spcon)
	e1:SetCost(c5969957.spcost)
	e1:SetTarget(c5969957.sptg)
	e1:SetOperation(c5969957.spop)
	c:RegisterEffect(e1)
	-- ②：只要从额外卡组特殊召唤的暗属性怪兽在自己场上存在，对方怪兽不能选择这张卡作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c5969957.atcon)
	-- 设置不能成为攻击对象效果的过滤函数
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
end
-- 过滤被战斗·效果破坏的、从额外卡组特殊召唤的自己场上的表侧表示暗属性怪兽
function c5969957.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsSummonLocation(LOCATION_EXTRA) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 检查被破坏的卡片中是否存在满足条件的怪兽，作为效果发动的条件
function c5969957.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5969957.spcfilter,1,nil,tp)
end
-- 效果发动的代价：把手卡·场上的这张卡送去墓地
function c5969957.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将作为代价的这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤可以作为效果对象的、存在于墓地或除外状态的被破坏怪兽，且墓地中必须存在原本卡名与其不同的暗属性怪兽
function c5969957.tgfilter(c,e,tp)
	return c5969957.spcfilter(c,tp) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c:IsCanBeEffectTarget(e)
		-- 检查自己墓地中是否存在至少1只原本卡名与该对象怪兽不同的暗属性怪兽
		and Duel.IsExistingMatchingCard(c5969957.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp,c)
end
-- 过滤自己墓地中可以特殊召唤的、且原本卡名与作为对象的怪兽不同的暗属性怪兽
function c5969957.spfilter(c,e,tp,tc)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 效果发动的目标：选择1只被破坏的怪兽作为对象，并声明特殊召唤的操作信息
function c5969957.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c5969957.tgfilter,nil,e,tp)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0 and g:GetCount()>0 end
	local c=nil
	if g:GetCount()>1 then
		-- 提示玩家选择作为效果对象的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		c=g:Select(tp,1,1,nil):GetFirst()
	else
		c=g:GetFirst()
	end
	-- 将选择的卡片设置为当前连锁的效果对象
	Duel.SetTargetCard(c)
	-- 设置当前连锁的操作信息为：从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：从自己墓地特殊召唤1只原本卡名与对象怪兽不同的暗属性怪兽
function c5969957.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 检查效果对象是否仍适用此效果，且自己场上仍有空余的怪兽区域
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己墓地选择1只原本卡名与对象怪兽不同的暗属性怪兽
		local g=Duel.SelectMatchingCard(tp,c5969957.spfilter,tp,LOCATION_GRAVE,0,1,1,tc,e,tp,tc)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤自己场上表侧表示的、从额外卡组特殊召唤的暗属性怪兽
function c5969957.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 检查自己场上是否存在从额外卡组特殊召唤的暗属性怪兽，作为不能成为攻击对象效果的适用条件
function c5969957.atcon(e)
	-- 检查自己场上是否存在至少1只从额外卡组特殊召唤的表侧表示暗属性怪兽
	return Duel.IsExistingMatchingCard(c5969957.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
