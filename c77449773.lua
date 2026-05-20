--サイバネット・クロスワイプ
-- 效果：
-- ①：把自己场上1只电子界族怪兽解放，以场上1张卡为对象才能发动。那张卡破坏。
function c77449773.initial_effect(c)
	-- ①：把自己场上1只电子界族怪兽解放，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c77449773.cost)
	e1:SetTarget(c77449773.target)
	e1:SetOperation(c77449773.activate)
	c:RegisterEffect(e1)
end
-- Cost检查函数，通过设置Label为1来标记需要进行解放Cost的检测
function c77449773.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤不能作为破坏目标的卡（不能是作为解放Cost的怪兽的装备卡，且不能是这张卡自身）
function c77449773.desfilter(c,tc,ec)
	return c:GetEquipTarget()~=tc and c~=ec
end
-- 过滤可作为解放Cost的电子界族怪兽（该怪兽被解放后，场上必须还存在至少1张可以被选择为破坏目标的卡）
function c77449773.costfilter(c,ec,tp)
	-- 检查该卡是否为电子界族，且在将其排除（作为解放Cost）后，场上是否存在至少1个符合条件的可选择的破坏目标
	return c:IsRace(RACE_CYBERSE) and Duel.IsExistingTarget(c77449773.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,c,ec)
end
-- 效果发动时的目标选择与Cost支付处理函数
function c77449773.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查玩家场上是否存在至少1只满足过滤条件（解放后场上仍有可破坏目标）的可解放电子界族怪兽
			return Duel.CheckReleaseGroup(tp,c77449773.costfilter,1,c,c,tp)
		else
			-- （非Cost检测时）检查场上是否存在除这张卡以外的任意卡作为破坏目标
			return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 玩家选择1只满足条件的电子界族怪兽作为解放Cost
		local sg=Duel.SelectReleaseGroup(tp,c77449773.costfilter,1,1,c,c,tp)
		-- 将选择的怪兽解放
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置效果处理信息，表示该效果的操作为破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理（连锁解决）函数
function c77449773.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的破坏目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏作为对象的卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
