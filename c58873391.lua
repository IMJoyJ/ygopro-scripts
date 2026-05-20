--フィッシャーチャージ
-- 效果：
-- 把自己场上存在的1只鱼族怪兽解放发动。场上1张卡破坏，从自己卡组抽1张卡。
function c58873391.initial_effect(c)
	-- 把自己场上存在的1只鱼族怪兽解放发动。场上1张卡破坏，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c58873391.cost)
	e1:SetTarget(c58873391.target)
	e1:SetOperation(c58873391.activate)
	c:RegisterEffect(e1)
end
-- 设置标记以在target函数中区分是否为发动时的代价检测
function c58873391.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤场上不为解放怪兽的装备卡且不为本卡自身的卡
function c58873391.desfilter(c,tc,ec)
	return c:GetEquipTarget()~=tc and c~=ec
end
-- 过滤场上可解放的鱼族怪兽，且该怪兽解放后场上仍存在可作为破坏对象的卡
function c58873391.costfilter(c,ec,tp)
	if not c:IsRace(RACE_FISH) then return false end
	-- 检查场上是否存在除被解放怪兽和本卡以外的、可作为破坏对象的卡
	return Duel.IsExistingTarget(c58873391.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,c,ec)
end
-- 效果发动时的对象选择与代价支付处理
function c58873391.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then
		-- 检查发动玩家当前是否可以进行抽卡
		if not Duel.IsPlayerCanDraw(tp,1) then return false end
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查自己场上是否存在满足解放条件且解放后有可选破坏对象的鱼族怪兽
			return Duel.CheckReleaseGroup(tp,c58873391.costfilter,1,c,c,tp)
		else
			-- 检查场上是否存在除本卡以外的可作为破坏对象的卡
			return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择自己场上1只满足条件的鱼族怪兽作为解放对象
		local sg=Duel.SelectReleaseGroup(tp,c58873391.costfilter,1,1,c,c,tp)
		-- 解放选中的怪兽作为发动的代价
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置连锁信息，表明此效果包含破坏选定卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁信息，表明此效果包含抽1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理的函数，执行破坏卡片和抽卡的操作
function c58873391.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的破坏对象
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍存在且成功被效果破坏
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 让发动效果的玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
