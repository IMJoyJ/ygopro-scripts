--闘気炎斬龍
-- 效果：
-- 龙族怪兽＋战士族·炎属性怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方回合，以自己场上1只战士族融合怪兽为对象才能发动。从自己的场上·墓地把这张卡当作装备魔法卡使用给那只自己怪兽装备。
-- ②：只要这张卡给「炎之剑士」或者有那个卡名记述的怪兽装备中，装备怪兽的攻击力上升700，同1次的战斗阶段中可以作2次攻击。
local s,id,o=GetID()
-- 初始化效果，注册融合召唤条件、装备效果和攻击力提升效果
function s.initial_effect(c)
	-- 记录该卡效果文本中记载着「炎之剑士」的卡名
	aux.AddCodeList(c,45231177)
	c:EnableReviveLimit()
	-- 设置融合召唤条件：使用龙族怪兽和战士族·炎属性怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),s.ffilter,true)
	-- ①：自己·对方回合，以自己场上1只战士族融合怪兽为对象才能发动。从自己的场上·墓地把这张卡当作装备魔法卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	-- 只要这张卡给「炎之剑士」或者有那个卡名记述的怪兽装备中，装备怪兽的攻击力上升700
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.eqcon)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	-- 同1次的战斗阶段中可以作2次攻击
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetCondition(s.eqcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断怪兽是否为战士族且具有炎属性
function s.ffilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsFusionAttribute(ATTRIBUTE_FIRE)
end
-- 过滤函数：判断怪兽是否为战士族融合怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_FUSION)
end
-- 装备效果的发动条件判断，检查是否有符合条件的怪兽可作为装备对象
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查场上是否有足够的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and c:CheckUniqueOnField(tp)
		-- 检查是否存在符合条件的装备对象
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备对象怪兽
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,c)
	if c:IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息，表示将从墓地离开的卡
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- 装备效果的处理函数，执行装备操作并设置装备限制
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁中选择的装备对象
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足，包括装备区域、对象控制权、对象状态等
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 若装备失败则将卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 执行装备操作，将卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc) then return end
	-- 设置装备限制效果，确保该卡只能装备给特定怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制效果的判断函数，确保只能装备给指定的怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判断装备怪兽是否为「炎之剑士」或记载有其卡名的怪兽
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local qc=e:GetHandler():GetEquipTarget()
	-- 判断装备怪兽是否为「炎之剑士」或记载有其卡名的怪兽
	return (qc:IsCode(45231177) or aux.IsCodeListed(qc,45231177))
end
