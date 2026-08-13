--移り気な仕立屋
-- 效果：
-- 把怪兽装备的1张装备卡，转换给1只别的能变成正确对象的怪兽。
function c43641473.initial_effect(c)
	-- 把怪兽装备的1张装备卡，转换给1只别的能变成正确对象的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_EQUIP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c43641473.target)
	e1:SetOperation(c43641473.operation)
	c:RegisterEffect(e1)
end
-- 筛选新的装备对象：要求怪兽表侧表示且该装备卡能够正确装备给它。
function c43641473.tcfilter(tc,ec)
	return tc:IsFaceup() and ec:CheckEquipTarget(tc)
end
-- 筛选可转移的装备卡：是装备卡、当前装备着怪兽，并且场上存在除当前装备对象外的另一只能正确装备该卡的怪兽。
function c43641473.ecfilter(c)
	-- 装备卡的筛选条件：是装备卡、当前有装备对象，且除该对象外还存在另一只表侧表示且可被该卡正确装备的怪兽。
	return c:IsType(TYPE_EQUIP) and c:GetEquipTarget()~=nil and Duel.IsExistingTarget(c43641473.tcfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c:GetEquipTarget(),c)
end
-- 发动时的目标选择处理：判断能否发动，选择1张符合条件的装备卡并记录，再选择1只新的正确装备对象。
function c43641473.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检查：场上是否存在至少1张可以作为对象的、满足ecfilter条件的装备卡。
	if chk==0 then return Duel.IsExistingTarget(c43641473.ecfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 显示“请选择一张装备卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(43641473,0))  --"请选择一张装备卡"
	-- 从双方魔陷区选择1张符合条件的装备卡作为效果对象。
	local g=Duel.SelectTarget(tp,c43641473.ecfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	local ec=g:GetFirst()
	e:SetLabelObject(ec)
	-- 显示“请选择要转移装备的对象”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(43641473,1))  --"请选择要转移装备的对象"
	-- 从双方怪兽区选择1只表侧表示且能被该装备卡正确装备的怪兽作为新的装备对象，并排除当前装备对象，同时将其设为连锁对象。
	local tc=Duel.SelectTarget(tp,c43641473.tcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,ec:GetEquipTarget(),ec)
end
-- 效果处理：取得连锁对象中的装备卡和新装备对象，若装备卡仍表侧且与效果关联，则将其装备给新的对象怪兽。
function c43641473.operation(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	-- 从当前连锁信息中取得本次效果的所有对象卡（装备卡与转移目标怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==ec then tc=g:GetNext() end
	if ec:IsFaceup() and ec:IsRelateToEffect(e) then
		-- 将装备卡ec装备给新的对象怪兽tc，完成装备转移。
		Duel.Equip(tp,ec,tc)
	end
end
