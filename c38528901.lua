--氷結界の決起隊
-- 效果：
-- ①：把这张卡解放，以场上1只水属性怪兽为对象才能发动。那只水属性怪兽破坏，从卡组把1只「冰结界」怪兽加入手卡。
function c38528901.initial_effect(c)
	-- ①：把这张卡解放，以场上1只水属性怪兽为对象才能发动。那只水属性怪兽破坏，从卡组把1只「冰结界」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38528901,0))  --"破坏，检索"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c38528901.cost)
	e1:SetTarget(c38528901.target)
	e1:SetOperation(c38528901.operation)
	c:RegisterEffect(e1)
end
-- 发动代价函数：在检查阶段判断这张卡是否满足解放条件；若满足，则执行解放自身作为发动代价。
function c38528901.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放这张卡作为发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义破坏对象过滤条件：场上表侧表示且属性为水属性的怪兽。
function c38528901.desfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 定义检索过滤条件：卡名属于「冰结界」系列的怪兽卡，且能够加入手卡。
function c38528901.sfilter(c)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动目标的判定与选择：确认对象是否合法，检查场上存在可破坏的水属性怪兽且卡组存在可检索的「冰结界」怪兽，然后选择对象并设置破坏与检索的操作信息。
function c38528901.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c38528901.desfilter(chkc) end
	-- 检查场上是否存在1只除自身以外、可作为对象的水属性怪兽（取对象效果的对象候选）。
	if chk==0 then return Duel.IsExistingTarget(c38528901.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
		-- 检查卡组是否存在至少1只满足条件的「冰结界」怪兽。
		and Duel.IsExistingMatchingCard(c38528901.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向当前玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只水属性怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c38528901.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次连锁将破坏所选择的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本次连锁可能从卡组将1只怪兽加入手卡，该卡在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：先破坏取对象的水属性怪兽，破坏成功后再从卡组选1只「冰结界」怪兽加入手卡，并向对方确认。
function c38528901.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象卡（即要破坏的水属性怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果相关且仍为表侧水属性怪兽，然后将其破坏；只有破坏成功才执行后续检索。
	if tc:IsRelateToEffect(e) and c38528901.desfilter(tc) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 向当前玩家显示“请选择要加入手牌的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只满足检索条件的「冰结界」怪兽。
		local g=Duel.SelectMatchingCard(tp,c38528901.sfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡加入其持有者的手卡，原因为效果。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
