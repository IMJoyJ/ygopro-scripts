--リモート・リボーン
-- 效果：
-- ①：以对方墓地1只怪兽为对象才能发动。那只怪兽在作为自己场上的连接怪兽所连接区的对方的主要怪兽区域特殊召唤。
function c54658815.initial_effect(c)
	-- ①：以对方墓地1只怪兽为对象才能发动。那只怪兽在作为自己场上的连接怪兽所连接区的对方的主要怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c54658815.target)
	e1:SetOperation(c54658815.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选自己场上表侧表示的连接怪兽
function c54658815.lkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 过滤函数：筛选对方墓地中可以特殊召唤到对方场上指定连接区域的怪兽
function c54658815.filter(c,e,tp,zone)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp,zone)
end
-- 效果①的发动准备与对象选择：计算自己连接怪兽指向的对方主要怪兽区域，并选择对方墓地1只怪兽作为对象
function c54658815.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=0
	-- 获取自己场上所有的表侧表示连接怪兽
	local lg=Duel.GetMatchingGroup(c54658815.lkfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历这些连接怪兽，计算它们所连接的对方主要怪兽区域的合集
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,bit.rshift(tc:GetLinkedZone(),16))
	end
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c54658815.filter(chkc,e,tp,zone) end
	-- 在发动阶段检测：是否存在可用的连接区域，且对方墓地是否存在可特殊召唤的对象
	if chk==0 then return zone~=0 and Duel.IsExistingTarget(c54658815.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp,zone) end
	-- 设置提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c54658815.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,zone)
	-- 设置操作信息：特殊召唤选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理：重新计算当前可用的连接区域，并将作为对象的怪兽特殊召唤到对方场上
function c54658815.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local zone=0
		-- 重新获取自己场上表侧表示的连接怪兽，以应对连锁中场上情况发生变化
		local lg=Duel.GetMatchingGroup(c54658815.lkfilter,tp,LOCATION_MZONE,0,nil)
		-- 重新遍历连接怪兽并计算当前可用的对方主要怪兽区域
		for tc in aux.Next(lg) do
			zone=bit.bor(zone,bit.rshift(tc:GetLinkedZone(),16))
		end
		-- 将目标怪兽以表侧表示特殊召唤到对方场上由连接怪兽指向的区域
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP,zone)
	end
end
