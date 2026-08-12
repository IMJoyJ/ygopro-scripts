--ゲーミング・ゲーマーGG
-- 效果：
-- 机械族4星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。对方场上的怪兽全部变成攻击表示。
-- ②：对方的场上或墓地有怪兽存在的场合，把这张卡1个超量素材取除才能发动。从卡组·额外卡组把1只机械族怪兽送去墓地。那之后，以下效果可以适用。
-- ●选自己墓地1只机械族超量怪兽，这张卡直到结束阶段当作和那只怪兽同名卡使用。
local s,id,o=GetID()
-- 初始化效果：注册超量召唤手续和特招变表示形式的诱发效果①、起动效果②（送墓并可当作同名卡使用，1回合1次）
function s.initial_effect(c)
	-- 设置超量召唤手续：用2只机械族4星怪兽进行叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),4,2)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。对方场上的怪兽全部变成攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变成攻击表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：对方的场上或墓地有怪兽存在的场合，把这张卡1个超量素材取除才能发动。从卡组·额外卡组把1只机械族怪兽送去墓地。那之后，以下效果可以适用。
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
-- ①效果的目标函数：确认对方场上存在守备表示的怪兽，检索对方场上全部守备表示怪兽并设置表示形式变更的操作信息
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：对方场上必须存在至少1只守备表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil) end
	-- 检索对方场上所有守备表示的怪兽组成卡片组
	local sg=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：声明本连锁将对检索出的守备表示怪兽执行表示形式变更
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,sg:GetCount(),0,0)
end
-- ①效果的处理函数：检索对方场上全部守备表示的怪兽，逐个变成攻击表示
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检索对方场上所有守备表示的怪兽组成卡片组
	local sg=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		-- 遍历检索出的守备表示怪兽卡片组，逐一处理
		for sc in aux.Next(sg) do
			-- 将该守备表示怪兽变成表侧攻击表示
			Duel.ChangePosition(sc,POS_FACEUP_ATTACK)
		end
	end
end
-- 过滤函数：该卡必须是怪兽卡
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER)
end
-- ②效果的发动条件：对方的场上或墓地存在至少1只怪兽
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上或墓地是否存在至少1只怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
end
-- ②效果的代价：取除这张卡的1个超量素材
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：该卡必须是机械族且能够送去墓地
function s.tgfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
end
-- ②效果的目标函数：确认卡组·额外卡组存在可送去墓地的机械族怪兽，并设置送墓的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己的卡组·额外卡组必须存在至少1只可以送去墓地的机械族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：声明本连锁将把自己的卡组·额外卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤函数：该卡必须是与这张卡不同名的机械族超量怪兽
function s.codefilter(c,ec)
	return not c:IsCode(ec:GetCode()) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ)
end
-- ②效果的处理函数：从卡组·额外卡组选1只机械族怪兽送去墓地，之后若自己墓地有不同名的机械族超量怪兽，可选1只使这张卡直到结束阶段当作其同名卡使用
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的卡组·额外卡组选择1只可以送去墓地的机械族怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	-- 确认已选出卡片、该卡确实被效果送去墓地且现在位于墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		and c:IsRelateToChain() and c:IsFaceup()
		-- 检查自己墓地是否存在与这张卡不同名的机械族超量怪兽
		and Duel.IsExistingMatchingCard(s.codefilter,tp,LOCATION_GRAVE,0,1,nil,c)
		-- 询问玩家是否变更这张卡的卡名（是否适用以下效果）
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否变更卡名？"
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 让玩家从自己墓地选择1只与这张卡不同名的机械族超量怪兽
		local sg=Duel.SelectMatchingCard(tp,s.codefilter,tp,LOCATION_GRAVE,0,1,1,nil,c)
		local tc=sg:GetFirst()
		if tc then
			-- 显示所选怪兽被指定为对象的动画并记录
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
