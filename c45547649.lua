--バード・フェイス
-- 效果：
-- 这张卡被战斗破坏送去墓地时，从卡组选1张「鹰身女郎」加入手卡。之后洗切卡组。
function c45547649.initial_effect(c)
	-- 登记卡片文本中记述的关联卡名「鹰身女郎」
	aux.AddCodeList(c,76812113)
	-- 这张卡被战斗破坏送去墓地时，从卡组选1张「鹰身女郎」加入手卡。之后洗切卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45547649,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c45547649.condition)
	e1:SetTarget(c45547649.target)
	e1:SetOperation(c45547649.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：确认这张卡当前位于墓地且是由于战斗破坏而送去墓地的
function c45547649.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤卡组中可检索的卡片：卡名为「鹰身女郎」且能够加入手卡
function c45547649.filter(c)
	return c:IsCode(76812113) and c:IsAbleToHand()
end
-- 效果发动合法性检查与操作信息设置：确认卡组中有可加入手卡的「鹰身女郎」，并登记从自己卡组将1张卡加入手卡的操作信息
function c45547649.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张满足条件的「鹰身女郎」
	if chk==0 then return Duel.IsExistingMatchingCard(c45547649.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次连锁包含从自己卡组将1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果处理：从自己卡组选择1张「鹰身女郎」加入手卡，并给对方玩家确认该卡
function c45547649.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家发送选择要加入手卡的卡片提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动玩家从自己卡组中选择1张「鹰身女郎」
	local g=Duel.SelectMatchingCard(tp,c45547649.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「鹰身女郎」以效果加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
