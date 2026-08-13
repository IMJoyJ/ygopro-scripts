--アメイジング・ペンデュラム
-- 效果：
-- 「惊异灵摆」在1回合只能发动1张。
-- ①：自己的灵摆区域没有卡存在的场合才能发动。从自己的额外卡组把2只卡名不同的表侧表示的「魔术师」灵摆怪兽加入手卡。
function c37803970.initial_effect(c)
	-- 「惊异灵摆」在1回合只能发动1张。①：自己的灵摆区域没有卡存在的场合才能发动。从自己的额外卡组把2只卡名不同的表侧表示的「魔术师」灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37803970+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c37803970.condition)
	e1:SetTarget(c37803970.target)
	e1:SetOperation(c37803970.activate)
	c:RegisterEffect(e1)
end
-- 该函数判断发动条件：自己的灵摆区域没有卡存在。
function c37803970.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域的两个区域（0号位和1号位）均没有卡存在。
	return not Duel.GetFieldCard(tp,LOCATION_PZONE,0) and not Duel.GetFieldCard(tp,LOCATION_PZONE,1)
end
-- 定义可选卡条件：额外卡组中表侧表示的、属于「魔术师」系列的灵摆怪兽，且能够加入手卡。
function c37803970.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 发动时判定：额外卡组中是否存在至少2只卡名不同且满足thfilter条件的卡；若满足则设置本次效果将2张卡加入手卡的操作信息。
function c37803970.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取己方额外卡组中所有满足thfilter条件的卡组。
		local g=Duel.GetMatchingGroup(c37803970.thfilter,tp,LOCATION_EXTRA,0,nil)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置操作信息：本次效果将把2张卡加入手卡，来源为己方额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_EXTRA)
end
-- 效果处理时：从额外卡组选择2只卡名不同的符合条件的灵摆怪兽加入手卡，并让对手确认加入手卡的卡。
function c37803970.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方额外卡组中所有满足thfilter条件的卡组。
	local g=Duel.GetMatchingGroup(c37803970.thfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetClassCount(Card.GetCode)>=2 then
		-- 弹出选择提示，要求玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从可选卡组中通过aux.dncheck限定选择2张卡名不同的卡。
		local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g1)
	end
end
