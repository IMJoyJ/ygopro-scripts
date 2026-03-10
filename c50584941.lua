--レッド・スプレマシー
-- 效果：
-- ①：把自己墓地1只「红莲魔」同调怪兽除外，以自己场上1只「红莲魔」同调怪兽为对象才能发动。那只怪兽当作和为这张卡发动而除外的「红莲魔」同调怪兽同名卡使用，变成相同效果。
function c50584941.initial_effect(c)
	-- 效果发动，设置为自由时点，需要支付除外墓地「红莲魔」同调怪兽的代价，并选择场上一只「红莲魔」同调怪兽作为对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c50584941.cost)
	e1:SetTarget(c50584941.target)
	e1:SetOperation(c50584941.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查墓地是否存在满足条件的「红莲魔」同调怪兽（可除外作为代价）且场上有符合条件的目标怪兽
function c50584941.cfilter(c,tp)
	local code=c:GetOriginalCode()
	return c:IsSetCard(0x1045) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost()
		-- 确保场上存在一只「红莲魔」同调怪兽可以被选为效果对象
		and Duel.IsExistingTarget(c50584941.filter,tp,LOCATION_MZONE,0,1,nil,code)
end
-- 支付代价阶段，检索满足条件的墓地「红莲魔」同调怪兽并除外，同时记录其原始卡号和对象卡
function c50584941.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查是否存在满足条件的墓地「红莲魔」同调怪兽用于除外作为代价
		if Duel.IsExistingMatchingCard(c50584941.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp) then
			e:SetLabel(1)
			return true
		else
			return false
		end
	end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张满足条件的墓地「红莲魔」同调怪兽进行除外
	local g=Duel.SelectMatchingCard(tp,c50584941.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 将选中的卡从墓地除外，作为发动效果的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetOriginalCode())
	e:SetLabelObject(g:GetFirst())
end
-- 过滤函数，用于选择场上一只「红莲魔」同调怪兽作为效果对象（不能是与除外怪兽同名的怪兽）
function c50584941.filter(c,code)
	return c:IsFaceup() and c:IsSetCard(0x1045) and c:IsType(TYPE_SYNCHRO) and not c:IsCode(code)
end
-- 设置效果目标，选择场上一只符合条件的「红莲魔」同调怪兽作为对象
function c50584941.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50584941.filter(chkc,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		e:SetLabelObject(nil)
		return true
	end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一只符合条件的场上「红莲魔」同调怪兽作为效果对象
	Duel.SelectTarget(tp,c50584941.filter,tp,LOCATION_MZONE,0,1,1,nil,e:GetLabel())
end
-- 发动效果，将目标怪兽变为与除外怪兽同名卡并获得相同效果
function c50584941.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	local code=e:GetLabel()
	local name=e:GetLabelObject():GetOriginalCodeRule()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为目标怪兽设置卡名改变效果，使其变成与除外怪兽相同的卡名
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(name)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc:ReplaceEffect(code,RESET_EVENT+RESETS_STANDARD)
	end
end
