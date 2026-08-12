--地霊術－「鉄」
-- 效果：
-- ①：把自己场上1只地属性怪兽解放，以那只怪兽以外的自己墓地1只4星以下的地属性怪兽为对象才能发动。那只地属性怪兽特殊召唤。
function c70156997.initial_effect(c)
	-- ①：把自己场上1只地属性怪兽解放，以那只怪兽以外的自己墓地1只4星以下的地属性怪兽为对象才能发动。那只地属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c70156997.cost)
	e1:SetTarget(c70156997.target)
	e1:SetOperation(c70156997.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上可解放的地属性怪兽（需考虑解放后是否能空出怪兽区域）
function c70156997.cfilter(c,ft,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果发动的代价：解放自己场上1只地属性怪兽
function c70156997.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否存在可解放的地属性怪兽（若怪兽区已满，则必须解放主要怪兽区中的怪兽来腾出位置）
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c70156997.cfilter,1,nil,ft,tp) end
	-- 玩家选择1只满足条件的可解放的地属性怪兽
	local g=Duel.SelectReleaseGroup(tp,c70156997.cfilter,1,1,nil,ft,tp)
	-- 解放选择的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- 过滤自己墓地4星以下的地属性且可以特殊召唤的怪兽
function c70156997.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标：选择自己墓地1只4星以下的地属性怪兽为对象
function c70156997.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c70156997.filter(chkc,e,tp) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查自己墓地是否存在满足条件的可特殊召唤的地属性怪兽（在cost阶段已解放怪兽，怪兽区必定有空位）
			return Duel.IsExistingTarget(c70156997.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		else
			-- 检查自己场上是否有空余的怪兽区域（非cost检测时）
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 且自己墓地存在满足条件的可特殊召唤的地属性怪兽
				and Duel.IsExistingTarget(c70156997.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		end
	end
	local ex=nil
	if e:GetLabel()==1 then
		ex=e:GetLabelObject()
	end
	-- 给玩家发送“请选择要特殊召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只4星以下的地属性怪兽作为对象（排除作为代价解放的那只怪兽）
	local g=Duel.SelectTarget(tp,c70156997.filter,tp,LOCATION_GRAVE,0,1,1,ex,e,tp)
	-- 设置效果处理时的操作信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	e:SetLabel(0)
end
-- 效果处理：将作为对象的怪兽特殊召唤
function c70156997.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若没有则效果不适用
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsAttribute(ATTRIBUTE_EARTH) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
