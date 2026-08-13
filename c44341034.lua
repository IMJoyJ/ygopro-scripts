--ダーク・バグ
-- 效果：
-- 这张卡召唤成功时，选择自己墓地存在的1只3星的调整在自己场上特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c44341034.initial_effect(c)
	-- 这张卡召唤成功时，选择自己墓地存在的1只3星的调整在自己场上特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
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
-- 过滤函数：判断卡是否满足等级3、是调整怪兽，并且可以被当前效果特殊召唤。
function c44341034.filter(c,e,tp)
	return c:IsLevel(3) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标的合法性判定：若为已选目标，验证其仍在墓地、属于自己且满足过滤条件；若为发动时检查，确认存在合法目标且自己场上有空格。
function c44341034.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44341034.filter(chkc,e,tp) end
	-- 在发动条件检查阶段，确认自己墓地中存在至少1只满足条件的3星调整怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c44341034.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 同时确认自己场上有可用的主要怪兽区空格，用于特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 显示选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的3星调整怪兽，并将其设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c44341034.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将进行特殊召唤，处理对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得效果持有者与对象怪兽；若对象仍与效果关联，则将其以表侧表示特殊召唤到自己场上；特殊召唤成功时，给该怪兽附加效果无效化状态；最后完成特殊召唤流程。
function c44341034.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的第一张对象卡（即被选择的墓地调整怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽仍与效果关联，然后以表侧表示执行特殊召唤步骤；若成功，在后续代码中给它附加无效化效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤处理，正式将所有通过SpecialSummonStep暂定的怪兽特殊召唤成功，并触发相关时点。
	Duel.SpecialSummonComplete()
end
