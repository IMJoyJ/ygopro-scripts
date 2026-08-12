--不知火流 燕の太刀
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只不死族怪兽解放，以场上2张卡为对象才能发动。那些卡破坏。那之后，从卡组把1只「不知火」怪兽除外。
function c4333086.initial_effect(c)
	-- ①：把自己场上1只不死族怪兽解放，以场上2张卡为对象才能发动。那些卡破坏。那之后，从卡组把1只「不知火」怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,4333086+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c4333086.cost)
	e1:SetTarget(c4333086.target)
	e1:SetOperation(c4333086.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选卡组中满足条件的「不知火」怪兽（怪兽卡且可除外）
function c4333086.filter(c)
	return c:IsSetCard(0xd9) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 设置发动时的标记，表示需要支付解放代价
function c4333086.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤函数，用于筛选场上满足条件的卡（非装备对象且非被选中卡）
function c4333086.desfilter(c,tc,ec)
	return c:GetEquipTarget()~=tc and c~=ec
end
-- 过滤函数，用于筛选场上可解放的不死族怪兽（且满足目标条件）
function c4333086.costfilter(c,ec,tp)
	if not c:IsRace(RACE_ZOMBIE) then return false end
	-- 检查场上是否存在满足条件的2张卡作为破坏对象
	return Duel.IsExistingTarget(c4333086.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c,c,ec)
end
-- 效果处理函数，判断是否满足发动条件并选择破坏对象和支付代价
function c4333086.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查场上是否存在满足条件的可解放的不死族怪兽
			return Duel.CheckReleaseGroup(tp,c4333086.costfilter,1,c,c,tp)
				-- 检查卡组中是否存在满足条件的「不知火」怪兽
				and Duel.IsExistingMatchingCard(c4333086.filter,tp,LOCATION_DECK,0,1,nil)
		else
			-- 检查场上是否存在2张满足条件的卡作为破坏对象
			return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c)
				-- 检查卡组中是否存在满足条件的「不知火」怪兽
				and Duel.IsExistingMatchingCard(c4333086.filter,tp,LOCATION_DECK,0,1,nil)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择场上满足条件的1张可解放的不死族怪兽
		local sg=Duel.SelectReleaseGroup(tp,c4333086.costfilter,1,1,c,c,tp)
		-- 以支付代价的方式解放选中的怪兽
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上2张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,c)
	-- 设置操作信息，记录将要破坏的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置操作信息，记录将要除外的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果发动处理函数，执行破坏和除外效果
function c4333086.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的对象卡组，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将选中的卡破坏
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从卡组中选择1张满足条件的「不知火」怪兽
		local rg=Duel.SelectMatchingCard(tp,c4333086.filter,tp,LOCATION_DECK,0,1,1,nil)
		if rg:GetCount()>0 then
			-- 中断当前效果，使后续处理视为错时点
			Duel.BreakEffect()
			-- 将选中的卡除外
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
