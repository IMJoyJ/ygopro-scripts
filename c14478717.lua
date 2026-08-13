--リブロマンサー・プリベント
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有「书灵师」怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽不能作为融合·同调·超量·连接召唤的素材。
-- ②：自己·对方的结束阶段，「书灵师」仪式怪兽不在自己场上存在的场合发动。这张卡送去墓地。
local s,id,o=GetID()
-- 注册该卡的三个效果：①允许魔陷发动的ACTIVATE空效果；②对应①效果，以对方场上一只表侧表示怪兽为对象，赋予其不能作为融合·同调·超量·连接召唤的素材（1回合1次）；③对应②效果，结束阶段场上没有「书灵师」仪式怪兽时自身送去墓地。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上有「书灵师」怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽不能作为融合·同调·超量·连接召唤的素材。
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
-- 过滤条件：判断卡为表侧表示且属于「书灵师」字段。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x17c)
end
-- ①效果的发动条件：自己场上有表侧表示且「书灵师」字段的怪兽存在。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足s.cfilter条件的「书灵师」怪兽，存在则条件成立。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的目标处理：效果发动时选择对方场上1只表侧表示怪兽为对象；若为连锁处理中的对象合法性校验，则校验对象是对方场上表侧表示怪兽；若为发动合法性检查，则检查对方场上有无可选对象；之后弹出选择提示并选择对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在效果发动的合法性检查阶段（chk==0），确认对方场上有至少1只表侧表示怪兽能成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 发送选择提示消息，让玩家选择表侧表示的卡（用于指定对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只表侧表示怪兽作为该效果的对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ①效果处理时：获取对象怪兽，若对象仍与此效果关联且表侧表示且为怪兽，则给它赋予多个‘不能作为素材’的永续效果：不能作为融合·同调·超量·连接召唤的素材，持续到这个回合结束。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取该效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 那只表侧表示怪兽不能作为融合·同调·超量·连接召唤的素材。
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
-- 融合素材限制的判定函数：只在召唤类型为融合召唤时返回true，表示不能作为融合素材。
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 过滤条件：表侧表示且属于「书灵师」字段且为仪式怪兽（用于②效果的发动条件判断）。
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x17c) and c:IsType(TYPE_RITUAL)
end
-- ②效果的发动条件：自己场上不存在表侧表示的「书灵师」仪式怪兽。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在满足s.filter条件的怪兽；不存在则返回true，即满足②效果发动条件。
	return not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标函数：本效果不取对象，发动时直接返回可行，并设置将自身送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将这张卡（效果持有者）送去墓地（分类为CATEGORY_TOGRAVE），以便连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与此效果关联，则将这张卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与效果关联后，以效果原因将这张卡送去墓地。
	if c:IsRelateToEffect(e) then Duel.SendtoGrave(c,REASON_EFFECT) end
end
