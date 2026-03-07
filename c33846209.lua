--デュアルスパーク
-- 效果：
-- ①：把自己场上1只表侧表示的4星二重怪兽解放，以场上1张卡为对象才能发动。那张卡破坏，自己从卡组抽1张。
function c33846209.initial_effect(c)
	-- ①：把自己场上1只表侧表示的4星二重怪兽解放，以场上1张卡为对象才能发动。那张卡破坏，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c33846209.cost)
	e1:SetTarget(c33846209.target)
	e1:SetOperation(c33846209.activate)
	c:RegisterEffect(e1)
end
c33846209.has_text_type=TYPE_DUAL
-- 设置cost标签为1，表示需要支付解放费用
function c33846209.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤函数，用于判断装备目标是否不等于tc且不等于ec
function c33846209.desfilter(c,tc,ec)
	return c:GetEquipTarget()~=tc and c~=ec
end
-- 过滤函数，用于判断是否满足解放条件：表侧表示、4星、二重类型，并且存在满足desfilter条件的目标
function c33846209.costfilter(c,ec,tp)
	if c:IsFacedown() or not c:IsLevel(4) or not c:IsType(TYPE_DUAL) then return false end
	-- 检查是否存在满足desfilter条件的目标
	return Duel.IsExistingTarget(c33846209.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,c,ec)
end
-- 处理效果的发动条件和选择目标，包括判断是否可以抽卡以及是否满足解放条件
function c33846209.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then
		-- 检查玩家是否可以抽卡
		if not Duel.IsPlayerCanDraw(tp,1) then return false end
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查场上是否存在满足costfilter条件的可解放怪兽
			return Duel.CheckReleaseGroup(tp,c33846209.costfilter,1,c,c,tp)
		else
			-- 检查场上是否存在满足条件的目标卡
			return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择满足costfilter条件的怪兽进行解放
		local sg=Duel.SelectReleaseGroup(tp,c33846209.costfilter,1,1,c,c,tp)
		-- 将选中的怪兽以REASON_COST原因进行解放
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置操作信息，记录将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，记录将要抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理效果的发动，包括破坏目标卡并抽卡
function c33846209.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否存在且与效果相关，并执行破坏操作
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 让玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
