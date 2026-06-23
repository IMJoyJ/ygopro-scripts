--Gaming Gamer GG
-- 效果：
-- 4星机械族怪兽×2
-- 这张卡特殊召唤的场合：可以把对方场上的怪兽全部变成表侧攻击表示。
-- 对方场上·墓地有怪兽存在的场合：可以把这张卡1个超量素材取除；从自己的卡组·额外卡组把1只机械族怪兽送去墓地，那之后，可以适用以下效果。
-- ●选自己墓地1只机械族超量怪兽，这张卡直到结束阶段当作和那只怪兽同名卡使用。
-- 「游戏玩家GG」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：设置超量召唤手续、限制复活、注册特殊召唤成功时的全场转表侧攻击的诱发选发效果，以及注册在怪兽区发动的送墓并复制卡名的起动效果。
function s.initial_effect(c)
	-- 为该卡添加超量召唤手续：使用等级为4的2只机械族怪兽进行叠放。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),4,2)
	c:EnableReviveLimit()
	-- 这张卡特殊召唤的场合：可以把对方场上的怪兽全部变成表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变成攻击表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	-- 对方场上·墓地有怪兽存在的场合：可以把这张卡1个超量素材取除；从自己的卡组·额外卡组把1只机械族怪兽送去墓地，那之后，可以适用以下效果。●选自己墓地1只机械族超量怪兽，这张卡直到结束阶段当作和那只怪兽同名卡使用。
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
-- 表示形式变更效果的发动准备与检查：检查对方场上是否存在守备表示的怪兽。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查对方场上是否存在至少1只守备表示的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有守备表示的怪兽组成卡片组。
	local sg=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：包含对符合条件的对方场上怪兽变更为表侧攻击表示的操作。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,sg:GetCount(),0,0)
end
-- 表示形式变更效果的处理：将对方场上所有的守备表示怪兽变更为表侧攻击表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有当前呈守备表示的怪兽组成卡片组。
	local sg=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		-- 遍历对方场上所有的守备表示怪兽。
		for sc in aux.Next(sg) do
			-- 将目标的表示形式变更为表侧攻击表示。
			Duel.ChangePosition(sc,POS_FACEUP_ATTACK)
		end
	end
end
-- 过滤条件：属于怪兽卡。
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER)
end
-- 判断送去墓地效果的发动条件是否满足：对方的场上或墓地存在至少1只怪兽。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上或者对方墓地中是否存在怪兽卡。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
end
-- 送去墓地效果的发动代价：取除这张卡的1个超量素材。
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：属于机械族怪兽且可以送去墓地。
function s.tgfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
end
-- 送去墓地效果的发动准备与检查：在效果发动时，检查自己卡组或额外卡组中是否存在机械族怪兽可以送去墓地。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查自己卡组或额外卡组中是否存在至少1只能够送去墓地的机械族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息：包含从卡组或额外卡组将卡片送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤条件：属于机械族超量怪兽且卡名与本卡不同。
function s.codefilter(c,ec)
	return not c:IsCode(ec:GetCode()) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ)
end
-- 送去墓地效果的处理：从自己的卡组或额外卡组将1只机械族怪兽送去墓地，之后可选择将自己墓地中的1只不同的机械族超量怪兽作为对象，直到结束阶段当作该怪兽的同名卡使用。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组或额外卡组中选择1只满足条件的机械族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	-- 如果选中了卡片，成功通过效果将其送去墓地，且卡片成功到达墓地。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		and c:IsRelateToChain() and c:IsFaceup()
		-- 检查自己墓地中是否存在满足卡名复制过滤条件的其他机械族超量怪兽。
		and Duel.IsExistingMatchingCard(s.codefilter,tp,LOCATION_GRAVE,0,1,nil,c)
		-- 询问玩家是否继续适用将这张卡当做同名卡使用的效果。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否变更卡名？"
		-- 提示玩家选择同名化效果作用的目标卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 从自己墓地中选择1只满足条件的机械族超量怪兽。
		local sg=Duel.SelectMatchingCard(tp,s.codefilter,tp,LOCATION_GRAVE,0,1,1,nil,c)
		local tc=sg:GetFirst()
		if tc then
			-- 手动为所选的墓地目标怪兽显示选中光圈动画。
			Duel.HintSelection(sg)
			-- ●选自己墓地1只机械族超量怪兽，这张卡直到结束阶段当作和那只怪兽同名卡使用。
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
