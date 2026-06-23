--サイバー・レイダー
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤时，从下列效果中选择1项发动：
-- ●选择场上1张装备在怪兽身上的装备卡并将其破坏。
-- ●选择场上1张装备在怪兽身上的装备卡并将其装备在这张卡身上。
function c39978267.initial_effect(c)
	-- 创建一个诱发必发效果，用于处理通常召唤成功时的发动
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
-- 过滤函数，用于判断装备卡是否可以被破坏或装备
function c39978267.desfilter(c)
	return c:GetEquipTarget() or c:IsFaceup() and c:IsType(TYPE_EQUIP)
end
-- 过滤函数，用于判断装备卡是否可以装备给指定目标
function c39978267.eqfilter(c,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec)
end
-- 目标选择函数，根据效果选择类型决定目标过滤条件
function c39978267.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==1 then return chkc:IsLocation(LOCATION_SZONE) and c39978267.desfilter(chkc)
		else return chkc:IsLocation(LOCATION_SZONE) and c39978267.eqfilter(chkc,e:GetHandler()) end
	end
	if chk==0 then return true end
	local sel=0
	-- 检查场上是否存在可破坏的装备卡
	if Duel.IsExistingMatchingCard(c39978267.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) then sel=sel+1 end
	-- 检查场上是否存在可装备的装备卡
	if Duel.IsExistingMatchingCard(c39978267.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e:GetHandler()) then sel=sel+2 end
	if sel==3 then
		-- 提示玩家选择发动效果
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39978267,0))  --"选择效果发动"
		-- 让玩家从两个效果中选择一个
		sel=Duel.SelectOption(tp,aux.Stringid(39978267,1),aux.Stringid(39978267,2))+1  --"装备卡破坏/装备卡装备在这张卡身上"
	end
	e:SetLabel(sel)
	if sel==1 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 提示玩家选择要破坏的装备卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择满足条件的装备卡作为破坏目标
		local g=Duel.SelectTarget(tp,c39978267.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
		-- 设置操作信息，标记将要破坏装备卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif sel==2 then
		e:SetCategory(0)
		-- 提示玩家选择要装备的装备卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 选择满足条件的装备卡作为装备目标
		local g=Duel.SelectTarget(tp,c39978267.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e:GetHandler())
	end
end
-- 效果处理函数，根据选择的效果类型执行破坏或装备操作
function c39978267.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then return end
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if sel==1 then
		if tc and tc:IsRelateToEffect(e) then
			-- 将目标卡破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	else
		local c=e:GetHandler()
		if tc and tc:IsRelateToEffect(e) then
			-- 将目标卡装备给自身
			Duel.Equip(tp,tc,c)
		end
	end
end
