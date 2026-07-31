--ゲーミング・ゲーマーGG
-- 效果：
-- 4星机械族怪兽×2
-- 这张卡特殊召唤的场合：可以把对方场上的怪兽全部变成表侧攻击表示。
-- 对方场上·墓地有怪兽存在的场合：可以把这张卡1个超量素材取除；从自己的卡组·额外卡组把1只机械族怪兽送去墓地，那之后，可以适用以下效果。
-- ●选自己墓地1只机械族超量怪兽，这张卡直到结束阶段当作和那只怪兽同名卡使用。
-- 「游戏玩家GG」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 定义卡片的初始效果，包含特殊召唤成功时的位置变更效果和起动效果的代价、目标及处理逻辑。
function s.initial_effect(c)
	-- 为怪兽 c 添加等级 4、素材数量为 2 的机械族怪兽叠放召唤手续。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),4,2)
	c:EnableReviveLimit()
	-- "这张卡特殊召唤的场合：可以把对方场上的怪兽全部变成表侧攻击表示。"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变成攻击表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	-- "对方场上·墓地有怪兽存在的场合：可以把这张卡 1 个超量素材取除；从自己的卡组·额外卡组把 1 只机械族怪兽送去墓地，那之后，可以适用以下效果。 ●选自己墓地 1 只机械族超量怪兽，这张卡直到结束阶段当作和那只怪兽同名卡使用。"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tgcon)
	e2:SetCost(s.tgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- e1 效果的发动检查函数，确认对方场上是否存在至少一只里侧守备表示的怪兽以决定是否进行位置变更操作。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少一只里侧守备表示的怪兽，用于确定 e1 效果的操作对象数量。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有里侧守备表示的怪兽组成的卡片组，用于后续设置操作信息。
	local sg=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	-- 设置 e1 效果的操作信息，类别为位置变更，操作对象为目标怪兽组及其数量。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,sg:GetCount(),0,0)
end
-- e1 效果的实际处理函数，遍历对方场上的里侧守备表示怪兽并将其变为表侧攻击表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在处理阶段再次获取对方场上里侧守备表示的怪兽组，准备进行位置变更。
	local sg=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		-- 遍历怪兽组，对每一只符合条件的怪兽执行位置变更操作。
		for sc in aux.Next(sg) do
			-- 将当前遍历到的怪兽 sc 变为表侧攻击表示。
			Duel.ChangePosition(sc,POS_FACEUP_ATTACK)
		end
	end
end
-- 定义 e2 效果的发动条件过滤函数，用于检查怪兽卡是否存在于对方场上或墓地。
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER)
end
-- e2 效果的发动条件检查函数，确认对方场上或墓地是否存在怪兽卡。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 使用 s.cfilter 检查对方场上或墓地是否存在至少一只怪兽卡，满足则 e2 效果可发动。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
end
-- e2 效果的代价处理函数，检查并执行移除一张超量素材作为发动代价。
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- e2 效果的目标选择过滤函数，筛选卡组或额外卡组中可送去墓地的机械族怪兽。
function s.tgfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
end
-- e2 效果的目标检查函数，确认卡组或额外卡组中是否存在符合条件的机械族怪兽以决定操作数量。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或额外卡组中是否存在至少一只满足 s.tgfilter 条件的怪兽，用于确定 e2 效果的操作对象数量。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置 e2 效果的操作信息，类别为送去墓地，操作对象数量预计为 1。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 定义 e2 效果后续处理阶段的过滤函数，用于筛选墓地中除当前卡外同名的机械族超量怪兽（或泛指符合条件的怪兽）。
function s.codefilter(c,ec)
	return not c:IsCode(ec:GetCode()) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ)
end
-- e2 效果的实际处理函数，包含选择送去墓地的怪兽、确认是否变更卡名等逻辑。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家显示"请选择要送去墓地的卡"的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组或额外卡组中选择一只满足 s.tgfilter 条件的怪兽作为 e2 效果的操作对象。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	-- 检查选中的怪兽是否成功送入墓地，并确认当前卡与连锁相关且处于表侧攻击表示状态。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		and c:IsRelateToChain() and c:IsFaceup()
		-- 检查墓地中是否存在至少一只满足 s.codefilter 条件的怪兽，用于后续决定是否变更卡名。
		and Duel.IsExistingMatchingCard(s.codefilter,tp,LOCATION_GRAVE,0,1,nil,c)
		-- 向玩家询问"是否变更卡名"，若选择是则继续执行后续效果。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否变更卡名？"
		-- 向玩家显示"请选择效果的对象"的提示信息，用于选择要赋予卡名的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 让玩家从墓地中选择一只满足 s.codefilter 条件的怪兽，将其卡号赋予当前卡片。
		local sg=Duel.SelectMatchingCard(tp,s.codefilter,tp,LOCATION_GRAVE,0,1,1,nil,c)
		local tc=sg:GetFirst()
		if tc then
			-- 为选中的怪兽组显示被选定对象的动画效果，确认选择结果。
			Duel.HintSelection(sg)
			-- "●选自己墓地 1 只机械族超量怪兽，这张卡直到结束阶段当作和那只怪兽同名卡使用。"
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetValue(tc:GetCode())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
