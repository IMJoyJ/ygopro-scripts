--瞬着ボマー
-- 效果：
-- 里侧守备表示的这张卡被对方怪兽攻击的场合，不进行伤害计算让这张卡变成攻击怪兽的装备卡。下次的对方回合的准备阶段时，那只装备怪兽破坏。
function c53828396.initial_effect(c)
	-- 里侧守备表示的这张卡被对方怪兽攻击的场合，不进行伤害计算让这张卡变成攻击怪兽的装备卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53828396,0))  --"变成装备卡"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCondition(c53828396.eqcon)
	e1:SetOperation(c53828396.eqop)
	c:RegisterEffect(e1)
end
-- 装备效果的发动条件：攻击对象为这张卡，且这张卡在战斗确认时为里侧守备表示。
function c53828396.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击对象是这张卡，且该卡在本次战斗发生前为里侧守备表示。
	return Duel.GetAttackTarget()==e:GetHandler() and e:GetHandler():GetBattlePosition()==POS_FACEDOWN_DEFENSE
end
-- 装备效果的处理：若攻击怪兽仍与战斗关联且我方魔陷区有空位，则将这张卡装备给攻击怪兽，并设置装备限制以及下次对方回合准备阶段破坏那只怪兽的效果；若无法装备则破坏这张卡。
function c53828396.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击怪兽，作为这张卡要装备的目标。
	local tc=Duel.GetAttacker()
	if not tc:IsRelateToBattle() or not c:IsRelateToBattle() then return end
	-- 若我方魔陷区没有空位，或攻击怪兽是里侧表示，则无法进行装备。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() then
		-- 无法装备时，这张卡因效果被破坏。
		Duel.Destroy(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给攻击怪兽。
	Duel.Equip(tp,c,tc)
	-- 让这张卡变成攻击怪兽的装备卡。
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c53828396.eqlimit)
	c:RegisterEffect(e1)
	-- 下次的对方回合的准备阶段时，那只装备怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53828396,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c53828396.descon)
	e2:SetTarget(c53828396.destg)
	e2:SetOperation(c53828396.desop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	c:RegisterEffect(e2)
end
-- 装备限制：这张卡只能装备给效果持有者（即当时的攻击怪兽）。
function c53828396.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 破坏效果的发动条件：当前是对方回合（即不是这张卡的控制者的回合）。
function c53828396.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是这张卡的控制者，满足“下次的对方回合”的条件。
	return Duel.GetTurnPlayer()~=tp
end
-- 破坏效果发动时设定对象：取这张卡的装备对象（那只怪兽）作为将破坏的卡，并建立关联、登记操作信息。
function c53828396.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=e:GetHandler():GetEquipTarget()
	ec:CreateEffectRelation(e)
	e:SetLabelObject(ec)
	-- 将“破坏那只装备怪兽”的操作信息登记到当前连锁，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ec,1,0,0)
end
-- 破坏效果处理：若装备怪兽仍与效果关联且表侧表示，则尝试破坏它；若破坏失败则破坏这张卡自身。
function c53828396.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ec=e:GetLabelObject()
	if ec:IsRelateToEffect(e) and ec:IsFaceup() then
		-- 以效果破坏装备怪兽，判断是否破坏成功。
		if Duel.Destroy(ec,REASON_EFFECT)~=0 then
		-- 若装备怪兽未被破坏（例如破坏被无效或失败），则改为破坏这张卡自身。
		else Duel.Destroy(c,REASON_EFFECT) end
	end
end
