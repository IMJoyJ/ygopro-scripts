--妖精伝姫－シラユキ
-- 效果：
-- ①：这张卡召唤·特殊召唤的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ②：自己·对方回合，这张卡在墓地存在的场合，从自己的手卡·场上·墓地把这张卡以外的7张卡除外才能发动。这张卡特殊召唤。
function c55623480.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55623480,0))  --"变成里侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c55623480.postg)
	e1:SetOperation(c55623480.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，这张卡在墓地存在的场合，从自己的手卡·场上·墓地把这张卡以外的7张卡除外才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55623480,1))  --"这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(c55623480.spcost)
	e3:SetTarget(c55623480.sptg)
	e3:SetOperation(c55623480.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数：返回卡为表侧表示且可以变成里侧表示（能被盖放）的怪兽
function c55623480.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ①效果的目标函数：确认对方场上存在可作为对象的表侧表示怪兽，并选择其中1只作为对象
function c55623480.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c55623480.posfilter(chkc) end
	-- 检查对方场上是否存在1只以上表侧表示且能被盖放的可作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c55623480.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 以对方场上1只表侧表示且能被盖放的怪兽为对象
	local g=Duel.SelectTarget(tp,c55623480.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息：将对象怪兽作为改变表示形式的处理对象
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ①效果的处理：若对象怪兽仍与本效果相关且为表侧表示，则将其变成里侧守备表示
function c55623480.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 把对象怪兽变成里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤函数：判断该卡离场后自己场上是否仍有可用的主要怪兽区
function c55623480.mainfilter(c,tp)
	-- 返回这张卡除外后自己主要怪兽区仍有空位（用于场上无空位时必须先除外场上的卡腾出格子）
	return Duel.GetMZoneCount(tp,c)>0
end
-- ②效果的代价函数：收集手卡·场上·墓地中这张卡以外可除外的卡，确认数量足够且有空位后，选择7张并将它们除外作为代价
function c55623480.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己主要怪兽区当前的空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检索自己手卡·场上·墓地中这张卡以外所有可以作为代价除外的卡
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return sg:GetCount()>=7 and (ft>0 or sg:IsExists(c55623480.mainfilter,1,nil,tp)) end
	local g=nil
	if ft<=0 then
		-- 提示玩家请选择要除外的卡（先选择1张能腾出怪兽区的卡）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=sg:FilterSelect(tp,c55623480.mainfilter,1,1,nil,tp)
		sg:Sub(g)
		-- 提示玩家请选择要除外的卡（再选择其余6张）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local g1=sg:Select(tp,6,6,nil)
		g:Merge(g1)
	else
		-- 提示玩家请选择要除外的卡（直接选择7张）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=sg:Select(tp,7,7,nil)
	end
	-- 将选出的7张卡以表侧表示除外，作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标函数：确认这张卡可以被特殊召唤，并设置特殊召唤的操作信息
function c55623480.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息：预定将这张卡从墓地特殊召唤1只
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：若这张卡仍与本连锁相关，则将自己特殊召唤到场上
function c55623480.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 把这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
