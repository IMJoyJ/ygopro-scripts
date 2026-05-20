--スナイプストーカー
-- 效果：
-- 丢弃1张手卡，选择场上1张卡才能发动。掷1次骰子，1·6以外出现的场合，选择的卡破坏。
function c84290642.initial_effect(c)
	-- 丢弃1张手卡，选择场上1张卡才能发动。掷1次骰子，1·6以外出现的场合，选择的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84290642,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c84290642.cost)
	e1:SetTarget(c84290642.target)
	e1:SetOperation(c84290642.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价（Cost）函数，用于处理丢弃手卡的操作
function c84290642.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查手牌中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义效果的目标选择（Target）函数，用于确认发动条件并选择对象
function c84290642.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 在发动阶段（chk==0）检查场上是否存在至少1张可以作为对象选择的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向发动玩家发送提示信息，要求选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动玩家选择场上1张卡作为效果的对象
	Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息，声明此效果包含掷1次骰子的处理
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 定义效果处理（Operation）函数，执行掷骰子和破坏卡片的操作
function c84290642.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 让发动玩家掷1次骰子，并获取掷出的点数
		local d=Duel.TossDice(tp,1)
		if d~=1 and d~=6 then
			-- 因效果将对象卡破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
