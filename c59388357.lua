--炎王炎環
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只炎属性怪兽和自己墓地1只炎属性怪兽为对象才能发动。作为对象的自己场上的怪兽破坏，作为对象的墓地的怪兽特殊召唤。
function c59388357.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只炎属性怪兽和自己墓地1只炎属性怪兽为对象才能发动。作为对象的自己场上的怪兽破坏，作为对象的墓地的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,59388357+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c59388357.target)
	e1:SetOperation(c59388357.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的炎属性怪兽，且该怪兽被破坏后能空出怪兽区域（或者原本就有空位）
function c59388357.desfilter(c,ft)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and (ft>0 or c:GetSequence()<5)
end
-- 过滤自己墓地可以特殊召唤的炎属性怪兽
function c59388357.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与可行性检查
function c59388357.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查自己场上是否存在符合条件的、可作为破坏对象的炎属性怪兽（若怪兽区已满，则该怪兽必须在主要怪兽区以确保破坏后能空出位置）
	if chk==0 then return ft>-1 and Duel.IsExistingTarget(c59388357.desfilter,tp,LOCATION_MZONE,0,1,nil,ft)
		-- 检查自己墓地是否存在符合条件的、可作为特殊召唤对象的炎属性怪兽
		and Duel.IsExistingTarget(c59388357.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只炎属性怪兽作为破坏对象
	local g1=Duel.SelectTarget(tp,c59388357.desfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只炎属性怪兽作为特殊召唤对象
	local g2=Duel.SelectTarget(tp,c59388357.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为破坏选中的场上怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 设置当前连锁的操作信息为特殊召唤选中的墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	e:SetLabelObject(g1:GetFirst())
end
-- 效果处理：破坏作为对象的场上怪兽，并特殊召唤作为对象的墓地怪兽
function c59388357.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的两个对象卡片
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	-- 检查场上的对象怪兽是否仍由自己控制且仍适用效果，将其破坏，若破坏成功且墓地的对象怪兽仍适用效果，则继续处理
	if tc1:IsControler(tp) and tc1:IsRelateToEffect(e) and Duel.Destroy(tc1,REASON_EFFECT)>0 and tc2:IsRelateToEffect(e) then
		-- 将作为对象的墓地怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end
