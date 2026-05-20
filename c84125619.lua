--刺し違GUY
-- 效果：
-- ①：把自己场上1只战士族怪兽解放，以场上1张卡为对象才能发动。那张卡破坏，自己从卡组抽1张。
function c84125619.initial_effect(c)
	-- ①：把自己场上1只战士族怪兽解放，以场上1张卡为对象才能发动。那张卡破坏，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c84125619.cost)
	e1:SetTarget(c84125619.target)
	e1:SetOperation(c84125619.activate)
	c:RegisterEffect(e1)
end
-- 由于解放怪兽是发动代价，在cost中设置Label标记为1，以便在target中区分是否需要支付代价
function c84125619.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤函数：过滤不能是作为解放怪兽的装备卡，且不能是此卡自身的场上的卡（防止解放怪兽后其装备卡消失导致对象不合法，或选择此卡自身作为对象）
function c84125619.desfilter(c,tc,ec)
	return c:GetEquipTarget()~=tc and c~=ec
end
-- 过滤函数：过滤自己场上可以解放的战士族怪兽，且场上必须存在至少1张可以作为破坏对象的其他卡
function c84125619.cfilter(c,ec,tp)
	if not c:IsRace(RACE_WARRIOR) then return false end
	-- 检查场上是否存在至少1张满足破坏过滤条件的对象卡
	return Duel.IsExistingTarget(c84125619.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,c,ec)
end
-- 效果发动时的对象选择与代价支付处理
function c84125619.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查自己场上是否存在可解放的、且解放后仍有合法破坏对象的战士族怪兽
			return Duel.CheckReleaseGroup(tp,c84125619.cfilter,1,c,c,tp)
				-- 检查自己是否可以抽1张卡
				and Duel.IsPlayerCanDraw(tp,1)
		else
			-- （非Cost检测时）检查场上是否存在除此卡以外的任意卡作为破坏对象
			return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
				-- （非Cost检测时）检查自己是否可以抽1张卡
				and Duel.IsPlayerCanDraw(tp,1)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择自己场上1只满足条件的战士族怪兽用于解放
		local sg=Duel.SelectReleaseGroup(tp,c84125619.cfilter,1,1,c,c,tp)
		-- 解放选中的怪兽作为发动的代价
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置效果处理信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：破坏对象卡，并让自己抽1张卡
function c84125619.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍存在于场上，则将其破坏，且必须成功破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
