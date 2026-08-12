--ゴッドバードアタック
-- 效果：
-- ①：把自己场上1只鸟兽族怪兽解放，以场上2张卡为对象才能发动。那些卡破坏。
function c53567095.initial_effect(c)
	-- ①：把自己场上1只鸟兽族怪兽解放，以场上2张卡为对象才能发动。那些卡破坏。
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
-- 设置cost标签为1，表示需要支付解放鸟兽族怪兽的代价
function c53567095.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤函数，用于判断目标卡是否能成为破坏效果的对象
function c53567095.desfilter(c,tc,ec)
	return c:GetEquipTarget()~=tc and c~=ec
end
-- 过滤函数，用于判断场上是否存在满足条件的鸟兽族怪兽可以被解放
function c53567095.costfilter(c,ec,tp)
	if not c:IsRace(RACE_WINDBEAST) then return false end
	-- 检查是否存在满足条件的卡作为破坏对象
	return Duel.IsExistingTarget(c53567095.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c,c,ec)
end
-- 处理效果的发动条件和选择对象，包括解放怪兽和选择破坏对象
function c53567095.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查场上是否存在满足解放条件的鸟兽族怪兽
			return Duel.CheckReleaseGroup(tp,c53567095.costfilter,1,c,c,tp)
		else
			-- 检查场上是否存在满足条件的2张卡作为破坏对象
			return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择满足条件的1只鸟兽族怪兽进行解放
		local sg=Duel.SelectReleaseGroup(tp,c53567095.costfilter,1,1,c,c,tp)
		-- 将选中的怪兽从场上解放作为发动代价
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择2张场上卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,c)
	-- 设置操作信息，表示将要破坏2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 处理效果的发动，对选中的卡进行破坏
function c53567095.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标卡组中的卡破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
