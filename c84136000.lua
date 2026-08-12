--復活の墓穴
-- 效果：
-- 自己场上存在的怪兽被战斗破坏送去墓地时发动。自己和对方选择各自的墓地1只怪兽，守备表示在场上特殊召唤。这个效果特殊召唤的怪兽只要在场上表侧表示存在，表示形式不能改变。
function c84136000.initial_effect(c)
	-- 自己场上存在的怪兽被战斗破坏送去墓地时发动。自己和对方选择各自的墓地1只怪兽，守备表示在场上特殊召唤。这个效果特殊召唤的怪兽只要在场上表侧表示存在，表示形式不能改变。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c84136000.condition)
	e1:SetTarget(c84136000.target)
	e1:SetOperation(c84136000.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：在墓地、原本控制者为自己、因战斗破坏的怪兽
function c84136000.cfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE)
end
-- 发动条件：自己场上的怪兽被战斗破坏送去墓地时
function c84136000.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c84136000.cfilter,1,nil,tp)
end
-- 过滤条件：可以以守备表示特殊召唤的怪兽
function c84136000.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的对象选择与可行性检查
function c84136000.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否有空余的怪兽区域
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的怪兽
		and Duel.IsExistingTarget(c84136000.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查对方墓地是否存在可以特殊召唤的怪兽
		and Duel.IsExistingTarget(c84136000.spfilter,1-tp,LOCATION_GRAVE,0,1,nil,e,1-tp) end
	-- 提示自己选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 自己选择自己墓地1只怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c84136000.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 提示对方选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 对方选择其墓地1只怪兽作为效果对象
	local g2=Duel.SelectTarget(1-tp,c84136000.spfilter,1-tp,LOCATION_GRAVE,0,1,1,nil,e,1-tp)
	g1:Merge(g2)
	-- 设置特殊召唤2只怪兽的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 效果处理的执行函数
function c84136000.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	while tc do
		-- 若对象卡片仍与效果相关，则将其以表侧守备表示特殊召唤到其持有者的场上
		if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tc:GetControler(),tc:GetControler(),false,false,POS_FACEUP_DEFENSE) then
			-- 这个效果特殊召唤的怪兽只要在场上表侧表示存在，表示形式不能改变。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
		end
		tc=g:GetNext()
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
