--タキオン・トランスミグレイション
-- 效果：
-- 自己场上有「银河眼时空龙」怪兽存在的场合，这张卡的发动从手卡也能用。
-- ①：自己场上有「银河眼」怪兽存在的场合，连锁2以后才能发动。这张卡的发动时积累的连锁上的全部对方的怪兽的效果·魔法·陷阱卡的发动无效，用这个效果把发动无效的卡在场上存在的场合，那些全部回到卡组。
function c8038143.initial_effect(c)
	-- ①：自己场上有「银河眼」怪兽存在的场合，连锁2以后才能发动。这张卡的发动时积累的连锁上的全部对方的怪兽的效果·魔法·陷阱卡的发动无效，用这个效果把发动无效的卡在场上存在的场合，那些全部回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c8038143.condition)
	e1:SetTarget(c8038143.target)
	e1:SetOperation(c8038143.activate)
	c:RegisterEffect(e1)
	-- 自己场上有「银河眼时空龙」怪兽存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8038143,0))  --"适用「时空转生」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c8038143.handcon)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「银河眼」怪兽
function c8038143.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107b)
end
-- 发动条件：自己场上有「银河眼」怪兽存在，且连锁2以后、积累的连锁上有可以被无效的对方卡片的效果发动
function c8038143.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「银河眼」怪兽，若不存在则不能发动
	if not Duel.IsExistingMatchingCard(c8038143.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	for i=1,ev do
		-- 获取连锁序号为i的连锁效果及发动玩家
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		-- 判断该连锁是否由对方发动、是否为怪兽效果或魔法·陷阱卡的发动，且该发动是否可以被无效
		if tgp~=tp and (te:IsActiveType(TYPE_MONSTER) or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(i) then
			return true
		end
	end
	return false
end
-- 收集积累的连锁中所有满足条件的对方卡片，并设置无效与回卡组的操作信息
function c8038143.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ng=Group.CreateGroup()
	local dg=Group.CreateGroup()
	for i=1,ev do
		-- 获取连锁序号为i的连锁效果及发动玩家
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		-- 筛选出由对方发动的、可被无效的怪兽效果或魔陷卡的发动
		if tgp~=tp and (te:IsActiveType(TYPE_MONSTER) or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(i) then
			local tc=te:GetHandler()
			ng:AddCard(tc)
			if tc:IsOnField() and tc:IsRelateToEffect(te) then
				dg:AddCard(tc)
			end
		end
	end
	-- 将对应发动会被无效且在场上存在的卡设为效果处理的对象
	Duel.SetTargetCard(dg)
	-- 设置无效发动的操作信息，包含所有要被无效的卡片组
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,ng:GetCount(),0,0)
	-- 设置回到卡组的操作信息，包含所有在场上存在且要被无效的卡片组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,dg,dg:GetCount(),0,0)
end
-- 效果处理：依次无效积累的连锁上全部对方卡片的发动，并将其中在场上存在的卡全部回到卡组
function c8038143.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Group.CreateGroup()
	for i=1,ev do
		-- 获取连锁序号为i的连锁效果及发动玩家
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		-- 若该连锁为对方发动的怪兽效果或魔陷卡的发动，则将其发动无效
		if tgp~=tp and (te:IsActiveType(TYPE_MONSTER) or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.NegateActivation(i) then
			local tc=te:GetHandler()
			if tc:IsRelateToEffect(e) and tc:IsRelateToEffect(te) then
				dg:AddCard(tc)
			end
		end
	end
	-- 将被无效且在场上存在的卡全部送回持有者卡组并洗牌
	Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,tp,true)
end
-- 过滤条件：自己场上表侧表示的「银河眼时空龙」怪兽
function c8038143.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x307b)
end
-- 手卡发动条件：自己场上存在「银河眼时空龙」怪兽
function c8038143.handcon(e)
	-- 检查自己场上是否存在表侧表示的「银河眼时空龙」怪兽
	return Duel.IsExistingMatchingCard(c8038143.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
