--パラレル・ツイスター
-- 效果：
-- ①：把这张卡以外的自己场上1张魔法·陷阱卡送去墓地，以场上1张卡为对象才能发动。那张卡破坏。
function c83102080.initial_effect(c)
	-- ①：把这张卡以外的自己场上1张魔法·陷阱卡送去墓地，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c83102080.cost)
	e1:SetTarget(c83102080.target)
	e1:SetOperation(c83102080.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上可以作为发动代价送去墓地的魔法·陷阱卡，且必须存在除该卡以外的场上卡片作为破坏对象
function c83102080.filter(c,ec)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
		-- 检查场上是否存在除作为代价的卡（c）和本卡（ec）以外的、可以作为效果对象的卡
		and Duel.IsExistingTarget(c83102080.tgfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ec,c)
end
-- 过滤破坏对象，确保破坏对象不是作为代价送去墓地的卡
function c83102080.tgfilter(c,tc)
	return c~=tc
end
-- 代价函数，将Label设为1以标记即将进行代价支付的检测与处理
function c83102080.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 效果靶向与代价支付处理函数，处理发动时的代价支付、选择破坏对象以及设置操作信息
function c83102080.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then
		if e:GetLabel()~=0 then
			e:SetLabel(0)
			-- 检查自己场上是否存在满足送墓代价条件的魔法·陷阱卡（且存在对应的破坏对象）
			return Duel.IsExistingMatchingCard(c83102080.filter,tp,LOCATION_ONFIELD,0,1,c,c)
		else
			-- 在不支付代价的情况下（如效果复制），检查场上是否存在可作为对象的卡
			return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		end
	end
	if e:GetLabel()~=0 then
		e:SetLabel(0)
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择自己场上1张除本卡以外的满足条件的魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c83102080.filter,tp,LOCATION_ONFIELD,0,1,1,c,c)
		-- 将选择的卡作为发动代价送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置操作信息，表明此效果的处理为破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，在效果结算时尝试破坏选中的对象
function c83102080.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
