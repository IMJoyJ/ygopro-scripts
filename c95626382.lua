--終獄龍機ⅩⅡ－ドラストリウス
-- 效果：
-- 8星怪兽×3
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。场上1只其他的表侧表示怪兽当作装备魔法卡使用给这张卡装备。
-- ②：这张卡1回合只有1次不会被战斗·效果破坏。
-- ③：对方把场上·墓地的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个效果无效。那之后，可以把对方场上1只表侧表示怪兽当作装备魔法卡使用给这张卡装备。
local s,id,o=GetID()
-- 注册卡片效果：设置XYZ召唤手续、①效果（超量召唤成功时装备场上怪兽）、②效果（一回合一次抗破坏）、③效果（无效对方场上/墓地怪兽效果并装备对方怪兽）。
function s.initial_effect(c)
	-- 设置XYZ召唤手续：需要3只8星怪兽。
	aux.AddXyzProcedure(c,nil,8,3)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合才能发动。场上1只其他的表侧表示怪兽当作装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡1回合只有1次不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(s.indct)
	c:RegisterEffect(e2)
	-- ③：对方把场上·墓地的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个效果无效。那之后，可以把对方场上1只表侧表示怪兽当作装备魔法卡使用给这张卡装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：这张卡超量召唤成功。
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤条件：场上表侧表示的怪兽（若是对方怪兽，则必须是可以转移控制权的怪兽）。
function s.eqfilter(c,tp)
	return c:IsFaceup() and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
-- ①效果的发动准备（检查魔陷区是否有空位，以及场上是否存在可装备的表侧表示怪兽）。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身魔陷区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在除自身以外的、满足装备条件的表侧表示怪兽。
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),tp) end
	-- 向对方玩家提示发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ①效果的处理：选择场上1只其他的表侧表示怪兽，作为装备卡装备给这张卡，并添加装备限制。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若魔陷区已无空位，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToChain() then return end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择场上1只除自身以外的、满足装备条件的表侧表示怪兽。
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,aux.ExceptThisCard(e),tp)
	local tc=g:GetFirst()
	if tc then
		-- 在场上为选中的卡片显示选中特效。
		Duel.HintSelection(g)
		-- 将选中的怪兽作为装备卡装备给这张卡，若装备失败则结束处理。
		if not Duel.Equip(tp,tc,c) then return end
		-- 当作装备魔法卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制：只能装备给该效果的拥有者（即这张卡）。
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 破坏抗性判定：适用于战斗或效果破坏。
function s.indct(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- ③效果的发动条件：对方发动场上或墓地的怪兽效果。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的发动位置。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep~=tp and (LOCATION_ONFIELD+LOCATION_GRAVE)&loc~=0
		-- 确认发动的效果是怪兽效果，且该效果可以被无效。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- ③效果的发动代价：取除这张卡的1个超量素材。
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ③效果的发动准备：设置效果无效的操作信息。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该发动效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 向对方玩家提示发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ③效果的处理：无效对方发动的效果，之后可以选对方场上1只表侧表示怪兽装备给这张卡。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 成功无效效果，且自身魔陷区有空位。
	if Duel.NegateEffect(ev) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且对方场上存在可装备的表侧表示怪兽。
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,0,LOCATION_MZONE,1,aux.ExceptThisCard(e),tp)
		and c:IsRelateToChain() and c:IsFaceup()
		-- 询问玩家是否选择将对方场上的怪兽装备。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把对方怪兽装备？"
		-- 中断效果处理，使后续的装备处理与无效效果不视为同时处理。
		Duel.BreakEffect()
		-- 提示玩家选择要装备的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 玩家选择对方场上1只满足装备条件的表侧表示怪兽。
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,0,LOCATION_MZONE,1,1,aux.ExceptThisCard(e),tp)
		local tc=g:GetFirst()
		if tc then
			-- 在场上为选中的卡片显示选中特效。
			Duel.HintSelection(g)
			-- 将选中的怪兽作为装备卡装备给这张卡，若装备失败则结束处理。
			if not Duel.Equip(tp,tc,c) then return end
			-- 可以把对方场上1只表侧表示怪兽当作装备魔法卡使用给这张卡装备。
			local e1=Effect.CreateEffect(c)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			tc:RegisterEffect(e1)
		end
	end
end
