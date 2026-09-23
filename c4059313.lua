--ゴッド・ブレイズ・キャノン
-- 效果：
-- ①：选自己场上1只「太阳神之翼神龙」。那只怪兽直到回合结束时得到以下效果。这张卡的发动和效果不会被无效化。
-- ●这张卡不受对方的效果影响。
-- ●这张卡进行战斗的攻击宣言时，把这个回合没有攻击宣言的自己场上的其他怪兽任意数量解放才能发动。这张卡的攻击力直到回合结束时上升解放的怪兽的原本攻击力的合计数值。
-- ●这张卡攻击的伤害计算后才能发动。对方场上的怪兽全部送去墓地。
function c4059313.initial_effect(c)
	-- 将「拉之翼神龙」记入该卡所记载的卡名列表中
	aux.AddCodeList(c,10000010)
	-- ①：选自己场上1只「拉之翼神龙」。那只怪兽直到回合结束时得到以下效果。这张卡的发动和效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c4059313.target)
	e1:SetOperation(c4059313.activate)
	c:RegisterEffect(e1)
	-- 这张卡的发动和效果不会被无效化。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
end
-- 过滤自己场上表侧表示、尚未适用该效果的「拉之翼神龙」
function c4059313.filter(c)
	return c:IsFaceup() and c:IsCode(10000010) and c:GetFlagEffect(4059313)==0
end
-- 效果发动目标检查
function c4059313.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可适用的「拉之翼神龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c4059313.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：选场上1只「拉之翼神龙」赋予3项强化效果
function c4059313.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择自己场上1只「拉之翼神龙」
	local g=Duel.SelectMatchingCard(tp,c4059313.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 高亮显示选中的怪兽
		Duel.HintSelection(g)
		-- ●这张卡不受对方的效果影响。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c4059313.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- ●这张卡进行战斗的攻击宣言时，把这个回合没有攻击宣言的自己场上的其他怪兽任意数量解放才能发动。这张卡的攻击力直到回合结束时上升解放的怪兽的原本攻击力的合计数值。
		local e2=Effect.CreateEffect(tc)
		e2:SetCategory(CATEGORY_ATKCHANGE)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetCondition(c4059313.atkcon)
		e2:SetCost(c4059313.atkcost)
		e2:SetTarget(c4059313.atktg)
		e2:SetOperation(c4059313.atkop)
		tc:RegisterEffect(e2)
		-- ●这张卡攻击的伤害计算后才能发动。对方场上的怪兽全部送去墓地。
		local e3=Effect.CreateEffect(tc)
		e3:SetCategory(CATEGORY_TOGRAVE)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e3:SetCode(EVENT_BATTLED)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetCondition(c4059313.tgcon)
		e3:SetTarget(c4059313.tgtg)
		e3:SetOperation(c4059313.tgop)
		tc:RegisterEffect(e3)
		if not tc:IsType(TYPE_EFFECT) then
			-- 那只怪兽直到回合结束时得到以下效果。
			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_ADD_TYPE)
			e4:SetValue(TYPE_EFFECT)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e4)
		end
		tc:RegisterFlagEffect(4059313,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(4059313,0))  --"「神威烈焰加农炮」效果适用中"
	end
end
-- 免疫过滤：不受对方效果影响
function c4059313.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end
-- 攻击力上升效果的发动条件：自身进行战斗的攻击宣言时
function c4059313.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否为攻击怪兽或被攻击对象
	return (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
end
-- 过滤本回合未进行攻击宣言且原本攻击力大于0的可解放怪兽
function c4059313.atkfilter(c,tp)
	return c:GetAttackAnnouncedCount()==0 and c:GetTextAttack()>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 发动代价：解放本回合未进行攻击宣言的其他怪兽任意数量并记录攻击力合计
function c4059313.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100,0)
	-- 获取自己场上其他满足条件的解放候选怪兽
	local g=Duel.GetReleaseGroup(tp):Filter(c4059313.atkfilter,e:GetHandler(),tp)
	if chk==0 then return g:GetCount()>0 end
	-- 提示选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g:Select(tp,1,g:GetCount(),nil)
	-- 计算代替解放效果次数
	aux.UseExtraReleaseCount(rg,tp)
	-- 作为代价解放选中的怪兽
	Duel.Release(rg,REASON_COST)
	local atk=rg:GetSum(Card.GetTextAttack)
	e:SetLabel(100,atk)
end
-- 设置目标参数：记录被解放怪兽原本攻击力合计
function c4059313.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local label,atk=e:GetLabel()
	if chk==0 then
		e:SetLabel(0,0)
		if label~=100 then return false end
		return true
	end
	e:SetLabel(0,0)
	-- 将攻击力合计值设为目标参数
	Duel.SetTargetParam(atk)
end
-- 效果处理：自身攻击力上升被解放怪兽原本攻击力的合计数值
function c4059313.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 获取此前设定的攻击力提升数值
		local atk=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		-- 这张卡的攻击力直到回合结束时上升解放的怪兽的原本攻击力的合计数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 送墓效果的发动条件：自身作为攻击怪兽
function c4059313.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否为此次战斗的攻击者
	return Duel.GetAttacker()==e:GetHandler()
end
-- 送墓效果发动目标检查
function c4059313.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有可送去墓地的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息：将对方场上所有怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果处理：将对方场上的怪兽全部送去墓地
function c4059313.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可送去墓地的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将对方场上的怪兽全部送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
