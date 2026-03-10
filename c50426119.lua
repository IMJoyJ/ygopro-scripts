--デグレネード・バスター
-- 效果：
-- 这张卡不能通常召唤。把自己墓地2只电子界族怪兽除外的场合可以特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：以持有比这张卡的攻击力高的攻击力的对方场上1只怪兽为对象才能发动。那只怪兽直到结束阶段除外。这个效果在对方回合也能发动。
function c50426119.initial_effect(c)
	c:EnableReviveLimit()
	-- 这个效果用于设置卡片的特殊召唤条件，需要从墓地除外2只电子界族怪兽才能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c50426119.sprcon)
	e1:SetTarget(c50426119.sprtg)
	e1:SetOperation(c50426119.sprop)
	c:RegisterEffect(e1)
	-- 这个效果用于设置卡片的发动条件和处理方式，可以将对方场上攻击力高于自身的怪兽除外直到结束阶段
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
-- 过滤函数，用于筛选墓地中可作为除外费用的电子界族怪兽
function c50426119.sprfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足特殊召唤的条件，包括场上有空位且自己墓地有2只以上电子界族怪兽
function c50426119.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否有足够的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在至少2只符合条件的电子界族怪兽
		and Duel.IsExistingMatchingCard(c50426119.sprfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 选择并设置要除外的2只电子界族怪兽作为特殊召唤的费用
function c50426119.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的电子界族怪兽组合作为选择目标
	local g=Duel.GetMatchingGroup(c50426119.sprfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤时的处理操作，将选中的2只怪兽除外并从游戏中移除
function c50426119.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的卡片以正面表示形式除外，并标记为特殊召唤原因
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤函数，用于筛选对方场上攻击力高于自身且可以被除外的怪兽
function c50426119.rmfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk and c:IsAbleToRemove()
end
-- 设置效果的发动条件和目标选择逻辑，确保能选到符合条件的对方怪兽
function c50426119.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c50426119.rmfilter(chkc,atk) end
	-- 检查是否满足发动条件，即对方场上有至少一只攻击力高于自身的怪兽
	if chk==0 then return Duel.IsExistingTarget(c50426119.rmfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 向玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c50426119.rmfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 设置连锁操作信息，确定效果处理时将要除外的怪兽数量和类型
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行效果的处理操作，将选中的对方怪兽除外并记录其返回场上的效果
function c50426119.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效且可以被除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(50426119,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 创建一个在结束阶段触发的效果，用于将被除外的怪兽返回场上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c50426119.retcon)
		e1:SetOperation(c50426119.retop)
		-- 注册该持续效果到游戏环境中
		Duel.RegisterEffect(e1,tp)
	end
end
-- 条件函数，检查目标怪兽是否具有标记以决定是否返回场上
function c50426119.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(50426119)~=0
end
-- 操作函数，将目标怪兽以原表示形式返回场上
function c50426119.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将指定的卡片以原表示形式返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
