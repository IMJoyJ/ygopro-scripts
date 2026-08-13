--昆虫機甲鎧
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上没有「昆虫机甲铠」存在的场合，以自己场上1只昆虫族怪兽为对象才能发动。这张卡当作装备卡使用给那只怪兽装备。这张卡以及用这个效果把这张卡装备的怪兽从场上离开的场合除外。
-- ②：有这张卡装备的怪兽在双方的战斗阶段以及主要阶段2内攻击力上升1500，守备力上升2000。
function c3084730.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在，自己场上没有「昆虫机甲铠」存在的场合，以自己场上1只昆虫族怪兽为对象才能发动。这张卡当作装备卡使用给那只怪兽装备。这张卡以及用这个效果把这张卡装备的怪兽从场上离开的场合除外。
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
	-- ②：有这张卡装备的怪兽在双方的战斗阶段以及主要阶段2内攻击力上升1500
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
-- 判断卡片是否为表侧表示的「昆虫机甲铠」（卡号3084730）。
function c3084730.sfilter(c)
	return c:IsCode(3084730) and c:IsFaceup()
end
-- 效果①的发动条件：自己场上不存在表侧表示的「昆虫机甲铠」。
function c3084730.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「昆虫机甲铠」，若不存在则返回true（满足发动条件）。
	return not Duel.IsExistingMatchingCard(c3084730.sfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 判断卡片是否为表侧表示的昆虫族怪兽，用作装备对象的选择条件。
function c3084730.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- ①的取对象处理函数：若指定对象（chkc）则检查其是否为自己场上表侧昆虫族怪兽且非自身；若为发动确认（chk==0），则检查魔陷区是否有空位、自身在场上是否唯一，以及是否存在可选的目标。
function c3084730.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c3084730.filter(chkc) and chkc~=c end
	-- 发动确认（chk==0）时，检查自己的魔陷区是否有空位（用于放置这张装备卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():CheckUniqueOnField(tp)
		-- 同时检查自己场上是否存在至少1只表侧昆虫族怪兽（且不能选择这张卡自身）作为装备对象。
		and Duel.IsExistingTarget(c3084730.filter,tp,LOCATION_MZONE,0,1,c) end
	-- 发送选择提示消息，提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1只表侧昆虫族怪兽（不能选择这张卡自身）作为效果对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,c3084730.filter,tp,LOCATION_MZONE,0,1,1,c)
	if c:IsLocation(LOCATION_GRAVE) then
		-- 若这张卡在墓地发动，则设置操作信息为涉及墓地（CATEGORY_LEAVE_GRAVE），以便相关效果（如王家长眠之谷）响应。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,0,0,0)
	end
end
-- 效果①的装备处理开始：先确认这张卡仍与效果关联，并获取目标；若魔陷区无空位、目标里侧、目标失去关联或自身不再唯一，则将这张卡送去墓地并结束处理。
function c3084730.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 取得发动时选择的装备对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断处理条件：自己魔陷区空位不足，或目标怪兽已变成里侧表示。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown()
		or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 由于处理条件不满足，将这张卡以效果原因送入墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽，若装备失败则终止处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- 这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c3084730.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 用这个效果把这张卡装备的怪兽从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e2:SetValue(LOCATION_REMOVED)
	tc:RegisterEffect(e2)
	-- 这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
end
-- 装备限制判定：检查传入的卡是否为之前选择的目标怪兽，只有该目标怪兽可以作为这张卡的装备对象。
function c3084730.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ②效果适用的阶段条件：当前阶段为主要阶段2，或处于战斗阶段（从开始到结束）内。
function c3084730.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段并存入局部变量ph，供后续条件判断使用。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
