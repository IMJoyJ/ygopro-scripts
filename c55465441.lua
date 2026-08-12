--ギブ＆テイク
-- 效果：
-- ①：以自己墓地1只怪兽和自己场上1只表侧表示怪兽为对象才能发动。作为对象的墓地的怪兽在对方场上守备表示特殊召唤，作为对象的场上的怪兽的等级直到回合结束时上升那只特殊召唤的怪兽的等级数值。
function c55465441.initial_effect(c)
	-- ①：以自己墓地1只怪兽和自己场上1只表侧表示怪兽为对象才能发动。作为对象的墓地的怪兽在对方场上守备表示特殊召唤，作为对象的场上的怪兽的等级直到回合结束时上升那只特殊召唤的怪兽的等级数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c55465441.target)
	e1:SetOperation(c55465441.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中等级大于0且可以特殊召唤到对方场上表侧守备表示的怪兽
function c55465441.filter(c,e,tp)
	return c:GetLevel()>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- 过滤自己场上表侧表示且有等级的怪兽
function c55465441.filter2(c)
	return c:IsFaceup() and c:IsLevelAbove(0)
end
-- 效果发动时的对象选择与合法性检测
function c55465441.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定对方场上是否有可用于特殊召唤的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 判定自己场上是否存在满足条件的表侧表示怪兽作为对象
		and Duel.IsExistingTarget(c55465441.filter2,tp,LOCATION_MZONE,0,1,nil)
		-- 判定自己墓地是否存在满足特殊召唤条件的怪兽作为对象
		and Duel.IsExistingTarget(c55465441.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为特殊召唤的对象
	local g1=Duel.SelectTarget(tp,c55465441.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为等级上升的对象
	local g2=Duel.SelectTarget(tp,c55465441.filter2,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g2:GetFirst())
	-- 设置效果处理信息为特殊召唤选中的墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
end
-- 效果处理的核心逻辑，包含特殊召唤和等级上升的处理
function c55465441.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	-- 获取当前连锁中被选择为对象的所有卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc2=g:GetFirst()
	if tc2==tc1 then tc2=g:GetNext() end
	-- 判定墓地的对象怪兽是否仍受效果影响，并将其在对方场上表侧守备表示特殊召唤
	if tc2:IsRelateToEffect(e) and Duel.SpecialSummon(tc2,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)~=0
		and tc1:IsFaceup() and tc1:IsRelateToEffect(e) then
		-- 作为对象的场上的怪兽的等级直到回合结束时上升那只特殊召唤的怪兽的等级数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(tc2:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc1:RegisterEffect(e1)
	end
end
