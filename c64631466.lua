--サクリファイス
-- 效果：
-- 「幻想的仪式」降临。
-- ①：1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽当作装备卡使用给这张卡装备（只有1只可以装备）。
-- ②：这张卡的攻击力·守备力变成这张卡的效果装备的怪兽的各自数值，这张卡被战斗破坏的场合，作为代替把装备的那只怪兽破坏。
-- ③：用这张卡的效果把怪兽装备的这张卡的战斗让自己受到战斗伤害时，对方也受到相同数值的效果伤害。
function c64631466.initial_effect(c)
	aux.AddCodeList(c,41426869)
	c:EnableReviveLimit()
	-- ①：1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽当作装备卡使用给这张卡装备（只有1只可以装备）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64631466,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c64631466.eqcon)
	e1:SetTarget(c64631466.eqtg)
	e1:SetOperation(c64631466.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力·守备力变成这张卡的效果装备的怪兽的各自数值
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetCondition(c64631466.adcon)
	e2:SetValue(c64631466.atkval)
	c:RegisterEffect(e2)
	-- ②：这张卡的攻击力·守备力变成这张卡的效果装备的怪兽的各自数值
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SET_DEFENSE)
	e3:SetCondition(c64631466.adcon)
	e3:SetValue(c64631466.defval)
	c:RegisterEffect(e3)
	-- ③：用这张卡的效果把怪兽装备的这张卡的战斗让自己受到战斗伤害时，对方也受到相同数值的效果伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c64631466.damcon)
	e4:SetOperation(c64631466.damop)
	c:RegisterEffect(e4)
end
-- 判定是否满足发动条件：自身当前没有通过自身效果装备的怪兽
function c64631466.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return c64631466.can_equip_monster(e:GetHandler())
end
-- 过滤函数：筛选带有本卡卡号标记（即通过本卡效果装备）的卡片
function c64631466.eqfilter(c)
	return c:GetFlagEffect(64631466)~=0
end
-- 判断自身当前是否未装备通过自身效果装备的怪兽
function c64631466.can_equip_monster(c)
	local g=c:GetEquipGroup():Filter(c64631466.eqfilter,nil)
	return g:GetCount()==0
end
-- 效果①的Target函数：检查魔法与陷阱区域是否有空位，并选择对方场上1只可以转移控制权的怪兽作为对象
function c64631466.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	-- 在发动准备阶段，检查当前玩家的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且对方场上存在可以转移控制权的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只可以转移控制权的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制函数：该装备卡只能装备给本卡
function c64631466.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 执行装备怪兽的操作：若本卡已装备其他怪兽则将目标送去墓地，否则将目标作为装备卡装备给本卡，并注册装备限制与代替破坏效果
function c64631466.equip_monster(c,tp,tc)
	if c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and not c64631466.can_equip_monster(c) then
		-- 根据规则，将无法装备的目标怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_RULE)
		return
	end
	-- 将目标怪兽作为装备卡装备给本卡，若装备失败则结束处理
	if not Duel.Equip(tp,tc,c,false) then return end
	tc:RegisterFlagEffect(64631466,RESET_EVENT+RESETS_STANDARD,0,0)
	-- 那只对方怪兽当作装备卡使用给这张卡装备（只有1只可以装备）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c64631466.eqlimit)
	tc:RegisterEffect(e1)
	-- 这张卡被战斗破坏的场合，作为代替把装备的那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(c64631466.repval)
	tc:RegisterEffect(e2)
end
-- 效果①的Operation函数：获取选择的对象，若其仍满足条件则将其作为装备卡装备给本卡
function c64631466.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsControler(1-tp) then
		c64631466.equip_monster(c,tp,tc)
	end
end
-- 代替破坏的判定：仅在因战斗破坏时可以进行代替破坏
function c64631466.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 效果③的发动条件：本卡装备有通过自身效果装备的怪兽，且本卡进行战斗使自身受到战斗伤害
function c64631466.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c64631466.eqfilter,nil)
	return g:GetCount()>0 and ep==tp
		-- 且本卡是本次战斗的攻击怪兽或被攻击怪兽
		and (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler())
end
-- 效果③的Operation函数：给与对方与自身受到的战斗伤害相同数值的效果伤害
function c64631466.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给与对方玩家相同数值的效果伤害
	Duel.Damage(1-tp,ev,REASON_EFFECT)
end
-- 攻击力·守备力变化效果的适用条件：本卡装备有通过自身效果装备的怪兽
function c64631466.adcon(e)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c64631466.eqfilter,nil)
	return g:GetCount()>0
end
-- 攻击力数值计算：获取装备怪兽的原本攻击力，若装备怪兽里侧表示、非怪兽卡或攻击力小于0，则攻击力变为0
function c64631466.atkval(e,c)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c64631466.eqfilter,nil)
	local atk=g:GetFirst():GetTextAttack()
	if g:GetFirst():IsFacedown() or bit.band(g:GetFirst():GetOriginalType(),TYPE_MONSTER)==0 or atk<0 then
		return 0
	else
		return atk
	end
end
-- 守备力数值计算：获取装备怪兽的原本守备力，若装备怪兽里侧表示、非怪兽卡或守备力小于0，则守备力变为0
function c64631466.defval(e,c)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c64631466.eqfilter,nil)
	local def=g:GetFirst():GetTextDefense()
	if g:GetFirst():IsFacedown() or bit.band(g:GetFirst():GetOriginalType(),TYPE_MONSTER)==0 or def<0 then
		return 0
	else
		return def
	end
end
