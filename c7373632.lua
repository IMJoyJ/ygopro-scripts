--神の進化
-- 效果：
-- 这张卡的发动和效果不会被无效化。
-- ①：选自己场上1只原本种族是幻神兽族的怪兽或者原本卡名是「邪神 神之化身」「邪神 恐惧之源」「邪神 抹灭者」的怪兽（已受「神之进化」的效果适用的怪兽不能选）。那只怪兽攻击力·守备力上升1000，自身的效果的发动以及那些发动的效果不会被无效化，得到以下效果。
-- ●这张卡的攻击宣言时才能发动。对方必须把自身场上1只怪兽送去墓地。
function c7373632.initial_effect(c)
	-- 记录这张卡上记载了「邪神 神之化身」「邪神 恐惧之源」「邪神 抹灭者」的卡名。
	aux.AddCodeList(c,21208154,62180201,57793869)
	-- ①：选自己场上1只原本种族是幻神兽族的怪兽或者原本卡名是「邪神 神之化身」「邪神 恐惧之源」「邪神 抹灭者」的怪兽（已受「神之进化」的效果适用的怪兽不能选）。那只怪兽攻击力·守备力上升1000，自身的效果的发动以及那些发动的效果不会被无效化，得到以下效果。●这张卡的攻击宣言时才能发动。对方必须把自身场上1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c7373632.target)
	e1:SetOperation(c7373632.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示、原本种族为幻神兽族或原本卡名为三邪神、且未适用「神之进化」效果的怪兽。
function c7373632.filter(c)
	return c:IsFaceup() and (c:GetOriginalRace()&RACE_DIVINE~=0 or c:IsOriginalCodeRule(21208154,62180201,57793869)) and c:GetFlagEffect(7373632)==0
end
-- 效果发动的目标检查：检查自己场上是否存在满足条件的怪兽。
function c7373632.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足过滤条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c7373632.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：选择自己场上1只满足条件的怪兽，使其攻击力·守备力上升1000，使其效果的发动及效果不会被无效，并使其获得攻击宣言时让对方送去墓地的效果。
function c7373632.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c7373632.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local c=e:GetHandler()
	local tc=g:GetFirst()
	if tc then
		-- 确认并显示所选择的怪兽。
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
		-- 注册全局效果：使目标怪兽的效果的发动不会被无效。
		Duel.RegisterEffect(e3,tp)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_DISEFFECT)
		e4:SetLabel(4)
		-- 注册全局效果：使目标怪兽发动的效果不会被无效。
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
			-- 得到以下效果
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
-- 获得效果的发动准备：检查对方场上是否有怪兽，并设置送去墓地的操作信息。
function c7373632.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的怪兽。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息：对方场上的1只怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
end
-- 获得效果的处理：对方选择自身场上1只怪兽送去墓地。
function c7373632.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的怪兽。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if g:GetCount()>0 then
		-- 提示对方玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 确认并显示对方选择送去墓地的怪兽。
		Duel.HintSelection(sg)
		-- 对方玩家因规则将选择的怪兽送去墓地。
		Duel.SendtoGrave(sg,REASON_RULE,1-tp)
	end
end
-- 过滤条件：判断当前连锁中的效果是否由适用「神之进化」效果的怪兽所发动。
function c7373632.effectfilter(e,ct)
	-- 获取当前连锁中触发的效果。
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
-- 检查目标怪兽是否离场，若离场则重置不会被无效的全局效果。
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
		-- 注册连锁结束时重置不会被无效效果的事件。
		Duel.RegisterEffect(e0,tp)
	end
end
-- 连锁结束时，重置不会被无效的全局效果。
function c7373632.resetop(e,tp,eg,ep,ev,re,r,rp)
	local e3=e:GetLabelObject()
	local e4=e3:GetLabelObject()
	e3:Reset()
	e4:Reset()
	e:Reset()
end
