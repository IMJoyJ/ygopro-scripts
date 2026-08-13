--糾罪巧－再巧
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的卡组·墓地把1张「纠罪都市」在自己的场地区域表侧表示放置。自己场上有「纠罪都市」存在的场合，可以作为代替把最多有自己的灵摆区域的卡数量的对方场上的表侧表示卡的效果无效。
-- ②：这张卡在墓地存在的状态，对方把卡的效果发动的场合，把这张卡除外才能发动。把最多有自己的灵摆区域的卡数量的自己场上的「纠罪巧」怪兽变成里侧守备表示。
local s,id,o=GetID()
-- 注册此卡的两个效果：e1为①的魔法卡发动效果（含同名卡1回合1次限制），e2为②的墓地诱发效果；同时登记文本中提到的「纠罪都市」的卡名信息。
function s.initial_effect(c)
	-- 将卡名17621695（纠罪都市）登记为这张卡文本中记载的卡名，便于规则处理涉及卡名记载的判定。
	aux.AddCodeList(c,17621695)
	-- 对应‘这个卡名的卡在1回合只能发动1张。①：从自己的卡组·墓地把1张「纠罪都市」在自己的场地区域表侧表示放置。自己场上有「纠罪都市」存在的场合，可以作为代替把最多有自己的灵摆区域的卡数量的对方场上的表侧表示卡的效果无效。’
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 对应‘②：这张卡在墓地存在的状态，对方把卡的效果发动的场合，把这张卡除外才能发动。把最多有自己的灵摆区域的卡数量的自己场上的「纠罪巧」怪兽变成里侧守备表示。’
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变成里侧守备"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.poscon)
	-- 设置②效果的发动代价：将墓地的这张卡除外，对应‘把这张卡除外才能发动’。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 定义「纠罪都市」的检索过滤条件：卡名为17621695、不是禁止卡且场上满足同名卡唯一性，用于从卡组·墓地选择可放置的「纠罪都市」。
function s.stfilter(c,tp)
	return c:IsCode(17621695) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 定义筛选灵摆区域的表侧表示卡的过滤条件，用于计算效果的可用数量上限。
function s.cfilter(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_PZONE)
end
-- 判定①效果能否发动：卡组·墓地有可放置的「纠罪都市」，或者（自己场上有「纠罪都市」、灵摆区有表侧卡且对方场上有可无效的表侧卡）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查从卡组·墓地放置「纠罪都市」的选项是否有可行对象。
		return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
			-- 检查替代无效分支的其中一个条件：自己场上存在表侧表示的「纠罪都市」。
			or Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,17621695)
			-- 检查自己灵摆区域是否有表侧表示卡，以确定无效数量上限是否至少为1。
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,nil)
			-- 检查对方场上是否存在可被无效的表侧表示卡。
			and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
	end
end
-- ①效果的实际处理：若满足替代条件且（无「纠罪都市」可放置或玩家选择无效），则选择对方场上最多为灵摆区卡数量的表侧卡使其效果无效；否则从卡组·墓地选1张「纠罪都市」放置到自己的场地区域，已有场地则先送墓。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自己场上是否有表侧「纠罪都市」，满足无效分支的前置条件。
	if Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,17621695)
		-- 判断自己灵摆区是否有表侧卡，保证无效数量上限大于0。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,nil)
		-- 判断对方场上是否有可无效的对象，保证无效分支可执行。
		and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查卡组·墓地是否不存在可放置的「纠罪都市」；若不存在则不再询问，直接执行无效分支。
		and (not Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
		-- 若仍有可放置的「纠罪都市」，由玩家选择是否以无效对方卡作为代替；选否则执行放置。
		or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then  --"是否把卡无效？"
		-- 统计自己灵摆区域表侧卡的数量，作为可选择无效的对方卡片数量上限。
		local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_PZONE,0,nil)
		-- 提示玩家进入选择无效对象的界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 从对方场上选择1至ct张可被无效的表侧表示卡。
		local g=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
		-- 显示无效对象的选择动画，并将其记录为当前效果的对象。
		Duel.HintSelection(g)
		-- 遍历所有被选择要无效的卡片。
		for tc in aux.Next(g) do
			-- 将与本回合连锁相关的该卡效果发动无效化，防止其后续发动影响。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 对应‘把最多有自己的灵摆区域的卡数量的对方场上的表侧表示卡的效果无效’，对选中的卡赋予效果无效状态。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 对应‘把最多有自己的灵摆区域的卡数量的对方场上的表侧表示卡的效果无效’，使选中的卡已经发动的效果也被无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 对应无效效果，若对象是陷阱怪兽，额外将其陷阱怪兽化状态无效。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e3)
			end
		end
	else
		-- 提示玩家进入选择要放置到场上的卡的界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从自己卡组·墓地选择1张「纠罪都市」（通过王家长眠之谷过滤），准备放置到场地区域。
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.stfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
		if tc then
			-- 取得自己场地区域当前的卡（场地区域为魔法陷阱区第6格）。
			local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc then
				-- 若已有场地卡，按规则将其送去墓地。
				Duel.SendtoGrave(fc,REASON_RULE)
				-- 中断当前效果处理，使旧场地送墓与新场地放置作为不同时点的处理。
				Duel.BreakEffect()
			end
			-- 将选中的「纠罪都市」以表侧表示放置到自己的场地区域。
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		end
	end
end
-- ②效果的发动条件：对方发动了卡的效果（rp为1-tp）。
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 定义「纠罪巧」怪兽的过滤条件：表侧表示、可以变成里侧守备表示、具有0x1d4的系列字段。
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsSetCard(0x1d4)
end
-- ②效果发动时点检查：自己灵摆区有表侧卡，且自己场上有可变成里侧守备的「纠罪巧」怪兽。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区是否存在表侧卡，作为可覆盖数量上限的依据。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,nil)
		-- 检查自己场上是否存在满足条件的「纠罪巧」怪兽。
		and Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 取得自己场上所有符合条件的「纠罪巧」怪兽组。
	local g=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置操作信息：效果将变更1只怪兽的表示形式，供相关卡片的连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 设置操作信息：效果包含里侧覆盖怪兽（CATEGORY_MSET），并将对方发动的效果连锁组eg登记为关联对象。
	Duel.SetOperationInfo(0,CATEGORY_MSET,eg,1,0,0)
end
-- ②效果的处理：按灵摆区表侧卡数量选择最多相同数量的「纠罪巧」怪兽，将它们全部变成里侧守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 统计自己灵摆区表侧卡的数量，作为可覆盖的「纠罪巧」怪兽数量上限。
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_PZONE,0,nil)
	if ct>0 then
		-- 提示玩家进入选择要改变表示形式的怪兽的界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 选择自己场上1至ct只满足条件的「纠罪巧」怪兽。
		local sg=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,ct,nil)
		-- 显示所选怪兽的选中动画，并记录为当前效果的对象。
		Duel.HintSelection(sg)
		-- 将选中的所有「纠罪巧」怪兽变成里侧守备表示。
		Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
	end
end
