--崩界の守護竜
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只龙族怪兽解放，以场上2张卡为对象才能发动。那些卡破坏。
function c47393199.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只龙族怪兽解放，以场上2张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,47393199+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c47393199.cost)
	e1:SetTarget(c47393199.target)
	e1:SetOperation(c47393199.activate)
	c:RegisterEffect(e1)
end
-- cost函数：设置标签为1，标记需要支付‘解放1只龙族怪兽’的代价；实际解放检查和支付在target函数中完成，此处仅返回true允许代价检查通过。
function c47393199.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- desfilter：选择破坏对象时的过滤条件，候选卡不能是解放的龙族怪兽tc，不能是效果持有者ec；若候选卡是装备卡，其装备对象也不能是tc。
function c47393199.desfilter(c,tc,ec)
	return c:GetEquipTarget()~=tc and c~=ec
end
-- costfilter：判断候选卡c是否为龙族怪兽，并且场上存在2张符合desfilter的卡，用于同时验证‘解放龙族怪兽’代价和‘2张破坏对象’是否可行。
function c47393199.costfilter(c,ec,tp)
	if not c:IsRace(RACE_DRAGON) then return false end
	-- 调用Duel.IsExistingTarget检查双方场上是否存在至少2张除解放候选c和效果持有者ec外、且装备对象不是c的卡，可作为破坏对象。
	return Duel.IsExistingTarget(c47393199.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c,c,ec)
end
-- target函数：处理效果发动条件的检查和发动时的对象选择；根据标签值，在检查阶段验证解放+对象是否满足，在发动阶段实际选择并解放龙族怪兽，再选择2张场上卡作为对象并登记破坏信息。
function c47393199.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查玩家tp场上是否存在至少1只满足costfilter条件的龙族怪兽可作为解放代价，同时该函数内部已确保存在2张可破坏对象。
			return Duel.CheckReleaseGroup(tp,c47393199.costfilter,1,c,c,tp)
		else
			-- 检查双方场上是否存在至少2张除效果持有者自身以外的卡可以成为效果对象，用于不依赖解放代价时的对象合法性判断。
			return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 让玩家tp从场上选择1只满足costfilter条件的龙族怪兽作为解放代价。
		local sg=Duel.SelectReleaseGroup(tp,c47393199.costfilter,1,1,c,c,tp)
		-- 将选中的龙族怪兽作为效果发动代价解放（REASON_COST），该解放不视为效果破坏。
		Duel.Release(sg,REASON_COST)
	end
	-- 向玩家tp显示选择提示：请选择要破坏的卡（HINTMSG_DESTROY），供后续SelectTarget选择界面使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家tp选择双方场上除自身外的2张卡作为破坏对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,c)
	-- 设置当前连锁操作信息：该效果包含破坏分类（CATEGORY_DESTROY），对象为已选择的2张卡g，处理数量为2。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- activate函数：效果处理时，获取连锁对象，筛选出仍与效果相关的卡，并将它们全部破坏。
function c47393199.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出发动时选择的2张对象卡（CHAININFO_TARGET_CARDS）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选后的对象卡以效果为原因（REASON_EFFECT）破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end
