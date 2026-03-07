--D・イヤホン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时当作调整使用。
-- ②：以场上1只同调怪兽为对象才能发动。从自己的场上·墓地把这张卡当作装备卡使用给那只怪兽装备。
-- ③：有这张卡装备的怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
local s,id,o=GetID()
-- 初始化效果函数，设置同调召唤手续、启用特殊召唤限制，并注册三个效果
function s.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tntg)
	e1:SetOperation(s.tnop)
	c:RegisterEffect(e1)
	-- ②：以场上1只同调怪兽为对象才能发动。从自己的场上·墓地把这张卡当作装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	-- ③：有这张卡装备的怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤条件：对象怪兽必须表侧表示且不是调整
function s.tnfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TUNER)
end
-- 设置①效果的目标选择函数，选择一个表侧表示的非调整怪兽
function s.tntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tnfilter(chkc) end
	-- 检查是否有满足条件的怪兽可作为目标
	if chk==0 then return Duel.IsExistingTarget(s.tnfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择一个表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个表侧表示的非调整怪兽作为目标
	Duel.SelectTarget(tp,s.tnfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ①效果的处理函数，将目标怪兽变为调整
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 创建一个效果，使目标怪兽获得调整属性直到回合结束
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：对象怪兽必须表侧表示且是同调怪兽
function s.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 设置②效果的目标选择函数，选择一个表侧表示的同调怪兽
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc) and chkc~=c end
	-- 检查玩家场上是否有足够的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and c:CheckUniqueOnField(tp)
		-- 检查是否有满足条件的同调怪兽可作为目标
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 提示玩家选择一个要装备的同调怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个表侧表示的同调怪兽作为目标
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	if c:IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息，表示将从墓地离开一张卡
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- ②效果的处理函数，将该卡装备给目标同调怪兽
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查装备条件是否满足，包括装备区域、目标怪兽状态、唯一性等
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 若条件不满足则将该卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将该卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc) then return end
	-- 设置装备限制效果，确保该卡只能装备给指定的怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制函数，判断目标怪兽是否为装备对象
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
