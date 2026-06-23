--リブロマンサー・プリベント
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有「书灵师」怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽不能作为融合·同调·超量·连接召唤的素材。
-- ②：自己·对方的结束阶段，「书灵师」仪式怪兽不在自己场上存在的场合发动。这张卡送去墓地。
local s,id,o=GetID()
-- 注册卡的初始效果，包括允许发动的空效果、①效果和②效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有「书灵师」怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽不能作为融合·同调·超量·连接召唤的素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"不能作为素材"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	-- ②：自己·对方的结束阶段，「书灵师」仪式怪兽不在自己场上存在的场合发动。这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"这张卡送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在表侧表示的「书灵师」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x17c)
end
-- 判断条件函数，检查是否满足①效果的发动条件
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「书灵师」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置①效果的目标选择函数，选择对方场上的1只表侧表示怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否满足①效果的目标选择条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的1只表侧表示怪兽作为目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ①效果的处理函数，为选中的目标怪兽添加不能作为各种召唤素材的效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 为选中的目标怪兽添加不能作为连接召唤素材的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e3:SetValue(s.fuslimit)
		tc:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e4)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		e5:SetDescription(aux.Stringid(id,1))  --"「书灵师阻拦」效果适用中"
		e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		tc:RegisterEffect(e5)
	end
end
-- 融合召唤素材限制函数，用于限制融合召唤
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 过滤函数，用于判断场上是否存在表侧表示的「书灵师」仪式怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x17c) and c:IsType(TYPE_RITUAL)
end
-- ②效果的发动条件函数，检查自己场上是否不存在「书灵师」仪式怪兽
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在「书灵师」仪式怪兽
	return not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标设定函数，设置将此卡送去墓地
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定将此卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- ②效果的处理函数，将此卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否还在场上，若在则将其送去墓地
	if c:IsRelateToEffect(e) then Duel.SendtoGrave(c,REASON_EFFECT) end
end
