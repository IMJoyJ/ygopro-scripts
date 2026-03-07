--ジャンクBOX
-- 效果：
-- ①：以自己墓地1只4星以下的「变形斗士」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
function c37745919.initial_effect(c)
	-- 效果原文内容：①：以自己墓地1只4星以下的「变形斗士」怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c37745919.target)
	e1:SetOperation(c37745919.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：4星以下的「变形斗士」怪兽且可以特殊召唤
function c37745919.filter(c,e,tp)
	return c:IsSetCard(0x26) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上存在空位且自己墓地存在符合条件的怪兽
function c37745919.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37745919.filter(chkc,e,tp) end
	-- 判断是否满足发动条件：场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：自己墓地存在符合条件的怪兽
		and Duel.IsExistingTarget(c37745919.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为对象
	local g=Duel.SelectTarget(tp,c37745919.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果发动处理：判断是否有空位并特殊召唤对象怪兽
function c37745919.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍然有效且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(37745919,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 效果原文内容：那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c37745919.descon)
		e1:SetOperation(c37745919.desop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		-- 将结束阶段破坏效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否为该效果对应的怪兽，用于确定是否触发破坏
function c37745919.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(37745919)==e:GetLabel()
end
-- 破坏对象怪兽
function c37745919.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果为原因破坏对象怪兽
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
