--ゴゴゴゴーレム－GF
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只名字带有「隆隆隆」的怪兽解放的场合才能特殊召唤。这张卡的攻击力变成解放的那只怪兽的原本攻击力2倍的数值。这张卡的战斗发生的对对方的战斗伤害变成一半。此外，1回合1次，对方场上有效果怪兽的效果发动时发动。这张卡的攻击力下降1500，那个效果无效。
function c2948263.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上1只名字带有「隆隆隆」的怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c2948263.spcon)
	e2:SetTarget(c2948263.sptg)
	e2:SetOperation(c2948263.spop)
	c:RegisterEffect(e2)
	-- 这张卡的战斗发生的对对方的战斗伤害变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	-- 将该卡受到的战斗伤害改为一半。
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
	-- 此外，1回合1次，对方场上有效果怪兽的效果发动时发动。这张卡的攻击力下降1500，那个效果无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(2948263,0))  --"效果无效"
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_F)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c2948263.discon)
	e4:SetTarget(c2948263.distg)
	e4:SetOperation(c2948263.disop)
	c:RegisterEffect(e4)
end
-- 过滤满足条件的怪兽：名字带有「隆隆隆」，且在场上或里侧表示。
function c2948263.spfilter(c,tp)
	return c:IsSetCard(0x59)
		-- 且该怪兽所在区域有空位。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查玩家场上是否存在满足条件的可解放怪兽。
function c2948263.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在满足条件的可解放怪兽。
	return Duel.CheckReleaseGroupEx(tp,c2948263.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 检索满足条件的可解放怪兽组并提示选择。
function c2948263.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的怪兽组并过滤满足条件的怪兽。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c2948263.spfilter,nil,tp)
	-- 提示玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 解放选择的怪兽，并将该怪兽的原本攻击力乘以2作为此卡的攻击力。
function c2948263.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 解放选择的怪兽。
	Duel.Release(tc,REASON_SPSUMMON)
	local atk=tc:GetBaseAttack()
	-- 将此卡的攻击力设为解放怪兽的原本攻击力的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(atk*2)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 判断连锁是否可以被无效，且发动者不是此卡控制者，且发动的是怪兽效果，且在主要怪兽区发动。
function c2948263.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的发动者和发动位置。
	local tgp,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	-- 判断此卡未在战斗中被破坏且该连锁可被无效。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainDisablable(ev)
		and tgp~=tp and re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE
end
-- 设置效果发动时的操作信息为使效果无效。
function c2948263.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果发动时的操作信息为使效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 判断此卡满足发动条件后使连锁效果无效，并将此卡攻击力下降1500。
function c2948263.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡满足发动条件：未里侧表示、攻击力不低于1500、与效果相关、连锁顺序正确、未在战斗中被破坏。
	if c:IsFacedown() or c:GetAttack()<1500 or not c:IsRelateToEffect(e) or Duel.GetCurrentChain()~=ev+1 or c:IsStatus(STATUS_BATTLE_DESTROYED) then
		return
	end
	-- 使该连锁效果无效。
	Duel.NegateEffect(ev)
	-- 将此卡的攻击力下降1500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1500)
	c:RegisterEffect(e1)
end
