--宝玉の解放
-- 效果：
-- 「宝玉兽」怪兽才能装备。
-- ①：装备怪兽的攻击力上升800。
-- ②：这张卡从场上送去墓地时才能发动。从卡组选1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c10004783.initial_effect(c)
	-- ②：这张卡从场上送去墓地时才能发动。从卡组选1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c10004783.target)
	e1:SetOperation(c10004783.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 「宝玉兽」怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c10004783.eqlimit)
	c:RegisterEffect(e3)
	-- ②：这张卡从场上送去墓地时才能发动。从卡组选1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
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
-- 装备对象限制函数，用于判断是否能装备此卡
function c10004783.eqlimit(e,c)
	return c:IsSetCard(0x1034)
end
-- 筛选场上可装备的「宝玉兽」怪兽
function c10004783.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034)
end
-- 装备效果的处理函数，用于选择装备对象
function c10004783.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c10004783.filter(chkc) end
	-- 判断是否满足装备条件，即场上是否存在「宝玉兽」怪兽
	if chk==0 then return Duel.IsExistingTarget(c10004783.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择场上满足条件的「宝玉兽」怪兽作为装备对象
	Duel.SelectTarget(tp,c10004783.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备效果的执行函数
function c10004783.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 发动条件判断函数，用于判断此卡是否从场上送去墓地
function c10004783.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选卡组中可使用的「宝玉兽」怪兽
function c10004783.tffilter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 发动效果的处理函数，用于选择从卡组特殊召唤的怪兽
function c10004783.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即自己魔法陷阱区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断卡组中是否存在满足条件的「宝玉兽」怪兽
		and Duel.IsExistingMatchingCard(c10004783.tffilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 发动效果的执行函数，用于将怪兽当作永续魔法卡使用
function c10004783.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足发动条件，即自己魔法陷阱区是否有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置的「宝玉兽」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	-- 从卡组中选择1只满足条件的「宝玉兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c10004783.tffilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 将选中的怪兽移动到自己的魔法陷阱区
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 将选中的怪兽转换为永续魔法卡类型
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
