--機甲忍法ゴールド・コンバージョン
-- 效果：
-- 自己场上有名字带有「忍法」的卡存在的场合才能发动。自己场上的名字带有「忍法」的卡全部破坏。那之后，从卡组抽2张卡。
function c16272453.initial_effect(c)
	-- 自己场上有名字带有「忍法」的卡存在的场合才能发动。自己场上的名字带有「忍法」的卡全部破坏。那之后，从卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c16272453.condition)
	e1:SetTarget(c16272453.target)
	e1:SetOperation(c16272453.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：该卡为表侧表示且字段为「忍法」（0x61），用于检索场上符合条件的表侧忍法卡。
function c16272453.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x61)
end
-- 发动条件函数：检查我方场上是否存在表侧表示且字段为「忍法」的卡，以满足“自己场上有名字带有「忍法」的卡存在的场合才能发动”。
function c16272453.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方场上（LOCATION_ONFIELD）是否存在至少1张满足cfilter（表侧且字段「忍法」）的卡。
	return Duel.IsExistingMatchingCard(c16272453.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 筛选条件：该卡为表侧表示且字段为「忍法」（0x61），用于后续处理时取得将被破坏的忍法卡。
function c16272453.dfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x61)
end
-- 发动时的目标/操作登记函数：检查是否可以抽卡，获取将破坏的忍法卡集合，并登记破坏与抽卡的操作信息。
function c16272453.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：在chk==0时，确认玩家tp是否可以进行2张抽卡，若不能则效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 取得我方场上除本卡（e:GetHandler()）以外所有表侧且字段为「忍法」的卡，作为本次破坏的对象集合。
	local g=Duel.GetMatchingGroup(c16272453.dfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	-- 登记破坏操作信息，targets为g（获取到的忍法卡），count为g中卡片数量，用于后续时点判定及防止“不能破坏”等互动。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 登记抽卡操作信息，预计当前玩家tp抽2张卡，category为CATEGORY_DRAW。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：实际破坏场上的忍法卡；若破坏成功，则中断效果后抽2张卡。
function c16272453.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理阶段重新取得当前场上我方除本卡以外的表侧「忍法」卡（通过aux.ExceptThisCard排除效果发动者自身），供破坏使用。
	local g=Duel.GetMatchingGroup(c16272453.dfilter,tp,LOCATION_ONFIELD,0,aux.ExceptThisCard(e))
	-- 以效果原因（REASON_EFFECT）将g中的忍法卡破坏，返回值ct为实际被破坏的数量。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		-- 中断当前效果链，使破坏与后续抽卡视为两个独立处理，以产生错时点，避免两张处理同时进行影响时点判断。
		Duel.BreakEffect()
		-- 以效果原因（REASON_EFFECT）让玩家tp从卡组抽2张卡。
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
