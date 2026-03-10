--フィッシュボーグ－プランター
-- 效果：
-- 只在这张卡在墓地存在才能发动1次。自己卡组最上面的卡送去墓地。送去墓地的卡是水属性怪兽的场合，再把这张卡从墓地特殊召唤。「电子鱼人-栽培者」的效果1回合只能使用1次。
function c51282878.initial_effect(c)
	-- 创建效果，设置效果描述为“卡组送墓”，分类为特殊召唤，类型为起动效果，属性为不重置，适用区域为墓地，限制一回合使用一次，设置目标函数和发动函数
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
-- 检查是否满足发动条件：自己可以将卡组最上面的1张卡送去墓地、自己场上存在可用怪兽区域、此卡可以被特殊召唤
function c51282878.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以将卡组最上面的1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 检查玩家场上是否有可用怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将要处理的卡为0张，处理对象为玩家自己，处理数量为1张，处理原因为卡组送墓
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	-- 设置操作信息：将要特殊召唤的卡为自身，处理数量为1张，处理对象为玩家自己
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 发动效果函数，检查卡组是否为空，然后将卡组最上面的1张卡送去墓地，获取操作后的卡片并判断是否满足条件，若满足则中断效果并特殊召唤自身
function c51282878.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家卡组中是否有卡牌
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 将玩家卡组最上面的1张卡以效果原因送去墓地
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	local c=e:GetHandler()
	-- 获取上一次操作实际处理的卡片组中的第一张卡
	local tc=Duel.GetOperatedGroup():GetFirst()
	if tc and c:IsRelateToEffect(e) and tc:IsLocation(LOCATION_GRAVE) and tc:IsAttribute(ATTRIBUTE_WATER) then
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 将自身以0方式特殊召唤到玩家场上，正面表示
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
