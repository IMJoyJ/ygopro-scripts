--メルフィータイム
-- 效果：
-- ①：把自己场上的兽族超量怪兽的超量素材任意数量取除，以最多有那个数量的对方场上的卡为对象才能发动。那些卡回到持有者手卡。自己场上的全部兽族超量怪兽的攻击力直到回合结束时上升因为这张卡发动而取除的超量素材数量×500。
function c82134632.initial_effect(c)
	-- ①：把自己场上的兽族超量怪兽的超量素材任意数量取除，以最多有那个数量的对方场上的卡为对象才能发动。那些卡回到持有者手卡。自己场上的全部兽族超量怪兽的攻击力直到回合结束时上升因为这张卡发动而取除的超量素材数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c82134632.cost)
	e1:SetTarget(c82134632.target)
	e1:SetOperation(c82134632.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示且可以取除超量素材的兽族超量怪兽
function c82134632.rmfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_BEAST) and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
-- 发动代价：任意数量取除自己场上兽族超量怪兽的超量素材，并记录取除的总数量
function c82134632.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100,0)
	-- 在chk==0（检查是否能发动）时，检查自己场上是否存在至少1只可以取除超量素材的兽族超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c82134632.rmfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	local ct=0
	local min=1
	while true do
		-- 提示玩家选择要取除超量素材的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
		-- 让玩家选择1只符合条件的兽族超量怪兽以取除其素材
		local sg=Duel.SelectMatchingCard(tp,c82134632.rmfilter,tp,LOCATION_MZONE,0,min,1,nil,tp)
		if #sg==0 then break end
		sg:GetFirst():RemoveOverlayCard(tp,1,1,REASON_COST)
		ct=ct+1
		min=0
	end
	e:SetLabel(100,ct)
end
-- 过滤条件：自己场上表侧表示的兽族超量怪兽
function c82134632.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_BEAST)
end
-- 效果的目标选择：选择最多与取除素材数量相同的对方场上的卡为对象
function c82134632.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local check,ct=e:GetLabel()
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then
		if check~=100 then return false end
		e:SetLabel(0,ct)
		-- 检查对方场上是否存在可以回到手牌的卡，且自己场上是否存在兽族超量怪兽
		return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) and Duel.IsExistingMatchingCard(c82134632.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择最多有取除素材数量的对方场上的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息：将选中的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：使作为对象的卡回到持有者手牌，并使自己场上全部兽族超量怪兽的攻击力上升
function c82134632.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与此效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将这些对象卡片送回持有者的手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
	local check,ct=e:GetLabel()
	-- 获取自己场上所有表侧表示的兽族超量怪兽
	local g=Duel.GetMatchingGroup(c82134632.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部兽族超量怪兽的攻击力直到回合结束时上升因为这张卡发动而取除的超量素材数量×500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ct*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
