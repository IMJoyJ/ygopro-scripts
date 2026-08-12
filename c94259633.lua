--サクリファイス・アニマ
-- 效果：
-- 衍生物以外的1星怪兽1只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以这张卡所连接区1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽当作装备魔法卡使用给这张卡装备（只有1只可以装备）。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
function c94259633.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤的手续，需要1只满足过滤条件的怪兽作为素材
	aux.AddLinkProcedure(c,c94259633.matfilter,1)
	-- ①：以这张卡所连接区1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽当作装备魔法卡使用给这张卡装备（只有1只可以装备）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94259633,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,94259633)
	e1:SetCondition(c94259633.eqcon)
	e1:SetTarget(c94259633.eqtg)
	e1:SetOperation(c94259633.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c94259633.adcon)
	e2:SetValue(c94259633.atkval)
	c:RegisterEffect(e2)
end
-- 过滤连接素材：等级为1且非衍生物的怪兽
function c94259633.matfilter(c)
	return c:IsLevel(1) and not c:IsLinkType(TYPE_TOKEN)
end
-- 效果①的发动条件：自身没有通过自身效果装备的怪兽（满足“只有1只可以装备”的限制）
function c94259633.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return c94259633.can_equip_monster(e:GetHandler())
end
-- 过滤通过此卡效果装备的卡（带有此卡卡号的FlagEffect）
function c94259633.eqfilter(c)
	return c:GetFlagEffect(94259633)~=0
end
-- 检查当前是否没有通过此卡效果装备的怪兽
function c94259633.can_equip_monster(c)
	local g=c:GetEquipGroup():Filter(c94259633.eqfilter,nil)
	return g:GetCount()==0
end
-- 过滤可装备的对象：表侧表示、在连接端（所连接区）、且可以转移控制权（若是对方的）或属于自己
function c94259633.eqfilter2(c,tp,lg)
	return c:IsFaceup() and (c:IsAbleToChangeControler() or c:IsControler(tp)) and lg:IsContains(c)
end
-- 效果①的靶向/发动准备：检查魔法与陷阱区域是否有空位，并选择所连接区1只表侧表示怪兽作为对象
function c94259633.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	-- 检查发动玩家的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在可以作为装备对象的、位于此卡连接端的表侧表示怪兽
		and Duel.IsExistingTarget(c94259633.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,lg) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c94259633.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,lg)
end
-- 装备限制：只能装备给此卡（效果来源卡）
function c94259633.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 执行装备操作：将目标怪兽作为装备卡装备给此卡，并添加对应的标记和装备限制效果
function c94259633.equip_monster(c,tp,tc)
	-- 尝试将目标怪兽作为装备卡装备给此卡，若失败则结束处理
	if not Duel.Equip(tp,tc,c,false) then return end
	tc:RegisterFlagEffect(94259633,RESET_EVENT+RESETS_STANDARD,0,0)
	-- 当作装备魔法卡使用给这张卡装备（只有1只可以装备）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c94259633.eqlimit)
	tc:RegisterEffect(e1)
end
-- 效果①的效果处理：获取对象怪兽，若其仍表侧表示存在且为怪兽卡，则将其装备给此卡
function c94259633.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		c94259633.equip_monster(c,tp,tc)
	end
end
-- 攻击力上升效果的适用条件：自身装备有通过自身效果装备的怪兽
function c94259633.adcon(e)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c94259633.eqfilter,nil)
	return g:GetCount()>0
end
-- 计算攻击力上升数值：获取通过自身效果装备的怪兽的原本攻击力（若非怪兽或数值小于0则为0）
function c94259633.atkval(e,c)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c94259633.eqfilter,nil)
	local atk=g:GetFirst():GetTextAttack()
	if bit.band(g:GetFirst():GetOriginalType(),TYPE_MONSTER)==0 or atk<0 then
		return 0
	else
		return atk
	end
end
