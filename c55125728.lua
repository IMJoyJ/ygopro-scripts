--春化精の女神 ヴェーラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权。这个效果得到控制权的怪兽变成地属性。
-- ②：对方回合，以自己墓地1只地属性怪兽为对象才能发动。那只怪兽特殊召唤。
-- ③：1回合1次，对方发动的怪兽的效果处理时，自己场上有地属性怪兽5只以上存在的场合，可以把那个发动的效果无效并破坏。
function c55125728.initial_effect(c)
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。得到那只怪兽的控制权。这个效果得到控制权的怪兽变成地属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55125728,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,55125728)
	e1:SetTarget(c55125728.cttg)
	e1:SetOperation(c55125728.ctop)
	c:RegisterEffect(e1)
	-- ②：对方回合，以自己墓地1只地属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55125728,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,55125729)
	e2:SetCondition(c55125728.spcon)
	e2:SetTarget(c55125728.sptg)
	e2:SetOperation(c55125728.spop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，对方发动的怪兽的效果处理时，自己场上有地属性怪兽5只以上存在的场合，可以把那个发动的效果无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c55125728.discon)
	e3:SetOperation(c55125728.disop)
	c:RegisterEffect(e3)
end
-- 过滤对方场上可以改变控制权的表侧表示怪兽
function c55125728.ctfilter(c)
	return c:IsControlerCanBeChanged() and c:IsFaceup()
end
-- ①号效果的靶向/发动准备阶段，选择对方场上1只表侧表示怪兽作为对象
function c55125728.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c55125728.ctfilter(chkc) end
	-- 检查对方场上是否存在可以改变控制权的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c55125728.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只表侧表示怪兽作为效果对象并将其设为连锁对象
	local g=Duel.SelectTarget(tp,c55125728.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- ①号效果的处理：得到目标怪兽的控制权，并将其属性变为地属性
function c55125728.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用此效果，则尝试让当前玩家得到其控制权
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp)~=0 then
		-- 这个效果得到控制权的怪兽变成地属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_EARTH)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- ②号效果的发动条件：对方回合
function c55125728.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方玩家
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤自己墓地可以特殊召唤的地属性怪兽
function c55125728.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②号效果的靶向/发动准备阶段，选择自己墓地1只地属性怪兽作为对象
function c55125728.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c55125728.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地是否存在可以特殊召唤的地属性怪兽
		and Duel.IsExistingTarget(c55125728.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只地属性怪兽作为效果对象并将其设为连锁对象
	local g=Duel.SelectTarget(tp,c55125728.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②号效果的处理：将目标怪兽特殊召唤
function c55125728.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已无空余的怪兽区域，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁中作为效果对象的那只墓地怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上表侧表示的地属性怪兽
function c55125728.disfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceup()
end
-- ③号效果的适用条件：对方发动的怪兽效果处理时，且自己场上有5只以上地属性怪兽存在
function c55125728.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方发动的、可以被无效的怪兽效果
	return rp==1-tp and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_MONSTER)
		-- 且自己场上是否存在5只以上的地属性怪兽
		and Duel.GetMatchingGroupCount(c55125728.disfilter,tp,LOCATION_MZONE,0,nil)>=5
		and e:GetHandler():GetFlagEffect(55125728)<=0
end
-- ③号效果的处理：询问是否将该发动的效果无效并破坏
function c55125728.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问玩家是否适用此效果来无效对方的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(55125728,2)) then  --"是否适用「春化精的女神 春」的效果来无效？"
		-- 在场上展示此卡以提示效果的适用
		Duel.Hint(HINT_CARD,0,55125728)
		local rc=re:GetHandler()
		-- 若成功使该效果无效，且该卡在场上或相关区域存在
		if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
			-- 将该卡破坏
			Duel.Destroy(rc,REASON_EFFECT)
		end
		e:GetHandler():RegisterFlagEffect(55125728,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(55125728,3))  --"已使用过效果"
	end
end
