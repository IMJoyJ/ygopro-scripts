--ゲーミング・ゲーマーGG
-- 效果：
-- 4星机械族怪兽×2
-- 这张卡特殊召唤的场合：可以把对方场上的怪兽全部变成表侧攻击表示。
-- 对方场上·墓地有怪兽存在的场合：可以把这张卡1个超量素材取除；从自己的卡组·额外卡组把1只机械族怪兽送去墓地，那之后，可以适用以下效果。
-- ●选自己墓地1只机械族超量怪兽，这张卡直到结束阶段当作和那只怪兽同名卡使用。
-- 「游戏玩家GG」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化效果函数，设置XYZ召唤手续并注册两个效果
function s.initial_effect(c)
	-- 添加XYZ召唤手续，使用机械族怪兽作为素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),4,2)
	c:EnableReviveLimit()
	-- 效果1：特殊召唤成功时触发，将对方场上所有里侧守备表示怪兽变为表侧攻击表示
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变成攻击表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	-- 效果2：场上的机械族超量怪兽可以发动，消耗1个超量素材并从卡组/额外卡组送1只机械族怪兽到墓地，之后可变更自身卡名
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
-- 判断是否对方场上存在里侧守备表示的怪兽
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在里侧守备表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有里侧守备表示怪兽组成的卡片组
	local sg=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息为改变表示形式效果，目标为获取到的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,sg:GetCount(),0,0)
end
-- 处理表侧攻击表示的效果操作函数
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的所有里侧守备表示怪兽组成的卡片组
	local sg=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		-- 遍历怪兽组中的每张怪兽卡
		for sc in aux.Next(sg) do
			-- 将当前怪兽变为表侧攻击表示
			Duel.ChangePosition(sc,POS_FACEUP_ATTACK)
		end
	end
end
-- 过滤器函数，用于判断是否为怪兽类型
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER)
end
-- 条件函数，检查对方场上或墓地是否存在怪兽
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上或墓地是否存在至少1只怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
end
-- 费用函数，检查并移除自身1个超量素材作为发动代价
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤器函数，用于筛选可以送去墓地的机械族怪兽
function s.tgfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
end
-- 目标函数，检查是否可以从卡组/额外卡组选择1只机械族怪兽送去墓地
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以从卡组/额外卡组选择1只机械族怪兽送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息为送去墓地效果，目标为1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤器函数，用于筛选墓地中非当前卡名的机械族超量怪兽
function s.codefilter(c,ec)
	return not c:IsCode(ec:GetCode()) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ)
end
-- 主效果处理函数，执行送墓并选择是否变更卡名的操作
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组/额外卡组选择1只机械族怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	-- 判断是否成功将卡送去墓地且该卡在墓地中存在
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		and c:IsRelateToChain() and c:IsFaceup()
		-- 检查自己墓地中是否存在符合条件的机械族超量怪兽
		and Duel.IsExistingMatchingCard(s.codefilter,tp,LOCATION_GRAVE,0,1,nil,c)
		-- 询问玩家是否变更卡名
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否变更卡名？"
		-- 提示玩家选择效果对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 从墓地中选择1只符合条件的机械族超量怪兽作为目标
		local sg=Duel.SelectMatchingCard(tp,s.codefilter,tp,LOCATION_GRAVE,0,1,1,nil,c)
		local tc=sg:GetFirst()
		if tc then
			-- 显示选中卡片的动画效果
			Duel.HintSelection(sg)
			-- 创建一个使自身卡号变为所选怪兽卡号的效果
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
