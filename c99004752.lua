--ミニマム・ガッツ
-- 效果：
-- 把自己场上1只怪兽解放，选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽的攻击力直到结束阶段时变成0。这个回合，选择的怪兽被战斗破坏送去对方墓地时，给与对方基本分那只怪兽的原本攻击力数值的伤害。
function c99004752.initial_effect(c)
	-- 把自己场上1只怪兽解放，选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽的攻击力直到结束阶段时变成0。这个回合，选择的怪兽被战斗破坏送去对方墓地时，给与对方基本分那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c99004752.cost)
	e1:SetTarget(c99004752.target)
	e1:SetOperation(c99004752.activate)
	c:RegisterEffect(e1)
end
-- 发动代价处理函数，设置标记并返回true（实际解放操作在target中进行）
function c99004752.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤函数：选择对方场上表侧表示的怪兽，且该怪兽不能是作为解放代价的怪兽或其装备对象
function c99004752.tgfilter(c,tc,ec)
	return c:IsFaceup() and c:GetEquipTarget()~=tc and c~=ec
end
-- 过滤函数：检查是否存在可作为解放代价的怪兽，且该怪兽解放后对方场上仍有合法的可选对象怪兽
function c99004752.costfilter(c,ec,tp)
	-- 检查对方场上是否存在至少1只满足tgfilter过滤条件的表侧表示怪兽
	return Duel.IsExistingTarget(c99004752.tgfilter,tp,0,LOCATION_MZONE,1,c,c,ec)
end
-- 发动时的对象选择与代价支付处理函数
function c99004752.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查自己场上是否存在至少1只可解放的怪兽作为发动代价
			return Duel.CheckReleaseGroup(tp,c99004752.costfilter,1,c,c,tp)
		else
			-- 检查对方场上是否存在表侧表示的怪兽（非cost检测时的常规检测）
			return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择自己场上1只满足条件的怪兽作为解放代价
		local sg=Duel.SelectReleaseGroup(tp,c99004752.costfilter,1,1,c,c,tp)
		-- 解放选择的怪兽
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果生效处理函数
function c99004752.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 选择的怪兽的攻击力直到结束阶段时变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个回合，选择的怪兽被战斗破坏送去对方墓地时，给与对方基本分那只怪兽的原本攻击力数值的伤害。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(99004752,0))  --"伤害"
		e2:SetCategory(CATEGORY_DAMAGE)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e2:SetCode(EVENT_BATTLE_DESTROYED)
		e2:SetCondition(c99004752.damcon)
		e2:SetTarget(c99004752.damtg)
		e2:SetOperation(c99004752.damop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetLabelObject(tc)
		-- 在全局环境中注册该回合内生效的战斗破坏伤害效果
		Duel.RegisterEffect(e2,tp)
		tc:RegisterFlagEffect(99004752,RESET_EVENT+0x17a0000+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 伤害效果发动条件：被战斗破坏的怪兽是之前选择的对象怪兽，且被送去对方墓地
function c99004752.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return eg:IsContains(tc) and tc:GetFlagEffect(99004752)~=0 and tc:GetOwner()==1-tp
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
end
-- 伤害效果目标设置：确定伤害数值为该怪兽的原本攻击力，并设置伤害操作信息
function c99004752.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local atk=e:GetLabelObject():GetBaseAttack()
	if atk<0 then atk=0 end
	-- 设置伤害的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害的数值为该怪兽的原本攻击力
	Duel.SetTargetParam(atk)
	-- 设置当前连锁的操作信息为给与对方原本攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 伤害效果执行函数
function c99004752.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的伤害对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与对方玩家相应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
