--ゴッドバードアタック
-- 效果：
-- ①：把自己场上1只鸟兽族怪兽解放，以场上2张卡为对象才能发动。那些卡破坏。
function c53567095.initial_effect(c)
	-- 对应效果原文：①：把自己场上1只鸟兽族怪兽解放，以场上2张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c53567095.cost)
	e1:SetTarget(c53567095.target)
	e1:SetOperation(c53567095.activate)
	c:RegisterEffect(e1)
end
-- cost函数：将效果标记e的Label设为1，表示本次发动需要执行解放鸟兽族怪兽的代价，并返回true允许发动；实际解放操作在target阶段完成。
function c53567095.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- desfilter过滤函数：用于筛选可破坏对象，要求对象不是效果发动者自身（ec），并且不是装备在将被解放的怪兽（tc）身上的装备卡。
function c53567095.desfilter(c,tc,ec)
	return c:GetEquipTarget()~=tc and c~=ec
end
-- costfilter过滤函数：用于选择解放用的鸟兽族怪兽，要求该怪兽为鸟兽族，且解放它之后场上仍存在至少2张可作为破坏对象的卡。
function c53567095.costfilter(c,ec,tp)
	if not c:IsRace(RACE_WINDBEAST) then return false end
	-- 检查场上是否存在至少2张满足desfilter条件且可被选择的卡（排除候选解放怪兽和效果卡自身）。
	return Duel.IsExistingTarget(c53567095.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c,c,ec)
end
-- target函数：处理发动的合法性检查、对象选择及解放cost支付。若cost已标记，则先检查并执行解放，再选择2张场上卡片作为破坏对象，并登记破坏信息。
function c53567095.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查玩家场上是否存在至少1只符合costfilter条件的鸟兽族怪兽可供解放，且满足后续能选出2张对象卡的条件。
			return Duel.CheckReleaseGroup(tp,c53567095.costfilter,1,c,c,tp)
		else
			-- 当cost已标记处理（或已支付过解放cost）时，检查场上是否存在至少2张卡（除效果卡自身外）可以作为破坏对象。
			return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择1只满足costfilter条件的鸟兽族怪兽作为解放代价。
		local sg=Duel.SelectReleaseGroup(tp,c53567095.costfilter,1,1,c,c,tp)
		-- 将选中的鸟兽族怪兽以REASON_COST原因解放，作为发动神鸟攻击的代价。
		Duel.Release(sg,REASON_COST)
	end
	-- 向玩家显示“请选择要破坏的卡”的选择提示，用于随后选择破坏对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上2张卡（排除效果卡自身）作为效果对象，并自动登记为连锁对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,c)
	-- 登记操作信息：本次效果将破坏2张卡（CATEGORY_DESTROY），供后续时点和相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- activate函数：效果处理时，从连锁信息中取出对象卡，筛掉已不相关的卡，将仍满足关系的对象卡全部破坏。
function c53567095.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中登记的对象卡组（CHAININFO_TARGET_CARDS）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍然有效的对象卡以REASON_EFFECT原因破坏，完成神鸟攻击的破坏效果。
	Duel.Destroy(sg,REASON_EFFECT)
end
