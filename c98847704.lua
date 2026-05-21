--拘束解放波
-- 效果：
-- 选择自己场上表侧表示存在的1张装备魔法卡发动。选择的装备魔法卡和对方场上盖放的魔法·陷阱卡全部破坏。
function c98847704.initial_effect(c)
	-- 选择自己场上表侧表示存在的1张装备魔法卡发动。选择的装备魔法卡和对方场上盖放的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c98847704.target)
	e1:SetOperation(c98847704.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的装备卡（若为陷阱卡则必须是曾作为怪兽存在的卡，如陷阱怪兽）。
function c98847704.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP)
		and (not c:IsType(TYPE_TRAP) or c:IsPreviousLocation(LOCATION_MZONE))
end
-- 过滤里侧表示的卡片。
function c98847704.filter2(c)
	return c:IsFacedown()
end
-- 效果发动时的合法性检测与对象选择处理。
function c98847704.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c98847704.filter1(chkc) end
	-- 检查自己场上是否存在可作为对象的表侧表示装备魔法卡。
	if chk==0 then return Duel.IsExistingTarget(c98847704.filter1,tp,LOCATION_SZONE,0,1,nil)
		-- 检查对方场上是否存在至少1张盖放的魔法·陷阱卡。
		and Duel.IsExistingMatchingCard(c98847704.filter2,tp,0,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示的装备魔法卡作为效果的对象。
	local g=Duel.SelectTarget(tp,c98847704.filter1,tp,LOCATION_SZONE,0,1,1,nil)
	-- 获取对方场上所有盖放的魔法·陷阱卡。
	local dg=Duel.GetMatchingGroup(c98847704.filter2,tp,0,LOCATION_SZONE,nil)
	dg:Merge(g)
	-- 设置破坏操作的信息，包含选中的装备卡和对方场上盖放的魔陷卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果处理的执行函数，破坏选中的装备卡和对方场上所有盖放的魔陷卡。
function c98847704.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为对象的装备魔法卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 获取效果处理时对方场上所有盖放的魔法·陷阱卡。
		local dg=Duel.GetMatchingGroup(c98847704.filter2,tp,0,LOCATION_SZONE,nil)
		dg:AddCard(tc)
		-- 将选中的装备卡和对方场上盖放的魔陷卡全部破坏。
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
