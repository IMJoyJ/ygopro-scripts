--星杯の守護竜
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的连接状态的怪兽为对象的魔法·陷阱·怪兽的效果发动时，把手卡·场上的这张卡送去墓地才能发动。那个发动无效并破坏。
-- ②：把墓地的这张卡除外，以自己墓地1只通常怪兽为对象才能发动。那只怪兽在作为连接怪兽所连接区的自己场上守备表示特殊召唤。
function c84899094.initial_effect(c)
	-- ①：自己场上的连接状态的怪兽为对象的魔法·陷阱·怪兽的效果发动时，把手卡·场上的这张卡送去墓地才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84899094,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(c84899094.condition)
	e1:SetCost(c84899094.cost)
	e1:SetTarget(c84899094.target)
	e1:SetOperation(c84899094.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只通常怪兽为对象才能发动。那只怪兽在作为连接怪兽所连接区的自己场上守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84899094,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,84899094)
	-- 将墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c84899094.sptg)
	e2:SetOperation(c84899094.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上的连接状态的怪兽
function c84899094.filter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsLinkState()
end
-- 检查发动效果是否以自己场上连接状态的怪兽为对象，且该发动可以被无效
function c84899094.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c84899094.filter,1,nil,tp)
		-- 且该效果的发动可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 检查并执行把手卡·场上的这张卡送去墓地的代价
function c84899094.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果1的发动准备，设置无效与破坏的操作信息
function c84899094.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将该发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏该卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果1的实际处理：使发动无效并破坏
function c84899094.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，且该卡在场上存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤自己墓地中可以守备表示特殊召唤到连接区的通常怪兽
function c84899094.spfilter(c,e,tp,zone)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
-- 效果2的发动准备，获取连接区并选择墓地的通常怪兽作为对象
function c84899094.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上连接怪兽所连接的区域
	local zone=Duel.GetLinkedZone(tp)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c84899094.spfilter(chkc,e,tp,zone) end
	if chk==0 then return zone~=0
		-- 且自己墓地存在可以特殊召唤到连接区的通常怪兽
		and Duel.IsExistingTarget(c84899094.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp,zone) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只符合条件的通常怪兽作为对象
	local tg=Duel.SelectTarget(tp,c84899094.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp,zone)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,0,0)
end
-- 效果2的实际处理：将对象怪兽在连接区守备表示特殊召唤
function c84899094.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取当前可用的连接区域
	local zone=Duel.GetLinkedZone(tp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将该怪兽在连接区守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone)
	end
end
