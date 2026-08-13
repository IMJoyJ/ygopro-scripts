--デグレネード・バスター
-- 效果：
-- 这张卡不能通常召唤。把自己墓地2只电子界族怪兽除外的场合可以特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：以持有比这张卡的攻击力高的攻击力的对方场上1只怪兽为对象才能发动。那只怪兽直到结束阶段除外。这个效果在对方回合也能发动。
function c50426119.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己墓地2只电子界族怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c50426119.sprcon)
	e1:SetTarget(c50426119.sprtg)
	e1:SetOperation(c50426119.sprop)
	c:RegisterEffect(e1)
	-- ①：以持有比这张卡的攻击力高的攻击力的对方场上1只怪兽为对象才能发动。那只怪兽直到结束阶段除外。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50426119,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,50426119)
	e2:SetTarget(c50426119.rmtg)
	e2:SetOperation(c50426119.rmop)
	c:RegisterEffect(e2)
end
-- 作为特殊召唤cost的过滤：墓地中的电子界族怪兽，且可以作为效果cost被除外。
function c50426119.sprfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤手续的条件：自己场上有可用的主怪兽区，且墓地存在至少2只电子界族怪兽可作为除外cost。
function c50426119.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的主要怪兽区。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少2只满足条件的电子界族怪兽（作为除外的cost）。
		and Duel.IsExistingMatchingCard(c50426119.sprfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 特殊召唤手续的目标选择：从墓地选择2只电子界族怪兽作为除外cost，选定后保存至效果标签。
function c50426119.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有可作为除外cost的电子界族怪兽组成的集合。
	local g=Duel.GetMatchingGroup(c50426119.sprfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家展示‘请选择要除外的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的操作：将选择的2只墓地怪兽以表侧表示除外，作为特殊召唤的cost。
function c50426119.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的墓地怪兽以表侧表示除外，原因记为特殊召唤。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ①效果的对象过滤：对方场上的表侧表示怪兽，攻击力高于本卡，且能被除外。
function c50426119.rmfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk and c:IsAbleToRemove()
end
-- ①效果的发动目标选择：选取对方场上1只攻击力高于本卡的怪兽作为对象；该效果为取对象效果。
function c50426119.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c50426119.rmfilter(chkc,atk) end
	-- 效果发动时检查对方场上是否存在符合条件的表侧怪兽（攻击力高于本卡且能被除外）。
	if chk==0 then return Duel.IsExistingTarget(c50426119.rmfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 向玩家展示‘请选择要除外的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1只对方场上的符合条件的怪兽，并将其设定为效果对象。
	local g=Duel.SelectTarget(tp,c50426119.rmfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 将处理信息设为除外1张卡，以便其他效果（如星尘龙等）能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果的处理：将对象怪兽暂时除外，并注册在结束阶段将其返回场上的持续效果。
function c50426119.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联后，将其以‘效果+暂时除外’的方式除外；若除外成功则继续处理返回。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(50426119,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 那只怪兽直到结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c50426119.retcon)
		e1:SetOperation(c50426119.retop)
		-- 将结束阶段时把怪兽返回场上的持续效果注册到当前玩家（自己）场上。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段返回的触发条件：确认被除外的怪兽仍带有本卡设置的标志（即尚未因其他因素离场）。
function c50426119.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(50426119)~=0
end
-- 结束阶段返回的操作：将被暂时除外的对象怪兽返回场上。
function c50426119.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂时除外的对象怪兽返回场上，表示形式恢复为离场前。
	Duel.ReturnToField(e:GetLabelObject())
end
