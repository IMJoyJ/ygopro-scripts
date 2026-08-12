--煉獄の死徒
-- 效果：
-- ①：以自己场上1只「狱火机」怪兽为对象才能发动。这个回合，那只自己怪兽不受对方的效果影响。
-- ②：自己场上的「狱火机」怪兽被效果破坏的场合，可以作为那些「狱火机」怪兽之内的1只的代替而把墓地的这张卡除外。
function c8437145.initial_effect(c)
	-- ①：以自己场上1只「狱火机」怪兽为对象才能发动。这个回合，那只自己怪兽不受对方的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c8437145.target)
	e1:SetOperation(c8437145.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「狱火机」怪兽被效果破坏的场合，可以作为那些「狱火机」怪兽之内的1只的代替而把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c8437145.reptg)
	e2:SetValue(c8437145.repval)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「狱火机」怪兽
function c8437145.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xbb)
end
-- ①号效果的对象选择与判定
function c8437145.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c8437145.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「狱火机」怪兽
	if chk==0 then return Duel.IsExistingTarget(c8437145.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「狱火机」怪兽作为效果对象
	Duel.SelectTarget(tp,c8437145.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①号效果的发动处理，赋予目标怪兽不受对方效果影响的抗性
function c8437145.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 这个回合，那只自己怪兽不受对方的效果影响。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c8437145.efilter)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1)
	end
end
-- 过滤不受影响的效果来源，判定是否为对方的效果
function c8437145.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
-- 过滤自己场上因效果破坏且可以被代替破坏的「狱火机」怪兽
function c8437145.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsSetCard(0xbb) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ②号效果的代替破坏处理
function c8437145.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c8437145.repfilter,1,nil,tp) end
	-- 询问玩家是否使用墓地的这张卡代替破坏
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local g=eg:Filter(c8437145.repfilter,nil,tp)
		if g:GetCount()==1 then
			e:SetLabelObject(g:GetFirst())
		else
			-- 提示玩家选择要代替破坏的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
			local cg=g:Select(tp,1,1,nil)
			e:SetLabelObject(cg:GetFirst())
		end
		-- 将墓地的这张卡除外
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
-- 判定被代替破坏的怪兽是否为玩家选择的目标
function c8437145.repval(e,c)
	return c==e:GetLabelObject()
end
