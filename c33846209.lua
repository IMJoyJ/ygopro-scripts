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
-- 代价函数：设置Label为1，标记本次发动需支付“解放1只表侧表示的4星二重怪兽”的代价，并直接返回true；实际解放选怪在target阶段处理。
function c33846209.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 破坏对象的过滤函数：候选对象不能是解放怪兽所装备的卡，也不能是效果发动者自身（即二重电光这张卡）。
function c33846209.desfilter(c,tc,ec)
	return c:GetEquipTarget()~=tc and c~=ec
end
-- 解放怪兽的过滤：必须是表侧表示、等级4的二重怪兽，且场上存在至少1张满足desfilter的、可作为破坏对象的卡。
function c33846209.costfilter(c,ec,tp)
	if c:IsFacedown() or not c:IsLevel(4) or not c:IsType(TYPE_DUAL) then return false end
	-- 检查双方场上是否存在至少1张可作为破坏对象的卡（排除解放怪兽本身，且不是其装备卡，也不是效果发动者自身）。
	return Duel.IsExistingTarget(c33846209.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,c,ec)
end
-- 目标函数：发动前合法检查（确认可抽卡、存在可解放怪兽和可选破坏对象），发动时先选择并解放1只怪兽，再选择场上1张卡作为破坏对象，并登记破坏与抽卡操作信息。
function c33846209.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then
		-- 若当前玩家不能因效果抽卡（如受到抽卡禁止影响），则本次效果无法发动。
		if not Duel.IsPlayerCanDraw(tp,1) then return false end
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查场上是否存在至少1只满足条件的可解放的4星二重怪兽，以保证代价可以支付。
			return Duel.CheckReleaseGroup(tp,c33846209.costfilter,1,c,c,tp)
		else
			-- 检查场上是否存在至少1张可以被选择为效果对象的卡（排除效果发动者自身）。
			return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 从满足costfilter条件的怪兽中选择1只作为解放代价。
		local sg=Duel.SelectReleaseGroup(tp,c33846209.costfilter,1,1,c,c,tp)
		-- 将选择的怪兽解放，作为发动效果的代价。
		Duel.Release(sg,REASON_COST)
	end
	-- 向操作玩家显示“请选择要破坏的卡”的提示，准备选择破坏对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择双方场上1张卡作为破坏对象，并将其登记为本连锁的效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 登记操作信息：本次连锁的破坏对象为g，数量为1，用于星尘龙等卡的连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记操作信息：本次连锁包含抽卡效果，没有确定对象，给自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果结算：若取对象仍未离开场上且与效果相关联，则将其破坏；破坏成功后再执行抽卡。
function c33846209.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取出效果发动时选择的那张对象卡（作为要破坏的目标）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍然与本次效果相关联且在场，然后以效果将其破坏；仅当实际破坏成功（返回值>0）时，才继续抽卡。
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 自己从卡组抽1张卡（因效果而抽卡）。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
