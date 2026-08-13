--ナイト・バタフライ・アサシン
-- 效果：
-- 4星怪兽×3
-- 1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力上升场上的超量素材数量×300的数值。
function c2191144.initial_effect(c)
	-- 为这张卡添加超量召唤手续：使用3只4星怪兽叠放召唤（对应超量召唤条件“4星怪兽×3”）。
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- 对应效果原文：“1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力上升场上的超量素材数量×300的数值。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2191144,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c2191144.atkcost)
	e1:SetTarget(c2191144.atktg)
	e1:SetOperation(c2191144.atkop)
	c:RegisterEffect(e1)
end
-- 发动代价处理：先检查这张卡是否有至少1个超量素材可作为代价取除；确认后实际取除1个超量素材（REASON_COST）。
function c2191144.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动条件判定：确认场上超量素材总数大于1才允许发动，避免取除素材后攻击力上升为0的无意义发动。
function c2191144.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：若为发动条件确认（chk==0），返回场上超量素材总数是否大于1。
	if chk==0 then return Duel.GetOverlayCount(tp,1,1)>1 end
end
-- 效果处理：若这张卡仍表侧表示且与发动时的效果存在关联，则获取当前场上超量素材数量ct，若ct>0则赋予这张卡攻击力上升ct×300的持续效果（直到离场/无效等重置）。
function c2191144.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 获取当前场上（双方场上）的超量素材总数，存入变量ct。
		local ct=Duel.GetOverlayCount(tp,1,1)
		if ct>0 then
			-- 对应效果原文：“这张卡的攻击力上升场上的超量素材数量×300的数值。”
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
