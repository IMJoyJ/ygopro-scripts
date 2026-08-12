--弩弓部隊
-- 效果：
-- ①：把自己场上1只怪兽解放，以对方场上1张卡为对象才能发动。那张卡破坏。
function c80584548.initial_effect(c)
	-- ①：把自己场上1只怪兽解放，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c80584548.cost)
	e1:SetTarget(c80584548.target)
	e1:SetOperation(c80584548.activate)
	c:RegisterEffect(e1)
end
-- 暂存发动标记，用于在target中区分是否需要检查/支付解放怪兽的代价
function c80584548.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤不为被解放怪兽的装备卡且不为本卡自身的对方场上的卡（防止解放怪兽后导致其装备卡离场，从而选择到非法对象）
function c80584548.desfilter(c,tc,ec)
	return c:GetEquipTarget()~=tc and c~=ec
end
-- 过滤可解放的怪兽，要求解放该怪兽后对方场上仍存在至少1张可作为破坏对象的卡
function c80584548.costfilter(c,ec,tp)
	-- 检查对方场上是否存在至少1张满足过滤条件（不为解放怪兽的装备卡且不为本卡自身）的可选择为对象的卡
	return Duel.IsExistingTarget(c80584548.desfilter,tp,0,LOCATION_ONFIELD,1,c,c,ec)
end
-- 效果发动时的处理（检查发动条件、支付解放代价、选择对方场上的1张卡作为对象并设置破坏操作信息）
function c80584548.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查自己场上是否存在至少1只满足过滤条件（解放后对方场上有合法对象）的可解放怪兽
			return Duel.CheckReleaseGroup(tp,c80584548.costfilter,1,c,c,tp)
		else
			-- 非发动时（如被其他卡的效果复制时）检查对方场上是否存在至少1张可选择为对象的卡
			return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,c)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 玩家选择1只满足过滤条件的可解放怪兽
		local sg=Duel.SelectReleaseGroup(tp,c80584548.costfilter,1,1,c,c,tp)
		-- 将选择的怪兽解放作为发动的代价
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,c)
	-- 设置效果处理的操作信息为“破坏选中的1张卡”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时的操作（获取对象卡，若该卡仍存在于场上则将其破坏）
function c80584548.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
