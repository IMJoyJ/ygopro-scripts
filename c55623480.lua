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
-- 对象过滤函数：筛选表侧表示且可以变成里侧守备表示的怪兽
function c55623480.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ①效果的目标函数：确认对方场上存在可变成里侧守备表示的表侧表示怪兽，并选取其中1只作为效果对象
function c55623480.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c55623480.posfilter(chkc) end
	-- 发动条件检查：对方主要怪兽区是否存在至少1只可选为对象、表侧表示且能变成里侧守备表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c55623480.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动玩家提示"请选择表侧表示的卡"，作为接下来选择效果对象的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动玩家选择对方场上1只满足条件的表侧表示怪兽，并将其设为当前连锁的效果对象
	local g=Duel.SelectTarget(tp,c55623480.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：声明该连锁包含改变表示形式（盖放）的处理，对象为选中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ①效果的处理函数：取得效果对象，若其仍与此效果关联且为表侧表示，则将其变成里侧守备表示
function c55623480.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象（即被选中的对方怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 把对象怪兽变成里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 辅助过滤函数：判断这张卡（被除外）离开场上后，自己场上是否仍有可用的主要怪兽区
function c55623480.mainfilter(c,tp)
	-- 返回这张卡离开后自己的主要怪兽区空位数量大于0，即除外此卡能腾出怪兽区格子
	return Duel.GetMZoneCount(tp,c)>0
end
-- ②效果的代价函数：从自己手卡·场上·墓地把这张卡以外的7张卡除外作为发动代价（怪兽区无空位时须先选1张场上的卡除外以腾出格子，再选其余6张）
function c55623480.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己主要怪兽区当前可用的空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 取得自己手卡·场上·墓地中这张卡以外所有可以作为代价被除外的卡
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return sg:GetCount()>=7 and (ft>0 or sg:IsExists(c55623480.mainfilter,1,nil,tp)) end
	local g=nil
	if ft<=0 then
		-- 提示发动玩家选择要除外的卡（怪兽区无空位时，先选择1张除外后能腾出格子的场上的卡）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=sg:FilterSelect(tp,c55623480.mainfilter,1,1,nil,tp)
		sg:Sub(g)
		-- 提示发动玩家选择要除外的卡（在已选1张腾格子的卡之后，再选择其余6张）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local g1=sg:Select(tp,6,6,nil)
		g:Merge(g1)
	else
		-- 提示发动玩家选择要除外的卡（怪兽区有空位时，直接选择7张）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=sg:Select(tp,7,7,nil)
	end
	-- 把选择好的7张卡以表侧表示除外，作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标函数：确认墓地的这张卡可以被特殊召唤，并设置特殊召唤的操作信息
function c55623480.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明该连锁将把这张卡（自身1张）特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理函数：若这张卡仍与当前连锁关联，则将其从墓地特殊召唤到自己场上
function c55623480.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 把这张卡以表侧表示特殊召唤到自己场上（不无视召唤条件和苏生限制）
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
