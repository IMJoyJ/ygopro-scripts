--No.74 マジカル・クラウン－ミッシング・ソード
-- 效果：
-- 7星怪兽×2
-- ①：这张卡为对象的魔法·陷阱·怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。那之后，可以选场上1张卡破坏。
function c16037007.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：把2只7星怪兽叠放来XYZ召唤。
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- ①：这张卡为对象的魔法·陷阱·怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。那之后，可以选场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16037007,0))  --"无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c16037007.discon)
	e1:SetCost(c16037007.discost)
	e1:SetTarget(c16037007.distg)
	e1:SetOperation(c16037007.disop)
	c:RegisterEffect(e1)
end
-- 将这张卡的XYZ编号记录为74（用于No.相关效果判定）。
aux.xyz_number[16037007]=74
-- 发动条件判断：本卡不处于战斗破坏确定状态，且对方发动的效果是取对象效果并以本卡为对象，且该连锁可以被无效。
function c16037007.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁效果的对象卡组。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 返回对象卡组中是否存在本卡且该连锁可被无效。
	return tg and tg:IsContains(e:GetHandler()) and Duel.IsChainNegatable(ev)
end
-- 发动代价：取除本卡1个超量素材。
function c16037007.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 无选择目标；设置操作信息：本效果将无效并破坏对方发动的效果（若其可破坏）。
function c16037007.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：登记本连锁将对对方发动的效果进行无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：登记本连锁将破坏对方发动效果的那张卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：无效并破坏对方发动的效果；若成功，可再选场上一张卡破坏。
function c16037007.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若该发动被无效，且发动效果的那张卡仍与效果关联，且成功将其破坏，则进入后续追加破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		-- 检查双方场上是否存在至少1张卡（可破坏对象）。
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否选择场上一张卡破坏。
			and Duel.SelectYesNo(tp,aux.Stringid(16037007,1)) then  --"是否要选择场上一张卡破坏？"
			-- 中断当前效果处理，使后续追加破坏视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 从双方场上选择1张卡（任意表侧/里侧表示）作为追加破坏对象。
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			-- 展示所选卡并记录其被选为对象。
			Duel.HintSelection(g)
			-- 将所选卡以效果原因破坏。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
