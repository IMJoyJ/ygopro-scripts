--聖剣を抱く王妃ギネヴィア
-- 效果：
-- 「怀抱圣剑的王后 桂妮薇儿」的①的效果1回合只能使用1次。
-- ①：以自己场上1只「圣骑士」怪兽为对象才能发动。手卡·墓地的这张卡当作攻击力上升300的装备卡使用给那只自己怪兽装备。
-- ②：得到装备怪兽的属性的以下效果。
-- ●光：装备怪兽被效果破坏的场合，可以作为代替把这张卡破坏。
-- ●暗：装备怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。那之后这张卡破坏。
function c19748583.initial_effect(c)
	-- ①：以自己场上1只「圣骑士」怪兽为对象才能发动。手卡·墓地的这张卡当作攻击力上升300的装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19748583,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,19748583)
	e1:SetTarget(c19748583.eqtg)
	e1:SetOperation(c19748583.eqop)
	c:RegisterEffect(e1)
	-- ●光：装备怪兽被效果破坏的场合，可以作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(c19748583.reptg)
	e3:SetOperation(c19748583.repop)
	c:RegisterEffect(e3)
	-- ●暗：装备怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。那之后这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c19748583.descon)
	e4:SetTarget(c19748583.destg)
	e4:SetOperation(c19748583.desop)
	c:RegisterEffect(e4)
end
-- 筛选场上表侧表示的「圣骑士」怪兽作为装备对象
function c19748583.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107a)
end
-- 判断是否满足装备条件
function c19748583.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19748583.filter(chkc) end
	-- 判断装备区域是否为空
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断场上是否存在「圣骑士」怪兽
		and Duel.IsExistingTarget(c19748583.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备对象
	Duel.SelectTarget(tp,c19748583.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 设置装备时的操作信息
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- 装备效果处理函数
function c19748583.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取选择的装备对象
	local tc=Duel.GetFirstTarget()
	-- 判断装备是否满足条件
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 执行装备操作
	Duel.Equip(tp,c,tc)
	-- 设置装备限制效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c19748583.eqlimit)
	c:RegisterEffect(e1)
	-- 设置装备卡攻击力上升300的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备卡只能装备给「圣骑士」怪兽
function c19748583.eqlimit(e,c)
	return c:IsSetCard(0x107a)
end
-- 判断是否满足代替破坏条件
function c19748583.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if chk==0 then return bit.band(r,REASON_EFFECT)~=0 and tc and tc:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and not tc:IsReason(REASON_REPLACE) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(e:GetOwnerPlayer(),c,96)
end
-- 代替破坏效果处理函数
function c19748583.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行代替破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 判断是否满足暗属性效果发动条件
function c19748583.descon(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetHandler():GetEquipTarget()
	-- 装备怪兽为暗属性且参与战斗
	return tg and tg:IsAttribute(ATTRIBUTE_DARK) and (Duel.GetAttacker()==tg or Duel.GetAttackTarget()==tg)
end
-- 设置暗属性效果的破坏操作信息
function c19748583.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget():GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) end
	local g=Group.FromCards(tc,c)
	-- 设置破坏操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 暗属性效果处理函数
function c19748583.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=c:GetEquipTarget():GetBattleTarget()
	-- 判断攻击怪兽是否可以被破坏
	if tc:IsRelateToBattle() and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 破坏装备卡
		Duel.Destroy(c,REASON_EFFECT)
	end
end
