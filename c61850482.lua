--レベル調整
-- 效果：
-- 对方抽2张卡。自己墓地存在的名字中带有「LV」的1只怪兽，无视召唤条件特殊召唤。这个效果特殊召唤的怪兽，这个回合不能攻击也不能效果发动以及适用。
function c61850482.initial_effect(c)
	-- 对方抽2张卡。自己墓地存在的名字中带有「LV」的1只怪兽，无视召唤条件特殊召唤。这个效果特殊召唤的怪兽，这个回合不能攻击也不能效果发动以及适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c61850482.target)
	e1:SetOperation(c61850482.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中名字带有「LV」且能无视召唤条件特殊召唤的怪兽
function c61850482.filter(c,e,tp)
	return c:IsSetCard(0x41) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果发动时的目标选择与合法性检查函数
function c61850482.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c61850482.filter(chkc,e,tp) end
	-- 检查对方是否能抽2张卡，以及自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,2) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己墓地是否存在符合条件的「LV」怪兽作为效果对象
			and Duel.IsExistingTarget(c61850482.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「LV」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c61850482.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置效果处理信息为对方玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,0,0,1-tp,2)
end
-- 效果处理（发动成功后的具体执行）函数
function c61850482.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让对方玩家因效果抽2张卡
	Duel.Draw(1-tp,2,REASON_EFFECT)
	-- 中断当前效果处理，使后续的特殊召唤处理与抽卡不视为同时进行
	Duel.BreakEffect()
	local c=e:GetHandler()
	-- 获取在发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 尝试将目标怪兽无视召唤条件以表侧表示特殊召唤
	if Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽，这个回合不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 也不能效果...以及适用
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 也不能效果发动
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_TRIGGER)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
