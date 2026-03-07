--昆虫機甲鎧
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上没有「昆虫机甲铠」存在的场合，以自己场上1只昆虫族怪兽为对象才能发动。这张卡当作装备卡使用给那只怪兽装备。这张卡以及用这个效果把这张卡装备的怪兽从场上离开的场合除外。
-- ②：有这张卡装备的怪兽在双方的战斗阶段以及主要阶段2内攻击力上升1500，守备力上升2000。
function c3084730.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己场上没有「昆虫机甲铠」存在的场合，以自己场上1只昆虫族怪兽为对象才能发动。这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3084730,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,3084730)
	e1:SetCondition(c3084730.sscon)
	e1:SetTarget(c3084730.eqtg)
	e1:SetOperation(c3084730.eqop)
	c:RegisterEffect(e1)
	-- ②：有这张卡装备的怪兽在双方的战斗阶段以及主要阶段2内攻击力上升1500，守备力上升2000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c3084730.condition)
	e2:SetValue(1500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(2000)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在表侧表示的昆虫机甲铠
function c3084730.sfilter(c)
	return c:IsCode(3084730) and c:IsFaceup()
end
-- 效果条件：自己场上没有昆虫机甲铠表侧表示存在
function c3084730.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 自己场上没有昆虫机甲铠表侧表示存在
	return not Duel.IsExistingMatchingCard(c3084730.sfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数，用于判断场上是否存在表侧表示的昆虫族怪兽
function c3084730.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 效果处理的条件判断：检查是否有满足条件的怪兽可作为装备对象
function c3084730.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c3084730.filter(chkc) and chkc~=c end
	-- 检查场上是否有足够的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():CheckUniqueOnField(tp)
		-- 检查是否存在满足条件的装备对象
		and Duel.IsExistingTarget(c3084730.filter,tp,LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备对象怪兽
	Duel.SelectTarget(tp,c3084730.filter,tp,LOCATION_MZONE,0,1,1,c)
	if c:IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息：将此卡从墓地离开的效果加入操作信息
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,0,0,0)
	end
end
-- 装备效果处理函数
function c3084730.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁中选择的装备对象
	local tc=Duel.GetFirstTarget()
	-- 检查装备区域是否足够或目标怪兽是否里侧表示
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown()
		or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 将此卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将此卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc) then return end
	-- 装备对象限制效果：此卡只能装备给指定的怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c3084730.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 装备怪兽离开场上的处理：将装备怪兽移至除外区
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e2:SetValue(LOCATION_REMOVED)
	tc:RegisterEffect(e2)
	-- 此卡离开场上的处理：将此卡移至除外区
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
end
-- 装备对象限制函数：判断装备对象是否为指定怪兽
function c3084730.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 效果适用条件：当前阶段为双方的主要阶段2或战斗阶段
function c3084730.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
