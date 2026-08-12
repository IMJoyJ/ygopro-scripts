--ダーク・バグ
-- 效果：
-- 这张卡召唤成功时，选择自己墓地存在的1只3星的调整在自己场上特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c44341034.initial_effect(c)
	-- 诱发选发效果，通常召唤成功时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44341034,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c44341034.sumtg)
	e1:SetOperation(c44341034.sumop)
	c:RegisterEffect(e1)
end
-- 筛选满足等级为3、类型为调整且可以特殊召唤的卡片
function c44341034.filter(c,e,tp)
	return c:IsLevel(3) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标为己方墓地满足条件的卡片
function c44341034.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44341034.filter(chkc,e,tp) end
	-- 判断是否满足发动条件：己方墓地存在满足条件的卡片
	if chk==0 then return Duel.IsExistingTarget(c44341034.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 判断是否满足发动条件：己方场上存在空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1张墓地卡片作为效果对象
	local g=Duel.SelectTarget(tp,c44341034.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的发动，将目标卡片特殊召唤到场上
function c44341034.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡片
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡片是否有效且成功执行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 使特殊召唤的怪兽效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的怪兽效果无效化（针对效果）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
