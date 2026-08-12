--六武衆推参！
-- 效果：
-- 选择自己墓地1只名字带有「六武众」的怪兽才能发动。选择的怪兽从墓地特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段时破坏。
function c46874015.initial_effect(c)
	-- 创建效果，设置为发动时点，可以特殊召唤怪兽，取对象
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c46874015.target)
	e1:SetOperation(c46874015.activate)
	c:RegisterEffect(e1)
end
-- 过滤器函数，判断是否为六武众卡组且可特殊召唤
function c46874015.filter(c,e,tp)
	return c:IsSetCard(0x103d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的处理目标函数，检查是否有满足条件的墓地怪兽
function c46874015.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46874015.filter(chkc,e,tp) end
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c46874015.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c46874015.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 发动效果函数，处理特殊召唤及后续破坏效果
function c46874015.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽有效并执行特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(46874015,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 创建一个在结束阶段触发的持续效果用于破坏特殊召唤的怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c46874015.descon)
		e1:SetOperation(c46874015.desop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		-- 将该持续效果注册到玩家全局环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否为当前效果对应的特殊召唤怪兽
function c46874015.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(46874015)==e:GetLabel()
end
-- 破坏目标怪兽
function c46874015.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏目标怪兽
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
