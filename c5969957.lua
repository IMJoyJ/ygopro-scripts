--ヴァレット・リチャージャー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从额外卡组特殊召唤的自己场上的表侧表示的暗属性怪兽被战斗·效果破坏的场合，把手卡·场上的这张卡送去墓地，以那些破坏的怪兽之内的1只为对象才能发动。原本卡名和那只怪兽不同的1只暗属性怪兽从自己墓地特殊召唤。
-- ②：只要从额外卡组特殊召唤的暗属性怪兽在自己场上存在，对方怪兽不能选择这张卡作为攻击对象。
function c5969957.initial_effect(c)
	-- ①：从额外卡组特殊召唤的自己场上的表侧表示的暗属性怪兽被战斗·效果破坏的场合，把手卡·场上的这张卡送去墓地，以那些破坏的怪兽之内的1只为对象才能发动。原本卡名和那只怪兽不同的1只暗属性怪兽从自己墓地特殊召唤
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
	-- ②：只要从额外卡组特殊召唤的暗属性怪兽在自己场上存在，对方怪兽不能选择这张卡作为攻击对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c5969957.atcon)
	-- 设置不能成为攻击对象的过滤函数
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
end
-- 过滤从额外卡组特殊召唤的自己场上的表侧表示被战斗·效果破坏的暗属性怪兽
function c5969957.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsSummonLocation(LOCATION_EXTRA) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 检查是否有从额外卡组特殊召唤的自己场上的表侧表示暗属性怪兽被战斗·效果破坏
function c5969957.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5969957.spcfilter,1,nil,tp)
end
-- 把手卡·场上的这张卡送去墓地的代价条件检查与执行
function c5969957.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把自身送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤可以成为效果对象且自己墓地存在原本卡名与之不同的暗属性怪兽的被破坏怪兽
function c5969957.tgfilter(c,e,tp)
	return c5969957.spcfilter(c,tp) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c:IsCanBeEffectTarget(e)
		-- 检查自己墓地是否存在原本卡名与目标怪兽不同且可以特殊召唤的暗属性怪兽
		and Duel.IsExistingMatchingCard(c5969957.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp,c)
end
-- 过滤自己墓地原本卡名与目标怪兽不同且可以特殊召唤的暗属性怪兽
function c5969957.spfilter(c,e,tp,tc)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 选择被破坏的怪兽之内的1只为对象，设置特殊召唤操作信息
function c5969957.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c5969957.tgfilter,nil,e,tp)
	if chkc then return g:IsContains(chkc) end
	-- 检查主要怪兽区域空位以及是否有可作为效果对象的被破坏怪兽
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0 and g:GetCount()>0 end
	local c=nil
	if g:GetCount()>1 then
		-- 提示玩家选择要作为效果对象的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		c=g:Select(tp,1,1,nil):GetFirst()
	else
		c=g:GetFirst()
	end
	-- 将选择的被破坏怪兽设为当前连锁的效果对象
	Duel.SetTargetCard(c)
	-- 设置特殊召唤墓地怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 一效果效果处理：将自己墓地1只原本卡名和对象怪兽不同的暗属性怪兽特殊召唤
function c5969957.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 检查效果对象是否仍适用且自己主要怪兽区域有空位
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只与对象怪兽原本卡名不同的暗属性怪兽
		local g=Duel.SelectMatchingCard(tp,c5969957.spfilter,tp,LOCATION_GRAVE,0,1,1,tc,e,tp,tc)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤自己场上从额外卡组特殊召唤的表侧表示暗属性怪兽
function c5969957.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 二效果的发动条件：自己场上存在额外卡组特殊召唤的暗属性怪兽
function c5969957.atcon(e)
	-- 检查自己场上是否存在额外卡组特殊召唤的暗属性怪兽
	return Duel.IsExistingMatchingCard(c5969957.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
