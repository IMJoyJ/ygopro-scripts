--魔界劇団の楽屋入り
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的灵摆区域有2张「魔界剧团」卡存在的场合才能发动。从卡组选2只「魔界剧团」灵摆怪兽表侧表示加入自己的额外卡组（同名卡最多1张）。
function c59057953.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的灵摆区域有2张「魔界剧团」卡存在的场合才能发动。从卡组选2只「魔界剧团」灵摆怪兽表侧表示加入自己的额外卡组（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,59057953+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c59057953.condition)
	e1:SetTarget(c59057953.target)
	e1:SetOperation(c59057953.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：检查自己的灵摆区域是否存在2张「魔界剧团」卡
function c59057953.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域是否存在至少2张卡名含有「魔界剧团」的卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,2,nil,0x10ec)
end
-- 过滤函数：筛选卡组中的「魔界剧团」灵摆怪兽
function c59057953.filter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x10ec)
end
-- 效果发动的目标选择与合法性检测
function c59057953.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己卡组中所有的「魔界剧团」灵摆怪兽
		local g=Duel.GetMatchingGroup(c59057953.filter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置操作信息：预计将卡组中的2张卡送往额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选2只卡名不同的「魔界剧团」灵摆怪兽表侧表示加入额外卡组
function c59057953.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有的「魔界剧团」灵摆怪兽
	local g=Duel.GetMatchingGroup(c59057953.filter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	-- 提示玩家选择要加入额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(59057953,0))  --"请选择要加入自己额外卡组的卡"
	-- 让玩家从符合条件的卡片中选择2张卡名不同的卡
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选择的卡片表侧表示送往额外卡组
	Duel.SendtoExtraP(tg1,nil,REASON_EFFECT)
end
