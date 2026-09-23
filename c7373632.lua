--神の進化
-- 效果：
-- 这张卡的发动和效果不会被无效化。
-- ①：选自己场上1只原本种族是幻神兽族的怪兽或者原本卡名是「邪神 神之化身」「邪神 恐惧之源」「邪神 抹灭者」的怪兽（已受「神之进化」的效果适用的怪兽不能选）。那只怪兽攻击力·守备力上升1000，自身的效果的发动以及那些发动的效果不会被无效化，得到以下效果。
-- ●这张卡的攻击宣言时才能发动。对方必须把自身场上1只怪兽送去墓地。
function c7373632.initial_effect(c)
	-- 记录三邪神卡片密码（邪神 神之化身、邪神 恐惧之源、邪神 抹灭者）到关联卡片列表
	aux.AddCodeList(c,21208154,62180201,57793869)
	-- ①：选自己场上1只原本种族是幻神兽族的怪兽或者原本卡名是「邪神 神之化身」「邪神 恐惧之源」「邪神 抹灭者」的怪兽（已受「神之进化」的效果适用的怪兽不能选）。那只怪兽攻击力·守备力上升1000，自身的效果的发动以及那些发动的效果不会被无效化，得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c7373632.target)
	e1:SetOperation(c7373632.activate)
	c:RegisterEffect(e1)
	-- 这张卡的发动和效果不会被无效化。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
end
-- 过滤自己场上未适用「神之进化」的原本幻神兽族或三邪神怪兽
function c7373632.filter(c)
	return c:IsFaceup() and (c:GetOriginalRace()&RACE_DIVINE~=0 or c:IsOriginalCodeRule(21208154,62180201,57793869)) and c:GetFlagEffect(7373632)==0
end
-- 卡片发动的目标判定
function c7373632.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c7373632.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：提升目标怪兽1000攻守、赋予发动与效果不会被无效的抗性、以及攻击宣言强迫对方送墓怪兽的效果
function c7373632.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c7373632.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local c=e:GetHandler()
	local tc=g:GetFirst()
	if tc then
		-- 高亮显示所选怪兽
		Duel.HintSelection(g)
		-- 那只怪兽攻击力·守备力上升1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		-- 自身的效果的发动以及那些发动的效果不会被无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_INACTIVATE)
		e3:SetLabel(3)
		e3:SetValue(c7373632.effectfilter)
		-- 注册自身效果发动不会被无效化的效果
		Duel.RegisterEffect(e3,tp)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_DISEFFECT)
		e4:SetLabel(4)
		-- 注册自身发动的效果不会被无效化的效果
		Duel.RegisterEffect(e4,tp)
		e3:SetLabelObject(e4)
		e4:SetLabelObject(tc)
		-- 自身的效果的发动以及那些发动的效果不会被无效化
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_LEAVE_FIELD_P)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e0:SetLabelObject(e3)
		e0:SetOperation(c7373632.chk)
		tc:RegisterEffect(e0)
		-- ●这张卡的攻击宣言时才能发动。对方必须把自身场上1只怪兽送去墓地。
		local e5=Effect.CreateEffect(tc)
		e5:SetCategory(CATEGORY_TOGRAVE)
		e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e5:SetCode(EVENT_ATTACK_ANNOUNCE)
		e5:SetRange(LOCATION_MZONE)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		e5:SetTarget(c7373632.tgtg)
		e5:SetOperation(c7373632.tgop)
		tc:RegisterEffect(e5)
		if not tc:IsType(TYPE_EFFECT) then
			-- 得到以下效果。
			local e6=Effect.CreateEffect(c)
			e6:SetType(EFFECT_TYPE_SINGLE)
			e6:SetCode(EFFECT_ADD_TYPE)
			e6:SetValue(TYPE_EFFECT)
			e6:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e6)
		end
		tc:RegisterFlagEffect(7373632,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(7373632,0))  --"「神之进化」效果适用中"
	end
end
-- 攻击诱发效果的目标判定及操作信息设置
function c7373632.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的怪兽
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息：对方把自身场上1只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
end
-- 效果处理：对方必须选自身场上1只怪兽送去墓地
function c7373632.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的怪兽
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if g:GetCount()>0 then
		-- 提示对方选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 高亮显示对方选中的怪兽
		Duel.HintSelection(sg)
		-- 玩家因规则将选中的怪兽送去墓地
		Duel.SendtoGrave(sg,REASON_RULE,1-tp)
	end
end
-- 过滤判定当前连锁的效果是否由该怪兽发动
function c7373632.effectfilter(e,ct)
	-- 获取当前连锁触发的效果对象
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	local label=e:GetLabel()
	local tc
	if label==3 then
		tc=e:GetLabelObject():GetLabelObject()
	else
		tc=e:GetLabelObject()
	end
	return tc and tc==te:GetHandler()
end
-- 离场前检测：怪兽因自身效果离场时延迟重置防无效效果
function c7373632.chk(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e3=e:GetLabelObject()
	local e4=e3:GetLabelObject()
	local te=c:GetReasonEffect()
	if c:GetFlagEffect(7373632)==0 or not te or not te:IsActivated() or te:GetHandler()~=c then
		e3:Reset()
		e4:Reset()
	else
		-- 自身的效果的发动以及那些发动的效果不会被无效化
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_CHAIN_END)
		e0:SetLabelObject(e3)
		e0:SetOperation(c7373632.resetop)
		-- 注册连锁结束时重置防无效效果的全局监听
		Duel.RegisterEffect(e0,tp)
	end
end
-- 连锁结束时重置不会被无效的效果并注销监听
function c7373632.resetop(e,tp,eg,ep,ev,re,r,rp)
	local e3=e:GetLabelObject()
	local e4=e3:GetLabelObject()
	e3:Reset()
	e4:Reset()
	e:Reset()
end
