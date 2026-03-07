--エレキーパー
-- 效果：
-- 选择自己墓地存在的1只4星以下的名字带有「电气」的怪兽发动。选择的怪兽从墓地特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段时破坏。
function c32061744.initial_effect(c)
	-- 效果原文内容：选择自己墓地存在的1只4星以下的名字带有「电气」的怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c32061744.target)
	e1:SetOperation(c32061744.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：4星以下且属于电气卡组且可以特殊召唤
function c32061744.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0xe) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上存在空位且自己墓地存在符合条件的怪兽
function c32061744.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32061744.filter(chkc,e,tp) end
	-- 判断是否满足发动条件：场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：自己墓地存在符合条件的怪兽
		and Duel.IsExistingTarget(c32061744.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标：从自己墓地选择1只符合条件的怪兽
	local g=Duel.SelectTarget(tp,c32061744.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将特殊召唤的怪兽作为效果处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果发动处理：判断是否满足特殊召唤条件并执行特殊召唤
function c32061744.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足特殊召唤条件：场上存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效并执行特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(32061744,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 效果原文内容：这个效果特殊召唤的怪兽在这个回合的结束阶段时破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c32061744.descon)
		e1:SetOperation(c32061744.desop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		-- 注册一个在结束阶段触发的效果用于破坏特殊召唤的怪兽
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否为该效果对应的特殊召唤怪兽
function c32061744.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(32061744)==e:GetLabel()
end
-- 效果发动处理：破坏目标怪兽
function c32061744.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽以效果原因破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
