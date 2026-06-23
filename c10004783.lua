--宝玉の解放
-- 效果：
-- 「宝玉兽」怪兽才能装备。
-- ①：装备怪兽的攻击力上升800。
-- ②：这张卡从场上送去墓地时才能发动。从卡组选1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c10004783.initial_effect(c)
	-- 创建效果，设置类别为装备，类型为激活，触发条件为自由连锁，属性为可以指定对象和持续对象，设置目标函数为c10004783.target，操作函数为c10004783.operation，将效果注册到卡片。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c10004783.target)
	e1:SetOperation(c10004783.operation)
	c:RegisterEffect(e1)
	-- 创建效果，设置类型为装备，代码为更新攻击力，值为800，将效果注册到卡片。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 创建效果，设置类型为单次生效，代码为装备限制，属性为不可无效化，值为c10004783.eqlimit，将效果注册到卡片。相关子函数：c10004783.eqlimit: 返回卡片是否属于宝玉兽系列。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c10004783.eqlimit)
	c:RegisterEffect(e3)
	-- 创建效果，设置描述为“放置「宝玉兽」在魔法陷阱区”，类型为单次生效且诱发选发，属性为伤害步骤，代码为送入墓地，条件函数为c10004783.tfcon，目标函数为c10004783.tftg，操作函数为c10004783.tfop，将效果注册到卡片。相关子函数：c10004783.tfcon: 返回装备卡是否在场上过；c10004783.tftg: 检查是否有宝玉兽怪兽在卡组且魔法陷阱区有空位；c10004783.tfop: 从卡组选择一只宝玉兽怪兽放置到魔法陷阱区域，并将其类型更改为永续魔法。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(10004783,0))  --"放置「宝玉兽」在魔法陷阱区"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c10004783.tfcon)
	e4:SetTarget(c10004783.tftg)
	e4:SetOperation(c10004783.tfop)
	c:RegisterEffect(e4)
end
-- 返回卡片是否属于宝玉兽系列。
function c10004783.eqlimit(e,c)
	return c:IsSetCard(0x1034)
end
-- 返回卡片是否表侧表示且属于宝玉兽系列。
function c10004783.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034)
end
-- 设置目标函数，如果检查对象存在则返回真，否则返回假。提示玩家选择要装备的卡片，并进行选择。设置操作信息为装备类别。
function c10004783.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c10004783.filter(chkc) end
	-- 检查是否存在满足条件的的目标卡片。
	if chk==0 then return Duel.IsExistingTarget(c10004783.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从指定位置选择满足过滤条件的卡片。
	Duel.SelectTarget(tp,c10004783.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前处理的连锁的操作信息，类别为装备。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 设置操作函数，获取第一个目标卡片，如果效果发动者和目标卡片都与该效果相关且目标卡片表侧表示，则将效果发动者的卡片装备到目标卡片上。
function c10004783.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将一张卡片装备给另一张卡片。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 返回装备卡是否在场上过。
function c10004783.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，返回卡片是否为宝玉兽怪兽且未禁止。
function c10004783.tffilter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 设置目标函数，检查是否有宝玉兽怪兽在卡组且魔法陷阱区有空位。
function c10004783.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查魔法陷阱区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在满足条件的宝玉兽怪兽。
		and Duel.IsExistingMatchingCard(c10004783.tffilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 设置操作函数，如果魔法陷阱区没有空位则返回。提示玩家选择要放置到场上的卡片，并进行选择。从卡组选择一只宝玉兽怪兽放置到魔法陷阱区域表侧表示，并将其类型更改为永续魔法。
function c10004783.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔法陷阱区是否有空位。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向玩家发送提示信息“请选择要放置到场上的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从指定位置选择满足过滤条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c10004783.tffilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 将一张卡片移动到指定区域，以指定表示形式。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 创建效果，设置代码为改变类型，类型为单次生效，属性为不可无效化，重置条件为事件和标准重置，值为TYPE_SPELL+TYPE_CONTINUOUS，将效果注册到目标卡片。对应原文：从卡组选1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
