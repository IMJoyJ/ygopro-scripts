--剣闘獣の闘器ハルバード
-- 效果：
-- 名字带有「剑斗兽」的怪兽才能装备。装备怪兽进行攻击的伤害步骤结束时，把场上1张魔法或者陷阱卡破坏。装备怪兽从自己场上回到卡组让这张卡被送去墓地时，这张卡回到手卡。
function c99013397.initial_effect(c)
	-- 名字带有「剑斗兽」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c99013397.target)
	e1:SetOperation(c99013397.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽进行攻击的伤害步骤结束时，把场上1张魔法或者陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(99013397,0))  --"场上1张魔法或者陷阱卡破坏"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c99013397.descon)
	e2:SetTarget(c99013397.destg)
	e2:SetOperation(c99013397.desop)
	c:RegisterEffect(e2)
	-- 名字带有「剑斗兽」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c99013397.eqlimit)
	c:RegisterEffect(e3)
	-- 装备怪兽从自己场上回到卡组让这张卡被送去墓地时，这张卡回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetDescription(aux.Stringid(99013397,1))  --"返回手牌"
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c99013397.retcon)
	e4:SetTarget(c99013397.rettg)
	e4:SetOperation(c99013397.retop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给名字带有「剑斗兽」的怪兽
function c99013397.eqlimit(e,c)
	return c:IsSetCard(0x1019)
end
-- 过滤条件：场上表侧表示的名字带有「剑斗兽」的怪兽
function c99013397.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019)
end
-- 装备魔法卡发动时的对象选择与效果处理准备
function c99013397.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c99013397.filter(chkc) end
	-- 检查场上是否存在可以装备的表侧表示「剑斗兽」怪兽
	if chk==0 then return Duel.IsExistingTarget(c99013397.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的「剑斗兽」怪兽作为装备对象
	Duel.SelectTarget(tp,c99013397.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含装备操作，数量为1
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动后的效果处理（将自身装备给目标怪兽）
function c99013397.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 破坏效果的发动条件：装备怪兽是本次战斗的攻击怪兽
function c99013397.descon(e,tp,eg,ep,ev,re,r,rp)
	local eqc=e:GetHandler():GetEquipTarget()
	-- 判定装备怪兽是否为进行攻击的怪兽
	return eqc==Duel.GetAttacker()
end
-- 过滤条件：魔法或陷阱卡
function c99013397.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的对象选择与效果处理准备
function c99013397.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c99013397.dfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法或陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c99013397.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁信息，表示该效果包含破坏操作，数量为选择的卡片数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理：破坏选择的魔法或陷阱卡
function c99013397.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的破坏目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 回手效果的发动条件：因装备怪兽离开场上回到卡组（或额外卡组）导致失去装备对象而送去墓地
function c99013397.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 回手效果的准备：检查自身是否能加入手卡并设置连锁信息
function c99013397.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁信息，表示该效果包含将自身加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 回手效果的处理：将自身加入手卡并给对方确认
function c99013397.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果将这张卡送回持有者手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,c)
	end
end
