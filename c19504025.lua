--糾罪巧－再巧
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的卡组·墓地把1张「纠罪都市」在自己的场地区域表侧表示放置。自己场上有「纠罪都市」存在的场合，可以作为代替把最多有自己的灵摆区域的卡数量的对方场上的表侧表示卡的效果无效。
-- ②：这张卡在墓地存在的状态，对方把卡的效果发动的场合，把这张卡除外才能发动。把最多有自己的灵摆区域的卡数量的自己场上的「纠罪巧」怪兽变成里侧守备表示。
local s,id,o=GetID()
-- 注册卡片效果，创建两个效果：①发动效果和②触发效果
function s.initial_effect(c)
	-- 记录该卡与「纠罪都市」的关联，用于效果判定
	aux.AddCodeList(c,17621695)
	-- ①：从自己的卡组·墓地把1张「纠罪都市」在自己的场地区域表侧表示放置。自己场上有「纠罪都市」存在的场合，可以作为代替把最多有自己的灵摆区域的卡数量的对方场上的表侧表示卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，对方把卡的效果发动的场合，把这张卡除外才能发动。把最多有自己的灵摆区域的卡数量的自己场上的「纠罪巧」怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变成里侧守备"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.poscon)
	-- 设置效果发动的费用为将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查是否能将「纠罪都市」放置到场上
function s.stfilter(c,tp)
	return c:IsCode(17621695) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 过滤函数：检查自己灵摆区域是否有表侧表示的灵摆卡
function s.cfilter(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_PZONE)
end
-- 效果①的发动条件判断
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己卡组或墓地是否有「纠罪都市」
		return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
			-- 检查自己场上是否有「纠罪都市」
			or Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,17621695)
			-- 检查自己灵摆区域是否有表侧表示的灵摆卡
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,nil)
			-- 检查对方场上是否有可无效的卡
			and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
	end
end
-- 效果①的发动处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有「纠罪都市」
	if Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,17621695)
		-- 检查自己灵摆区域是否有表侧表示的灵摆卡
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,nil)
		-- 检查对方场上是否有可无效的卡
		and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查自己卡组或墓地是否有「纠罪都市」
		and (not Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
		-- 若无「纠罪都市」则询问是否无效对方卡的效果
		or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then  --"是否把卡无效？"
		-- 获取自己灵摆区域的卡数量
		local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_PZONE,0,nil)
		-- 提示玩家选择要无效的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 选择对方场上可无效的卡
		local g=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
		-- 显示所选卡被选为对象的动画
		Duel.HintSelection(g)
		-- 遍历所选卡组进行无效处理
		for tc in aux.Next(g) do
			-- 使目标卡的连锁无效
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使目标卡的效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 使目标卡的效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 使目标陷阱怪兽的效果无效
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e3)
			end
		end
	else
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 选择自己卡组或墓地的「纠罪都市」
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.stfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
		if tc then
			-- 获取自己场上的灵摆区域卡
			local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc then
				-- 将场上灵摆区域的卡送去墓地
				Duel.SendtoGrave(fc,REASON_RULE)
				-- 中断当前效果处理
				Duel.BreakEffect()
			end
			-- 将选中的卡放置到场上
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		end
	end
end
-- 触发效果的条件：对方发动卡的效果
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤函数：检查自己场上的「纠罪巧」怪兽是否可变为里侧守备表示
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsSetCard(0x1d4)
end
-- 效果②的发动条件判断
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区域是否有表侧表示的灵摆卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,nil)
		-- 检查自己场上有可变为里侧守备表示的「纠罪巧」怪兽
		and Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上的「纠罪巧」怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置操作信息：改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 设置操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_MSET,eg,1,0,0)
end
-- 效果②的发动处理
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己灵摆区域的卡数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_PZONE,0,nil)
	if ct>0 then
		-- 提示玩家选择要改变表示形式的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 选择自己场上的「纠罪巧」怪兽
		local sg=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,ct,nil)
		-- 显示所选怪兽被选为对象的动画
		Duel.HintSelection(sg)
		-- 将所选怪兽变为里侧守备表示
		Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
	end
end
