--ナイト・バタフライ・アサシン
-- 效果：
-- 4星怪兽×3
-- 1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力上升场上的超量素材数量×300的数值。
function c2191144.initial_effect(c)
	-- 为卡片添加等级为4、需要3只怪兽的XYZ召唤手续
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力上升场上的超量素材数量×300的数值。
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
-- 检查是否可以移除1个超量素材作为发动代价，并执行移除操作
function c2191144.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果目标，判断场上是否有超过1个超量素材
function c2191144.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有超过1个超量素材
	if chk==0 then return Duel.GetOverlayCount(tp,1,1)>1 end
end
-- 效果发动时，若卡片表侧表示且与效果相关，则根据场上超量素材数量提升攻击力
function c2191144.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 获取场上超量素材的数量
		local ct=Duel.GetOverlayCount(tp,1,1)
		if ct>0 then
			-- 将攻击力提升场上超量素材数量×300的数值
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
