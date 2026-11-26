--サイバー・レイダー
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤时，从下列效果中选择1项发动：
-- ●选择场上1张装备在怪兽身上的装备卡并将其破坏。
-- ●选择场上1张装备在怪兽身上的装备卡并将其装备在这张卡身上。
function c39978267.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤时，从下列效果中选择1项发动： ●选择场上1张装备在怪兽身上的装备卡并将其破坏。 ●选择场上1张装备在怪兽身上的装备卡并将其装备在这张卡身上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39978267,0))  --"选择效果发动"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c39978267.target)
	e1:SetOperation(c39978267.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查卡片是否为当前装备于怪兽身上的装备卡
function c39978267.desfilter(c)
	return c:GetEquipTarget()
end
-- 过滤函数，检查装备卡当前是否装备于怪兽身上且能够正确装备给这张卡
function c39978267.eqfilter(c,ec)
	return c:GetEquipTarget() and c:CheckEquipTarget(ec)
end
-- 对象合法性复检，按此前所选分支确认魔陷区的对象卡仍满足破坏或转移装备的条件
function c39978267.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==1 then return chkc:IsLocation(LOCATION_SZONE) and c39978267.desfilter(chkc)
		else return chkc:IsLocation(LOCATION_SZONE) and c39978267.eqfilter(chkc,e:GetHandler()) end
	end
	if chk==0 then return true end
	local sel=0
	-- 检查双方魔陷区是否存在可破坏的装备卡，若存在则标记选项1可用
	if Duel.IsExistingMatchingCard(c39978267.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) then sel=sel+1 end
	-- 检查双方魔陷区是否存在可转移装备给这张卡的装备卡，若存在则标记选项2可用
	if Duel.IsExistingMatchingCard(c39978267.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e:GetHandler()) then sel=sel+2 end
	if sel==3 then
		-- 提示控制者选择要发动的效果分支
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39978267,0))  --"选择效果发动"
		-- 当两项效果均可发动时，让控制者选择破坏装备卡或将装备卡装备在这张卡身上
		sel=Duel.SelectOption(tp,aux.Stringid(39978267,1),aux.Stringid(39978267,2))+1  --"装备卡破坏/装备卡装备在这张卡身上"
	end
	e:SetLabel(sel)
	if sel==1 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 提示控制者选择场上1张要破坏的装备卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择双方魔陷区1张装备在怪兽身上的装备卡作为破坏对象
		local g=Duel.SelectTarget(tp,c39978267.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
		-- 设置破坏对象装备卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif sel==2 then
		e:SetCategory(0)
		-- 提示控制者选择场上1张要装备在这张卡身上的装备卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 选择双方魔陷区1张可转移装备给这张卡的装备卡作为对象
		local g=Duel.SelectTarget(tp,c39978267.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e:GetHandler())
	end
end
-- 效果处理，确认对象卡仍与效果关联后，按所选分支将其破坏或重新装备到这张卡身上
function c39978267.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then return end
	-- 获取作为对象选择的装备卡
	local tc=Duel.GetFirstTarget()
	if sel==1 then
		if tc and tc:IsRelateToEffect(e) then
			-- 将作为对象的装备卡依效果破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	else
		local c=e:GetHandler()
		if tc and tc:IsRelateToEffect(e) then
			-- 将作为对象的装备卡重新装备到这张卡身上
			Duel.Equip(tp,tc,c)
		end
	end
end
