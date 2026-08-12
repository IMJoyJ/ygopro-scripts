--No.74 マジカル・クラウン－ミッシング・ソード
-- 效果：
-- 7星怪兽×2
-- ①：这张卡为对象的魔法·陷阱·怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。那之后，可以选场上1张卡破坏。
function c16037007.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为7的怪兽进行叠放，需要2只怪兽
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
-- 设置该卡的XYZ编号为74
aux.xyz_number[16037007]=74
-- 判断连锁是否满足发动条件，包括该卡未在战斗中被破坏、效果具有取对象属性、该卡在连锁对象中且该连锁可被无效
function c16037007.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 返回判断结果：对象卡片组存在且包含该卡，且该连锁可被无效
	return tg and tg:IsContains(e:GetHandler()) and Duel.IsChainNegatable(ev)
end
-- 支付发动费用，移除该卡1个超量素材作为代价
function c16037007.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果处理时的操作信息，包括使发动无效和可能的破坏效果
function c16037007.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏发动的卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 处理效果发动后的操作，包括使连锁无效、破坏发动的卡片，并可选择破坏场上一张卡
function c16037007.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行使连锁无效、检查发动卡片是否可破坏、破坏发动的卡片
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		-- 检查场上是否存在可破坏的卡片
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否选择破坏场上一张卡
			and Duel.SelectYesNo(tp,aux.Stringid(16037007,1)) then  --"是否要选择场上一张卡破坏？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择场上一张卡作为破坏目标
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			-- 显示所选卡片被选为对象的动画效果
			Duel.HintSelection(g)
			-- 将所选卡片破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
