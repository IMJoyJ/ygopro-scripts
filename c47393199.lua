--崩界の守護竜
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只龙族怪兽解放，以场上2张卡为对象才能发动。那些卡破坏。
function c47393199.initial_effect(c)
	-- 创建效果对象并设置其分类为破坏、取对象、发动类型、自由连锁时点、发动次数限制为1次且为誓约次数，设置费用函数、目标函数和发动函数
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
-- 费用函数设置标签为1并直接返回true
function c47393199.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 破坏过滤器函数，用于判断卡片是否不等于目标卡片且不等于装备目标卡片
function c47393199.desfilter(c,tc,ec)
	return c:GetEquipTarget()~=tc and c~=ec
end
-- 解放过滤器函数，检查是否为龙族怪兽并且场上存在满足条件的2张卡作为对象
function c47393199.costfilter(c,ec,tp)
	if not c:IsRace(RACE_DRAGON) then return false end
	-- 检查场上是否存在满足破坏过滤器条件的2张卡
	return Duel.IsExistingTarget(c47393199.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c,c,ec)
end
-- 目标函数处理阶段，根据标签判断是否需要支付费用并选择解放的龙族怪兽，然后选择2张场上的卡作为对象
function c47393199.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查玩家场上是否存在至少1张满足解放过滤器条件的可解放卡
			return Duel.CheckReleaseGroup(tp,c47393199.costfilter,1,c,c,tp)
		else
			-- 检查场上是否存在至少2张满足任意条件的卡作为对象
			return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 从玩家场上选择1张满足解放过滤器条件的卡进行解放
		local sg=Duel.SelectReleaseGroup(tp,c47393199.costfilter,1,1,c,c,tp)
		-- 以代价原因解放已选中的卡
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择2张场上的卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,c)
	-- 设置操作信息，指定将要破坏2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 发动函数，获取连锁中指定的对象卡组并进行破坏处理
function c47393199.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因破坏满足条件的卡片组
	Duel.Destroy(sg,REASON_EFFECT)
end
