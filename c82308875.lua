--No.7 ラッキー・ストライプ
-- 效果：
-- 7星怪兽×3
-- ①：把这张卡1个超量素材取除才能发动。掷2次骰子。这张卡的攻击力直到对方回合结束时变成较大方的出现数目×700。出现的数目合计是7的场合，再从以下效果选1个适用。
-- ●这张卡以外的场上的卡全部送去墓地。
-- ●从手卡或者自己·对方的墓地选1只怪兽在自己场上特殊召唤。
-- ●自己从卡组抽3张，那之后选2张手卡丢弃。
function c82308875.initial_effect(c)
	-- 添加XYZ召唤手续：7星怪兽×3
	aux.AddXyzProcedure(c,nil,7,3)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。掷2次骰子。这张卡的攻击力直到对方回合结束时变成较大方的出现数目×700。出现的数目合计是7的场合，再从以下效果选1个适用。●这张卡以外的场上的卡全部送去墓地。●从手卡或者自己·对方的墓地选1只怪兽在自己场上特殊召唤。●自己从卡组抽3张，那之后选2张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82308875,0))
	e1:SetCategory(CATEGORY_DICE|CATEGORY_ATKCHANGE|CATEGORY_DRAW|CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE|CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c82308875.cost)
	e1:SetTarget(c82308875.target)
	e1:SetOperation(c82308875.operation)
	c:RegisterEffect(e1)
end
-- 设置该怪兽的“No.”编号为7
aux.xyz_number[82308875]=7
-- 定义效果发动的代价：把这张卡1个超量素材取除
function c82308875.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义效果发动的目标：检查并设置投掷骰子的操作信息
function c82308875.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为投掷2次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
end
-- 定义过滤条件：可以特殊召唤的怪兽
function c82308875.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果处理：投掷骰子，改变攻击力，若合计为7则选择适用后续效果
function c82308875.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 投掷2次骰子
	local d1,d2=Duel.TossDice(tp,2)
	if d2>d1 then d1,d2=d2,d1 end
	-- 这张卡的攻击力直到对方回合结束时变成较大方的出现数目×700
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(d1*700)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	c:RegisterEffect(e1)
	if d1+d2==7 then
		-- 检查场上是否存在除这张卡以外的卡
		local b1=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)>1
		-- 获取手卡以及双方墓地中可以特殊召唤的怪兽组（受王家长眠之谷影响）
		local spg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c82308875.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
		-- 检查自己场上是否有空怪兽区域且存在可特殊召唤的怪兽
		local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and spg:GetCount()>0
		-- 检查玩家是否可以抽3张卡
		local b3=Duel.IsPlayerCanDraw(tp,3)
		if not b1 and not b2 and not b3 then return end
		local op=0
		-- 仅能适用送去墓地效果时，强制选择该选项
		if b1 and not b2 and not b3 then op=Duel.SelectOption(tp,aux.Stringid(82308875,1))  --"这张卡以外的场上的卡全部送去墓地"
		-- 仅能适用特殊召唤效果时，强制选择该选项
		elseif not b1 and b2 and not b3 then op=Duel.SelectOption(tp,aux.Stringid(82308875,2))+1  --"从手卡或者墓地把1只怪兽特殊召唤"
		-- 仅能适用抽卡效果时，强制选择该选项
		elseif not b1 and not b2 and b3 then op=Duel.SelectOption(tp,aux.Stringid(82308875,3))+2  --"从卡组抽3张卡，那之后选2张手卡丢弃"
		-- 仅能适用送去墓地或特殊召唤效果时，让玩家从这两个选项中选择
		elseif b1 and b2 and not b3 then op=Duel.SelectOption(tp,aux.Stringid(82308875,1),aux.Stringid(82308875,2))  --"这张卡以外的场上的卡全部送去墓地/从手卡或者墓地把1只怪兽特殊召唤"
		-- 仅能适用送去墓地或抽卡效果时，让玩家从这两个选项中选择，并调整选项索引
		elseif b1 and not b2 and b3 then op=Duel.SelectOption(tp,aux.Stringid(82308875,1),aux.Stringid(82308875,3)) if op==1 then op=2 end  --"这张卡以外的场上的卡全部送去墓地/从卡组抽3张卡，那之后选2张手卡丢弃"
		-- 仅能适用特殊召唤或抽卡效果时，让玩家从这两个选项中选择，并调整选项索引
		elseif not b1 and b2 and b3 then op=Duel.SelectOption(tp,aux.Stringid(82308875,2),aux.Stringid(82308875,3))+1  --"从手卡或者墓地把1只怪兽特殊召唤/从卡组抽3张卡，那之后选2张手卡丢弃"
		-- 三个效果均能适用时，让玩家从三个选项中选择
		else op=Duel.SelectOption(tp,aux.Stringid(82308875,1),aux.Stringid(82308875,2),aux.Stringid(82308875,3)) end  --"这张卡以外的场上的卡全部送去墓地/从手卡或者墓地把1只怪兽特殊召唤/从卡组抽3张卡，那之后选2张手卡丢弃"
		if op==0 then
			-- 过滤获取场上除这张卡以外的所有卡
			local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
			-- 将获取的卡全部送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		elseif op==1 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=spg:Select(tp,1,1,nil)
			-- 将选中的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 自己从卡组抽3张卡
			Duel.Draw(tp,3,REASON_EFFECT)
			-- 中断当前效果，使之后的丢弃手卡处理不与抽卡同时进行
			Duel.BreakEffect()
			-- 玩家选择2张手卡丢弃
			Duel.DiscardHand(tp,aux.TRUE,2,2,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
