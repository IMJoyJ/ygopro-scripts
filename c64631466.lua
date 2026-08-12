--サクリファイス
-- 效果：
-- 「幻想的仪式」降临。
-- ①：1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽当作装备卡使用给这张卡装备（只有1只可以装备）。
-- ②：这张卡的攻击力·守备力变成这张卡的效果装备的怪兽的各自数值，这张卡被战斗破坏的场合，作为代替把装备的那只怪兽破坏。
-- ③：用这张卡的效果把怪兽装备的这张卡的战斗让自己受到战斗伤害时，对方也受到相同数值的效果伤害。
function c64631466.initial_effect(c)
	-- 在卡片的关联卡列表中添加「幻想的仪式」的卡片密码
	aux.AddCodeList(c,41426869)
	c:EnableReviveLimit()
	-- 1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽当作装备卡使用给这张卡装备（只有1只可以装备）。
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
	-- 这张卡的攻击力·守备力变成这张卡的效果装备的怪兽的各自数值
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetCondition(c64631466.adcon)
	e2:SetValue(c64631466.atkval)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力·守备力变成这张卡的效果装备的怪兽的各自数值
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SET_DEFENSE)
	e3:SetCondition(c64631466.adcon)
	e3:SetValue(c64631466.defval)
	c:RegisterEffect(e3)
	-- 用这张卡的效果把怪兽装备的这张卡的战斗让自己受到战斗伤害时，对方也受到相同数值的效果伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c64631466.damcon)
	e4:SetOperation(c64631466.damop)
	c:RegisterEffect(e4)
end
-- 发动条件：检查这张卡是否没有通过自身效果装备怪兽
function c64631466.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return c64631466.can_equip_monster(e:GetHandler())
end
-- 过滤条件：通过该卡自身效果装备的卡片
function c64631466.eqfilter(c)
	return c:GetFlagEffect(64631466)~=0
end
-- 检查自身是否没有通过自身效果装备怪兽
function c64631466.can_equip_monster(c)
	local g=c:GetEquipGroup():Filter(c64631466.eqfilter,nil)
	return g:GetCount()==0
end
-- 选择对方场上1只怪兽作为效果的对象，并进行魔法陷阱区域空余格数的检查
function c64631466.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	-- 检查自己的魔法与陷阱区域是否有空余的格子
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否存在可以作为效果对象且能够夺取控制权的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制条件：限制只能装备在自身上面
function c64631466.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 将目标怪兽作为装备卡装备给这张卡，并为该装备卡注册装备限制以及代替破坏的效果
function c64631466.equip_monster(c,tp,tc)
	if c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and not c64631466.can_equip_monster(c) then
		-- 当这张卡已经装备了自身效果的怪兽时，试图装备的怪兽将因为规则送入墓地
		Duel.SendtoGrave(tc,REASON_RULE)
		return
	end
	-- 将目标怪兽作为装备卡装备给这张卡，若装备失败则结束处理
	if not Duel.Equip(tp,tc,c,false) then return end
	tc:RegisterFlagEffect(64631466,RESET_EVENT+RESETS_STANDARD,0,0)
	-- 那只对方怪兽当作装备卡使用给这张卡装备（只有1只可以装备）
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
-- 效果处理：将选择的对方场上的怪兽作为装备卡装备给自身
function c64631466.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsControler(1-tp) then
		c64631466.equip_monster(c,tp,tc)
	end
end
-- 代替破坏的判定条件：检查破坏原因是否为战斗破坏
function c64631466.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 反弹战斗伤害效果的触发条件：这张卡已装备自身效果的怪兽、自己受到战斗伤害且这张卡参与了该次战斗
function c64631466.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c64631466.eqfilter,nil)
	return g:GetCount()>0 and ep==tp
		-- 检查这张卡是否是本次战斗的攻击怪兽或是被攻击的目标
		and (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler())
end
-- 反弹战斗伤害效果的处理：给对方造成与自己受到的战斗伤害相同数值的效果伤害
function c64631466.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给对方玩家造成与本次战斗中自己受到的战斗伤害相同数值的效果伤害
	Duel.Damage(1-tp,ev,REASON_EFFECT)
end
-- 攻击力·守备力改变效果的适用条件：检查自身是否装备了通过自身效果装备的怪兽
function c64631466.adcon(e)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c64631466.eqfilter,nil)
	return g:GetCount()>0
end
-- 数值计算：计算这张卡效果装备的怪兽的攻击力数值，若不是怪兽卡或小于0则返回0
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
-- 数值计算：计算这张卡效果装备的怪兽的守备力数值，若不是怪兽卡或小于0则返回0
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
