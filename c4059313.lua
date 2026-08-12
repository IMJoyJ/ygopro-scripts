--ゴッド・ブレイズ・キャノン
-- 效果：
-- ①：选自己场上1只「太阳神之翼神龙」。那只怪兽直到回合结束时得到以下效果。这张卡的发动和效果不会被无效化。
-- ●这张卡不受对方的效果影响。
-- ●这张卡进行战斗的攻击宣言时，把这个回合没有攻击宣言的自己场上的其他怪兽任意数量解放才能发动。这张卡的攻击力直到回合结束时上升解放的怪兽的原本攻击力的合计数值。
-- ●这张卡攻击的伤害计算后才能发动。对方场上的怪兽全部送去墓地。
function c4059313.initial_effect(c)
	-- 记录此卡具有「太阳神之翼神龙」的卡名
	aux.AddCodeList(c,10000010)
	-- ①：选自己场上1只「太阳神之翼神龙」。那只怪兽直到回合结束时得到以下效果。这张卡的发动和效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c4059313.target)
	e1:SetOperation(c4059313.activate)
	c:RegisterEffect(e1)
end
-- 筛选场上正面表示存在的「太阳神之翼神龙」且未被此卡效果适用的怪兽
function c4059313.filter(c)
	return c:IsFaceup() and c:IsCode(10000010) and c:GetFlagEffect(4059313)==0
end
-- 检查场上是否存在满足条件的「太阳神之翼神龙」
function c4059313.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「太阳神之翼神龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c4059313.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 选择场上1只符合条件的「太阳神之翼神龙」作为对象
function c4059313.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择场上1只符合条件的「太阳神之翼神龙」作为对象
	local g=Duel.SelectMatchingCard(tp,c4059313.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 显示所选怪兽被选为对象的动画效果
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
			-- 若该怪兽不是效果怪兽，则添加效果怪兽类型
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
-- 效果免疫对方的效果
function c4059313.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end
-- 判断是否为攻击状态
function c4059313.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否为攻击状态
	return (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
end
-- 筛选未进行过攻击宣言且攻击力大于0的怪兽
function c4059313.atkfilter(c,tp)
	return c:GetAttackAnnouncedCount()==0 and c:GetTextAttack()>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 支付解放怪兽的费用
function c4059313.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100,0)
	-- 获取可解放的怪兽组
	local g=Duel.GetReleaseGroup(tp):Filter(c4059313.atkfilter,e:GetHandler(),tp)
	if chk==0 then return g:GetCount()>0 end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g:Select(tp,1,g:GetCount(),nil)
	-- 使用额外解放次数
	aux.UseExtraReleaseCount(rg,tp)
	-- 解放所选怪兽
	Duel.Release(rg,REASON_COST)
	local atk=rg:GetSum(Card.GetTextAttack)
	e:SetLabel(100,atk)
end
-- 设置攻击力提升值
function c4059313.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local label,atk=e:GetLabel()
	if chk==0 then
		e:SetLabel(0,0)
		if label~=100 then return false end
		return true
	end
	e:SetLabel(0,0)
	-- 设置目标参数为攻击力提升值
	Duel.SetTargetParam(atk)
end
-- 将攻击力提升值应用到怪兽上
function c4059313.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 获取目标参数中的攻击力提升值
		local atk=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		-- 将攻击力提升值应用到怪兽上
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
-- 判断是否为攻击状态
function c4059313.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为攻击状态
	return Duel.GetAttacker()==e:GetHandler()
end
-- 设置墓地效果的目标
function c4059313.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息为将怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 将对方场上的所有怪兽送去墓地
function c4059313.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将对方场上的所有怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
