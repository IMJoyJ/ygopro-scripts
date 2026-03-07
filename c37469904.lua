--デュエリスト・アドベント
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己或对方的灵摆区域有卡存在的场合才能发动。从卡组把1只「灵摆」灵摆怪兽或1张「灵摆」魔法·陷阱卡加入手卡。
function c37469904.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37469904+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c37469904.condition)
	e1:SetTarget(c37469904.target)
	e1:SetOperation(c37469904.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查自己或对方的灵摆区域是否有卡
function c37469904.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断灵摆区域是否有卡存在
	return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,LOCATION_PZONE)>0
end
-- 效果作用：定义过滤函数，筛选灵摆种族的魔法或陷阱卡
function c37469904.filter(c)
	return c:IsSetCard(0xf2) and c:IsType(TYPE_PENDULUM+TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果作用：设置效果的发动条件和目标
function c37469904.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检测卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c37469904.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 效果作用：设置连锁操作信息，指定将卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：执行效果的处理流程
function c37469904.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：从卡组选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c37469904.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 效果作用：将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 效果作用：确认对方查看所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
