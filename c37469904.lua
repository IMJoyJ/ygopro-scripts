--デュエリスト・アドベント
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己或对方的灵摆区域有卡存在的场合才能发动。从卡组把1只「灵摆」灵摆怪兽或1张「灵摆」魔法·陷阱卡加入手卡。
function c37469904.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己或对方的灵摆区域有卡存在的场合才能发动。从卡组把1只「灵摆」灵摆怪兽或1张「灵摆」魔法·陷阱卡加入手卡。
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
-- 此条件函数判断自己或对方的灵摆区域是否有卡存在，作为效果的发动条件。
function c37469904.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回双方灵摆区域卡片总数是否大于0。
	return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,LOCATION_PZONE)>0
end
-- 定义检索过滤条件：卡名含有「灵摆」字段，且为灵摆怪兽或灵摆魔法·陷阱卡，并且可以被加入手卡。
function c37469904.filter(c)
	return c:IsSetCard(0xf2) and c:IsType(TYPE_PENDULUM+TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动时的目标选择函数：判断卡组是否存在符合条件的卡，并设置将卡加入手卡的操作信息。
function c37469904.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段，确认卡组中存在1张以上符合条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c37469904.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时将执行的回手牌操作信息，用于后续时点检测和发动确认。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时从卡组挑选1张符合条件的「灵摆」卡片加入手卡，若选择成功则给对方确认。
function c37469904.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中筛选并选择1张符合条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c37469904.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
