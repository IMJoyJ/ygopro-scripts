--レッド・スプレマシー
-- 效果：
-- ①：把自己墓地1只「红莲魔」同调怪兽除外，以自己场上1只「红莲魔」同调怪兽为对象才能发动。那只怪兽当作和为这张卡发动而除外的「红莲魔」同调怪兽同名卡使用，变成相同效果。
function c50584941.initial_effect(c)
	-- ①：把自己墓地1只「红莲魔」同调怪兽除外，以自己场上1只「红莲魔」同调怪兽为对象才能发动。那只怪兽当作和为这张卡发动而除外的「红莲魔」同调怪兽同名卡使用，变成相同效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c50584941.cost)
	e1:SetTarget(c50584941.target)
	e1:SetOperation(c50584941.activate)
	c:RegisterEffect(e1)
end
-- 定义除外候选的过滤条件：必须是「红莲魔」同调怪兽、可以除外作为代价，并且自己场上存在1只表侧表示的同为「红莲魔」同调怪兽且卡号（卡名）与候选不同的怪兽可作为对象。
function c50584941.cfilter(c,tp)
	local code=c:GetOriginalCode()
	return c:IsSetCard(0x1045) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost()
		-- 确认场上存在满足条件的对象（卡号与候选墓地怪兽不同），以保证发动时能够选择不重名的「红莲魔」同调怪兽作为对象。
		and Duel.IsExistingTarget(c50584941.filter,tp,LOCATION_MZONE,0,1,nil,code)
end
-- 代价处理：先检查墓地是否有满足条件的「红莲魔」同调怪兽可除外且场上存在对象；若可行，让玩家选择1张墓地怪兽除外，将其原始卡号存入效果的Label，并将该卡作为LabelObject，供后续处理使用。
function c50584941.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查墓地中是否存在至少1张满足cfilter过滤条件的「红莲魔」同调怪兽可以作为代价除外（cfilter已同时检查场上对象存在性）。
		if Duel.IsExistingMatchingCard(c50584941.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp) then
			e:SetLabel(1)
			return true
		else
			return false
		end
	end
	-- 发送选择提示，告知玩家接下来要选择除外的卡（墓地中的怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足条件的「红莲魔」同调怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c50584941.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 将选中的墓地怪兽以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetOriginalCode())
	e:SetLabelObject(g:GetFirst())
end
-- 定义取对象时的对象过滤条件：表侧表示、自己场上的「红莲魔」同调怪兽，且其卡名（卡号）不能与除外的那只墓地「红莲魔」同调怪兽的卡名（卡号）相同。
function c50584941.filter(c,code)
	return c:IsFaceup() and c:IsSetCard(0x1045) and c:IsType(TYPE_SYNCHRO) and not c:IsCode(code)
end
-- 效果发动时的对象选择处理：在发动阶段校验代价阶段已满足条件（Label为1），然后让玩家选择自己场上1只符合条件的「红莲魔」同调怪兽作为效果对象；同时对连锁中的对象进行合法性检查。
function c50584941.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50584941.filter(chkc,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		e:SetLabelObject(nil)
		return true
	end
	-- 发送选择提示，告知玩家接下来要选择表侧表示的怪兽作为对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只表侧表示且符合filter条件的「红莲魔」同调怪兽作为效果对象，并将其记录为当前连锁的对象。
	Duel.SelectTarget(tp,c50584941.filter,tp,LOCATION_MZONE,0,1,1,nil,e:GetLabel())
end
-- 效果处理：取得对象怪兽和记录的除外卡信息；若对象怪兽仍与效果关联且表侧表示，则给对象怪兽附加卡名变更效果，使其卡名变为除外卡规则上的卡名，并将其效果替换为除外卡的效果，直到离场等标准重置时失效。
function c50584941.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local code=e:GetLabel()
	local name=e:GetLabelObject():GetOriginalCodeRule()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽当作和为这张卡发动而除外的「红莲魔」同调怪兽同名卡使用
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
