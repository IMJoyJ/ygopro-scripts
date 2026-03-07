--時花の魔女－フルール・ド・ソルシエール
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以对方墓地1只怪兽为对象发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽不能向对方直接攻击，这个回合的结束阶段破坏。
function c36405256.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以对方墓地1只怪兽为对象发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽不能向对方直接攻击，这个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36405256,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,36405256)
	e1:SetTarget(c36405256.sptg)
	e1:SetOperation(c36405256.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 检索满足条件的卡片组
function c36405256.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择对象怪兽并设置操作信息
function c36405256.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c36405256.filter(chkc,e,tp) end
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and e:GetHandler():IsFaceup() end
	-- 向玩家提示“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地一只怪兽作为对象
	local g=Duel.SelectTarget(tp,c36405256.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果
function c36405256.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 将目标怪兽特殊召唤到场上
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(36405256,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 在结束阶段破坏特殊召唤的怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c36405256.descon)
		e1:SetOperation(c36405256.desop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		-- 注册结束阶段破坏效果
		Duel.RegisterEffect(e1,tp)
		-- 特殊召唤的怪兽不能向对方直接攻击
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 判断是否为该效果特殊召唤的怪兽
function c36405256.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(36405256)==e:GetLabel()
end
-- 破坏该怪兽
function c36405256.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将怪兽破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
