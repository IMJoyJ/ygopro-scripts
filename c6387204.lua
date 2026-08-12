--CNo.6 先史遺産カオス・アトランタル
-- 效果：
-- 7星怪兽×3
-- ①：这张卡的效果发动过的回合，对方受到的全部伤害变成0。
-- ②：1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽当作攻击力上升1000的装备卡使用给这张卡装备。
-- ③：这张卡有「No.6 先史遗产 大西洲巨人」在作为超量素材的场合，得到以下效果。
-- ●把这张卡3个超量素材取除，把这张卡的效果装备的「No.」怪兽卡全部送去墓地才能发动。对方基本分变成100。
function c6387204.initial_effect(c)
	-- 添加XYZ召唤手续：7星怪兽×3。
	aux.AddXyzProcedure(c,nil,7,3)
	c:EnableReviveLimit()
	-- ②：1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽当作攻击力上升1000的装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6387204,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c6387204.eqtg)
	e1:SetOperation(c6387204.eqop)
	c:RegisterEffect(e1)
	-- ③：这张卡有「No.6 先史遗产 大西洲巨人」在作为超量素材的场合，得到以下效果。●把这张卡3个超量素材取除，把这张卡的效果装备的「No.」怪兽卡全部送去墓地才能发动。对方基本分变成100。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6387204,1))  --"基本分变成100"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c6387204.lpcon)
	e2:SetCost(c6387204.lpcost)
	e2:SetOperation(c6387204.lpop)
	c:RegisterEffect(e2)
end
-- 设置该卡的「No.」编号为6。
aux.xyz_number[6387204]=6
-- 装备效果的对象筛选与准备函数。
function c6387204.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	-- 判定自身魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定对方场上是否存在可以转移控制权的怪兽作为对象。
		and Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只可以转移控制权的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备效果的执行函数。
function c6387204.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽作为装备卡装备给这张卡，若装备失败则结束处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 当作装备卡使用给这张卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c6387204.eqlimit)
		tc:RegisterEffect(e1)
		-- 攻击力上升1000
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(1000)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(6387204,RESET_EVENT+RESETS_STANDARD,0,0)
	end
	-- ①：这张卡的效果发动过的回合，对方受到的全部伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetValue(0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使对方受到的伤害变成0的全局效果。
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使对方受到的效果伤害变成0的全局效果。
	Duel.RegisterEffect(e4,tp)
end
-- 装备限制函数，规定该卡只能装备给当前卡（混沌大西洲巨人）。
function c6387204.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 对方基本分变成100效果的发动条件函数。
function c6387204.lpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定对方基本分不等于100，且这张卡有「No.6 先史遗产 大西洲巨人」在作为超量素材。
	return Duel.GetLP(1-tp)~=100 and e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,9161357)
end
-- 过滤出由这张卡的效果装备的、且可以送去墓地的「No.」怪兽卡。
function c6387204.filter(c)
	return c:GetFlagEffect(6387204)~=0 and c:IsSetCard(0x48) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 对方基本分变成100效果的发动代价（Cost）判定与执行函数。
function c6387204.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST)
		and e:GetHandler():GetEquipGroup():IsExists(c6387204.filter,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
	local g=e:GetHandler():GetEquipGroup():Filter(c6387204.filter,nil)
	-- 将符合条件的装备「No.」怪兽卡送去墓地作为发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 对方基本分变成100效果的执行函数。
function c6387204.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方的基本分变成100。
	Duel.SetLP(1-tp,100)
	-- ①：这张卡的效果发动过的回合，对方受到的全部伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使对方受到的全部伤害变成0的全局效果。
	Duel.RegisterEffect(e1,tp)
end
