--フィッシュボーグ－プランター
-- 效果：
-- 只在这张卡在墓地存在才能发动1次。自己卡组最上面的卡送去墓地。送去墓地的卡是水属性怪兽的场合，再把这张卡从墓地特殊召唤。「电子鱼人-栽培者」的效果1回合只能使用1次。
function c51282878.initial_effect(c)
	-- 只在这张卡在墓地存在才能发动1次。自己卡组最上面的卡送去墓地。送去墓地的卡是水属性怪兽的场合，再把这张卡从墓地特殊召唤。「电子鱼人-栽培者」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51282878,0))  --"卡组送墓"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,51282878)
	e1:SetTarget(c51282878.target)
	e1:SetOperation(c51282878.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的合法判定：检查己方卡组顶端是否可送墓、己方主要怪兽区是否有空位、此卡是否可被特殊召唤，全部满足时效果才可发动。
function c51282878.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以将己方卡组最上面1张卡送去墓地（即卡组有卡且不受限制）。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 检查自己主要怪兽区是否有空余区域，用于后续特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本效果包含从卡组送墓（堆墓）的分类，预期将己方卡组顶端1张卡送去墓地，用于连锁判断。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	-- 设置操作信息：声明本效果包含特殊召唤分类，预期将这张卡自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：先将己方卡组最上面1张卡送去墓地；若该卡是水属性怪兽且此卡仍与效果关联，则中断当前效果链并把此卡特殊召唤。
function c51282878.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方卡组没有卡，无法进行堆墓，则直接终止处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 以效果原因将己方卡组最上面1张卡送去墓地。
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	local c=e:GetHandler()
	-- 取得刚才因丢牌实际送去墓地的卡片组，取出其中那张被送去墓地的卡。
	local tc=Duel.GetOperatedGroup():GetFirst()
	if tc and c:IsRelateToEffect(e) and tc:IsLocation(LOCATION_GRAVE) and tc:IsAttribute(ATTRIBUTE_WATER) then
		-- 中断当前效果链，使后续特殊召唤作为独立处理，避免与堆墓同时处理并正确生成时点。
		Duel.BreakEffect()
		-- 将这张卡以表侧攻击表示特殊召唤到己方主要怪兽区（保持通常的召唤条件/苏生限制检查）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
