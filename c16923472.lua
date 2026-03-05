--ゼンマイハンター
-- 效果：
-- 自己的主要阶段时，把「发条猎人」以外的自己场上表侧表示存在的1只名字带有「发条」的怪兽解放才能发动。对方手卡随机1张送去墓地。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c16923472.initial_effect(c)
	-- 效果原文：自己的主要阶段时，把「发条猎人」以外的自己场上表侧表示存在的1只名字带有「发条」的怪兽解放才能发动。对方手卡随机1张送去墓地。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16923472,0))  --"手牌破坏"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c16923472.cost)
	e1:SetTarget(c16923472.target)
	e1:SetOperation(c16923472.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查怪兽是否表侧表示、卡名含发条字段且不是发条猎人本身
function c16923472.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x58) and not c:IsCode(16923472)
end
-- 效果发动时的费用处理：检查是否能选择满足条件的怪兽进行解放，并选择1只进行解放
function c16923472.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c16923472.costfilter,1,nil) end
	-- 从场上选择满足条件的1只怪兽进行解放
	local sg=Duel.SelectReleaseGroup(tp,c16923472.costfilter,1,1,nil)
	-- 将选中的怪兽以代價原因进行解放
	Duel.Release(sg,REASON_COST)
end
-- 效果发动时的目标确认：确认对方手牌数量不为0
function c16923472.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认对方手牌数量不为0
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)~=0 end
	-- 设置连锁操作信息：将对方手牌送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end
-- 效果发动时的处理：从对方手牌中随机选择1张送去墓地
function c16923472.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌区的所有卡
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将选中的卡以效果原因送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
