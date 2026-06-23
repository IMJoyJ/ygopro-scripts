--アメイジング・ペンデュラム
-- 效果：
-- 「惊异灵摆」在1回合只能发动1张。
-- ①：自己的灵摆区域没有卡存在的场合才能发动。从自己的额外卡组把2只卡名不同的表侧表示的「魔术师」灵摆怪兽加入手卡。
function c37803970.initial_effect(c)
	-- 创建效果并注册给卡片，设置为魔陷发动、自由时点、发动次数限制为1次、条件为灵摆区域无卡、目标函数为target、发动函数为activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37803970+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c37803970.condition)
	e1:SetTarget(c37803970.target)
	e1:SetOperation(c37803970.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：自己的灵摆区域没有卡存在
function c37803970.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 自己的灵摆区域没有卡存在
	return not Duel.GetFieldCard(tp,LOCATION_PZONE,0) and not Duel.GetFieldCard(tp,LOCATION_PZONE,1)
end
-- 检索过滤函数：表侧表示的魔术师灵摆怪兽且可以送去手卡
function c37803970.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果目标处理：检查额外卡组中是否存在至少2只不同卡名的魔术师灵摆怪兽
function c37803970.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取满足条件的额外卡组中的魔术师灵摆怪兽组
		local g=Duel.GetMatchingGroup(c37803970.thfilter,tp,LOCATION_EXTRA,0,nil)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置连锁操作信息为将2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_EXTRA)
end
-- 效果发动处理：检索满足条件的2只不同卡名的魔术师灵摆怪兽并加入手牌
function c37803970.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的额外卡组中的魔术师灵摆怪兽组
	local g=Duel.GetMatchingGroup(c37803970.thfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetClassCount(Card.GetCode)>=2 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从满足条件的怪兽组中选择2只不同卡名的怪兽
		local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		-- 向对方确认选中的怪兽
		Duel.ConfirmCards(1-tp,g1)
	end
end
