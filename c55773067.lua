--はたき落とし
-- 效果：
-- 对方抽卡阶段时发动。对方的抽卡阶段抽的1张卡丢弃送去墓地。
function c55773067.initial_effect(c)
	-- 对方抽卡阶段时发动。对方的抽卡阶段抽的1张卡丢弃送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_HANDES_OPPO)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c55773067.condition)
	e1:SetTarget(c55773067.target)
	e1:SetOperation(c55773067.activate)
	c:RegisterEffect(e1)
end
-- 过滤触发事件，确保是对方玩家因规则（抽卡阶段通常抽卡）进行的抽卡
function c55773067.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and bit.band(r,REASON_RULE)~=0
end
-- 效果发动的目标确认与操作信息设置，将对方抽到的卡设为效果处理对象，并声明将要丢弃对方1张手牌
function c55773067.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方抽到的卡设定为当前连锁的处理对象
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
end
-- 效果处理，将对方抽到的卡（若有多张则由对方选择1张）作为效果丢弃送去墓地
function c55773067.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=eg:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()==0 then
	elseif sg:GetCount()==1 then
		-- 将该张被抽到的卡作为效果丢弃送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	else
		-- 提示对方玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,ep,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local dg=sg:Select(ep,1,1,nil)
		-- 将对方选择的1张卡作为效果丢弃送去墓地
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
