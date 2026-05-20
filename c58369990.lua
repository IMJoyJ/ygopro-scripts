--凶星の魔術師
-- 效果：
-- ①：1回合1次，丢弃1张手卡，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡破坏，自己从卡组抽1张。
function c58369990.initial_effect(c)
	-- ①：1回合1次，丢弃1张手卡，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡破坏，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58369990,0))  --"魔陷破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(c58369990.cost)
	e1:SetTarget(c58369990.target)
	e1:SetOperation(c58369990.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价处理函数，检查并执行丢弃手卡的操作
function c58369990.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手卡中是否存在可以丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡作为效果发动的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义效果发动时的对象选择与可行性检查函数
function c58369990.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) end
	-- 检查发动玩家当前是否具有抽卡的能力
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查双方灵摆区域是否存在至少1张可以作为效果对象的目标卡片
		and Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	-- 向发动玩家发送提示信息，要求选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择双方灵摆区域的1张卡片作为当前效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,LOCATION_PZONE,1,1,nil)
	-- 设置当前连锁的操作信息，表明将要破坏1张卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置当前连锁的操作信息，表明发动玩家将要抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果处理函数，执行破坏对象卡片并抽卡的操作
function c58369990.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡片在效果处理时依然有效，并将其破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 在成功破坏卡片后，让发动玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
