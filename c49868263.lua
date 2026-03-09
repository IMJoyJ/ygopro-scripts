--ドラゴン・ウォリアー
-- 效果：
-- 「战士 戴·格雷法」＋「灵魂龙」
-- 融合召唤这只怪兽，必须用上面所写的卡融合召唤。只要这张卡在场上存在，可以支付1000分使通常陷阱的效果无效化。以这张卡为对象的魔法卡的效果无效并破坏。
function c49868263.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为75953262和67957315的两只怪兽为融合素材
	aux.AddFusionProcCode2(c,75953262,67957315,false,false)
	-- 只要这张卡在场上存在，可以支付1000分使通常陷阱的效果无效化
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
	-- 以这张卡为对象的魔法卡的效果无效并破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c49868263.disop2)
	c:RegisterEffect(e2)
	-- 场上的魔法卡效果被无效
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e3:SetTarget(c49868263.distg2)
	c:RegisterEffect(e3)
	-- 场上的魔法卡被破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e4:SetTarget(c49868263.distg2)
	c:RegisterEffect(e4)
end
-- 判断连锁是否为陷阱卡的发动且可被无效
function c49868263.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 连锁的卡片类型为陷阱卡且可被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetActiveType()==TYPE_TRAP and Duel.IsChainDisablable(ev)
end
-- 支付1000点LP作为发动代价
function c49868263.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000点LP
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000点LP
	Duel.PayLPCost(tp,1000)
end
-- 设置效果处理时的操作信息，将目标陷阱卡设为无效化对象
function c49868263.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定连锁中被无效的卡片
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 使连锁效果无效
function c49868263.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的效果无效
	Duel.NegateEffect(ev)
end
-- 处理连锁中魔法卡的发动，若目标包含此卡则使其无效并破坏
function c49868263.disop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(re)
		and re:IsActiveType(TYPE_SPELL) and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		-- 获取连锁中目标卡片组的信息
		local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		if g and g:IsContains(e:GetHandler()) then
			-- 使连锁效果无效并检查原卡是否还在场上
			if Duel.NegateEffect(ev,true) and re:GetHandler():IsRelateToEffect(re) then
				-- 将发动效果的魔法卡破坏
				Duel.Destroy(re:GetHandler(),REASON_EFFECT)
			end
		end
	end
end
-- 判断卡片是否为目标对象且为魔法卡
function c49868263.distg2(e,c)
	return c:GetCardTargetCount()>0 and c:IsType(TYPE_SPELL)
		and c:GetCardTarget():IsContains(e:GetHandler())
end
