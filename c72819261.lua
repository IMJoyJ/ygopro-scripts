--エレメントセイバー・マロー
-- 效果：
-- ①：1回合1次，从手卡把1只「元素灵剑士」怪兽送去墓地才能发动。从卡组把「元素灵剑士·日炙」以外的1只「元素灵剑士」怪兽或者「灵神」怪兽送去墓地。
-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
function c72819261.initial_effect(c)
	-- ①：1回合1次，从手卡把1只「元素灵剑士」怪兽送去墓地才能发动。从卡组把「元素灵剑士·日炙」以外的1只「元素灵剑士」怪兽或者「灵神」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72819261,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c72819261.sgcost)
	e1:SetTarget(c72819261.sgtg)
	e1:SetOperation(c72819261.sgop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72819261,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(c72819261.atttg)
	e2:SetOperation(c72819261.attop)
	c:RegisterEffect(e2)
end
-- 过滤手卡（或卡组）中可作为发动代价送去墓地的「元素灵剑士」怪兽，且卡组中必须存在可送去墓地的目标怪兽
function c72819261.costfilter(c,tp)
	return c:IsSetCard(0x400d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 检查卡组中是否存在至少1只不与当前作为代价的卡相同的、可送去墓地的「元素灵剑士」或「灵神」怪兽
		and Duel.IsExistingMatchingCard(c72819261.filter,tp,LOCATION_DECK,0,1,c)
end
-- 效果①的发动代价处理函数，从手卡（或因「灵神统一」的效果从卡组）将1只「元素灵剑士」怪兽送去墓地
function c72819261.sgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否受到「灵神统一」效果的影响（允许从卡组将「元素灵剑士」送去墓地代替手卡）
	local fe=Duel.IsPlayerAffectedByEffect(tp,61557074)
	local loc=LOCATION_HAND
	if fe then loc=LOCATION_HAND+LOCATION_DECK end
	-- 步骤chk==0：检查是否存在可作为代价送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c72819261.costfilter,tp,loc,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张满足代价过滤条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,c72819261.costfilter,tp,loc,0,1,1,nil,tp):GetFirst()
	if tc:IsLocation(LOCATION_DECK) then
		-- 向对方玩家展示「灵神统一」的卡片，提示使用了其效果
		Duel.Hint(HINT_CARD,0,61557074)
		fe:UseCountLimit(tp)
	end
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(tc,REASON_COST)
end
-- 过滤卡组中除「元素灵剑士·日炙」以外的「元素灵剑士」怪兽或「灵神」怪兽
function c72819261.filter(c)
	return c:IsSetCard(0x400d,0x113) and not c:IsCode(72819261) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果①的发动检查与靶向函数，确认卡组中存在可送去墓地的怪兽并设置操作信息
function c72819261.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤chk==0：检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c72819261.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理函数，从卡组选择1只满足条件的怪兽送去墓地
function c72819261.sgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c72819261.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果②的发动检查与靶向函数，让玩家宣言1个属性并记录
function c72819261.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言1个与这张卡当前属性不同的属性
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
	e:SetLabel(att)
	-- 设置连锁处理信息：涉及墓地卡片状态变化
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理函数，使墓地的这张卡直到回合结束时变成宣言的属性
function c72819261.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 墓地的这张卡直到回合结束时变成宣言的属性
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
