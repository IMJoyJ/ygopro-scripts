--撃滅龍 ダーク・アームド
-- 效果：
-- 7星怪兽×2只以上
-- 「击灭龙 暗黑武装」1回合1次也能在自己墓地的暗属性怪兽只有5只的场合，在自己场上的5星以上的龙族·暗属性怪兽上面重叠来超量召唤。
-- ①：把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡破坏。那之后，从自己墓地选1张卡除外。这个效果的发动后，直到回合结束时这张卡不能攻击。
function c78144171.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,7,2,c78144171.ovfilter,aux.Stringid(78144171,0),99,c78144171.xyzop)  --"是否只用1只素材超量召唤？"
	-- ①：把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡破坏。那之后，从自己墓地选1张卡除外。这个效果的发动后，直到回合结束时这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78144171,1))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c78144171.cost)
	e1:SetTarget(c78144171.target)
	e1:SetOperation(c78144171.activate)
	c:RegisterEffect(e1)
end
-- 判定是否满足重叠超量召唤条件的怪兽过滤函数（自己墓地暗属性怪兽只有5只，且场上存在5星以上的龙族·暗属性怪兽）
function c78144171.ovfilter(c)
	-- 检查自己墓地的暗属性怪兽数量是否刚好为5只，若不为5只则不能进行重叠超量召唤
	if Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)~=5 then return false end
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(5)
end
-- 重叠超量召唤时的额外操作函数，用于注册1回合1次重叠超量召唤的玩家标识
function c78144171.xyzop(e,tp,chk)
	-- 检查本回合是否已经使用过该重叠超量召唤方式
	if chk==0 then return Duel.GetFlagEffect(tp,78144171)==0 end
	-- 给玩家注册本回合已使用过该重叠超量召唤方式的全局标识（誓约效果，持续到回合结束）
	Duel.RegisterFlagEffect(tp,78144171,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 效果①的发动代价：取除这张卡的1个超量素材
function c78144171.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的发动准备：选择对方场上1张卡作为对象，并确认自己墓地有可除外的卡
function c78144171.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为破坏对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查自己墓地是否存在可以除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息，包含选中的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置除外效果的操作信息，包含从自己墓地除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_GRAVE)
end
-- 效果①的效果处理：使自身不能攻击，破坏对象卡，之后从自己墓地除外1张卡
function c78144171.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个效果的发动后，直到回合结束时这张卡不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	-- 获取发动的对象卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与效果相关，并将其破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 中断效果处理，使后续的除外处理与破坏处理不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 玩家从自己墓地选择1张不受王家长眠之谷影响且可以除外的卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的墓地卡片表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
