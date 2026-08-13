--ドラゴン・ウォリアー
-- 效果：
-- 「战士 戴·格雷法」＋「灵魂龙」
-- 融合召唤这只怪兽，必须用上面所写的卡融合召唤。只要这张卡在场上存在，可以支付1000分使通常陷阱的效果无效化。以这张卡为对象的魔法卡的效果无效并破坏。
function c49868263.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：必须用卡号75953262（战士 戴·格雷法）和67957315（灵魂龙）作为融合素材进行融合召唤。
	aux.AddFusionProcCode2(c,75953262,67957315,false,false)
	-- 只要这张卡在场上存在，可以支付1000分使通常陷阱的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49868263,0))  --"效果无效化"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c49868263.discon)
	e1:SetCost(c49868263.discost)
	e1:SetTarget(c49868263.distg)
	e1:SetOperation(c49868263.disop)
	c:RegisterEffect(e1)
	-- 以这张卡为对象的魔法卡的效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c49868263.disop2)
	c:RegisterEffect(e2)
	-- 以这张卡为对象的魔法卡的效果无效
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e3:SetTarget(c49868263.distg2)
	c:RegisterEffect(e3)
	-- 并破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e4:SetTarget(c49868263.distg2)
	c:RegisterEffect(e4)
end
-- e1的发动条件：此卡未被战斗破坏确定时，当有陷阱卡发动且该连锁效果可以被无效时，返回true。
function c49868263.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 判断当前连锁效果是否为陷阱卡的发动，且该连锁效果可以被无效化；满足则可发动无效效果。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetActiveType()==TYPE_TRAP and Duel.IsChainDisablable(ev)
end
-- e1的代价函数：在代价检测阶段确认可支付1000LP后，实际支付1000LP作为发动代价。
function c49868263.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：检查当前玩家能否支付1000LP。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000LP。
	Duel.PayLPCost(tp,1000)
end
-- e1的发动目标函数：无取对象，合法即返回true，并设置操作信息为无效该陷阱卡效果。
function c49868263.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将当前发动的陷阱卡纳入无效化处理，类别为效果无效（CATEGORY_DISABLE），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- e1的效果处理：将当前连锁的陷阱卡效果无效化。
function c49868263.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效连锁ev的效果。
	Duel.NegateEffect(ev)
end
-- e2的效果处理：当这张卡成为取对象魔法卡的对象时，在该魔法卡效果解决时将其无效并破坏。
function c49868263.disop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(re)
		and re:IsActiveType(TYPE_SPELL) and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		-- 获取连锁ev所取的对象卡组，用于检查这张卡是否在其对象中。
		local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		if g and g:IsContains(e:GetHandler()) then
			-- 尝试无效该魔法卡效果；若无效成功且该魔法卡仍与连锁效果关联，则继续将其破坏。
			if Duel.NegateEffect(ev,true) and re:GetHandler():IsRelateToEffect(re) then
				-- 以效果破坏该魔法卡。
				Duel.Destroy(re:GetHandler(),REASON_EFFECT)
			end
		end
	end
end
-- 筛选条件：判定c为魔法卡，且其效果对象中包含这张龙战士，用于指定受影响的魔法卡。
function c49868263.distg2(e,c)
	return c:GetCardTargetCount()>0 and c:IsType(TYPE_SPELL)
		and c:GetCardTarget():IsContains(e:GetHandler())
end
