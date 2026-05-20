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
-- 过滤条件：场上表侧表示且可以变成里侧表示的怪兽
function c55623480.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果①的发动准备：确认是否存在合法对象并选择对象
function c55623480.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c55623480.posfilter(chkc) end
	-- 发动条件检查：对方场上是否存在至少1只满足条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c55623480.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c55623480.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：改变1张卡表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果①的效果处理：将作为对象的怪兽变成里侧守备表示
function c55623480.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽的表示形式改变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤条件：位于主要怪兽区域的怪兽（用于在格子不足时优先除外自己场上的怪兽以腾出格子）
function c55623480.mainfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<=4
end
-- 效果②的发动代价：从手卡、场上、墓地将这张卡以外的7张卡除外（若怪兽区无空位，则必须包含自己主要怪兽区的怪兽）
function c55623480.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上主要怪兽区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	-- 获取自己手卡、场上、墓地中可以作为代价除外的卡片组（排除这张卡自身）
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return sg:GetCount()>=7 and (ft>0 or sg:IsExists(c55623480.mainfilter,ct,nil)) end
	local g=nil
	if ft<=0 then
		-- 提示玩家选择要除外的卡片（优先选择主要怪兽区的怪兽以腾出格子）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=sg:FilterSelect(tp,c55623480.mainfilter,ct,ct,nil)
		if ct<7 then
			sg:Sub(g)
			-- 提示玩家选择剩余所需除外的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local g1=sg:Select(tp,7-ct,7-ct,nil)
			g:Merge(g1)
		end
	else
		-- 提示玩家选择要除外的7张卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=sg:Select(tp,7,7,nil)
	end
	-- 将选中的卡片表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备：确认这张卡是否可以特殊召唤，并设置特殊召唤的操作信息
function c55623480.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将墓地的这张卡特殊召唤
function c55623480.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
