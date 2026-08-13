--ラヴァル・ガンナー
-- 效果：
-- 这张卡召唤成功时，自己墓地有「熔岩炮击手」以外的名字带有「熔岩」的怪兽存在的场合，从自己卡组上面把最多5张卡送去墓地才能发动。这张卡的攻击力上升因为这个效果发动而送去墓地的名字带有「熔岩」的怪兽数量×200的数值。
function c11834972.initial_effect(c)
	-- 这张卡召唤成功时，自己墓地有「熔岩炮击手」以外的名字带有「熔岩」的怪兽存在的场合，从自己卡组上面把最多5张卡送去墓地才能发动。这张卡的攻击力上升因为这个效果发动而送去墓地的名字带有「熔岩」的怪兽数量×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11834972,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c11834972.condition)
	e1:SetCost(c11834972.cost)
	e1:SetOperation(c11834972.operation)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：判断怪兽是否为名字带有「熔岩」且不是「熔岩炮击手」的卡，用于检查墓地中是否存在满足发动条件的怪兽。
function c11834972.cfilter(c)
	return c:IsSetCard(0x39) and not c:IsCode(11834972)
end
-- 定义发动条件函数：检查自己墓地是否存在至少1张满足cfilter过滤条件的「熔岩」怪兽。
function c11834972.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行检查：检索自己墓地中是否存在至少1张「熔岩炮击手」以外的名字带有「熔岩」的怪兽，若存在则发动条件成立。
	return Duel.IsExistingMatchingCard(c11834972.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 定义代价函数：从自己卡组上面把最多5张卡送去墓地作为发动代价，并统计其中名字带有「熔岩」的怪兽数量，将其乘以200存入效果标签，供处理时上升攻击力。
function c11834972.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前合法性检查：至少能够从卡组上面丢弃1张卡作为代价才能发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	local ct={}
	for i=5,1,-1 do
		-- 从5到1依次检查是否能够丢弃i张卡作为代价，生成可选的丢弃数量列表，用于让玩家选择最多5张。
		if Duel.IsPlayerCanDiscardDeckAsCost(tp,i) then
			table.insert(ct,i)
		end
	end
	if #ct==1 then
		-- 若只有一种可选数量，则直接执行：从卡组上面丢弃该数量的卡去墓地作为代价。
		Duel.DiscardDeck(tp,ct[1],REASON_COST)
	else
		-- 提示玩家选择要送去墓地的卡组数量。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(11834972,1))  --"请选择送去墓地的数量"
		-- 让玩家宣言一个数字（可选数量），作为实际送去墓地的卡数。
		local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
		-- 按玩家宣言的数量从卡组上面丢弃卡去墓地作为代价。
		Duel.DiscardDeck(tp,ac,REASON_COST)
	end
	-- 获取刚才作为代价实际从卡组送去墓地的卡组对象，以便统计其中「熔岩」怪兽数量。
	local g=Duel.GetOperatedGroup()
	e:SetLabel(g:FilterCount(Card.IsSetCard,nil,0x39)*200)
end
-- 效果处理函数：若这张卡仍表侧表示且与发动效果关联，则给它赋予攻击力上升效果，上升值为cost阶段记录的数量×200。
function c11834972.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升因为这个效果发动而送去墓地的名字带有「熔岩」的怪兽数量×200的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(e:GetLabel())
		c:RegisterEffect(e1)
	end
end
