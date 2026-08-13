--転生炎獣ヒートライオ
-- 效果：
-- 炎属性效果怪兽2只以上
-- ①：这张卡连接召唤的场合，以对方的魔法与陷阱区域1张卡为对象才能发动。那张卡回到卡组。
-- ②：这张卡是已用「转生炎兽 炽热多头狮」为素材作连接召唤的场合，1回合1次，以场上1只表侧表示怪兽和自己墓地1只怪兽为对象才能发动。作为对象的场上的怪兽的攻击力直到回合结束时变成和作为对象的墓地的怪兽的攻击力相同。
function c41463181.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加连接召唤手续：需要2只以上满足matfilter的怪兽（炎属性效果怪兽）作为连接素材，对应卡片的召唤条件“炎属性效果怪兽2只以上”。
	aux.AddLinkProcedure(c,c41463181.matfilter,2)
	-- ①：这张卡连接召唤的场合，以对方的魔法与陷阱区域1张卡为对象才能发动。那张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41463181,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(c41463181.tdcon)
	e1:SetTarget(c41463181.tdtg)
	e1:SetOperation(c41463181.tdop)
	c:RegisterEffect(e1)
	-- ②：这张卡是已用「转生炎兽 炽热多头狮」为素材作连接召唤的场合，1回合1次，以场上1只表侧表示怪兽和自己墓地1只怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(c41463181.condition)
	e2:SetOperation(c41463181.operation)
	c:RegisterEffect(e2)
	-- ②：这张卡是已用「转生炎兽 炽热多头狮」为素材作连接召唤的场合。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c41463181.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 连接素材的过滤条件：素材必须是效果怪兽且属性为炎属性。
function c41463181.matfilter(c)
	return c:IsLinkType(TYPE_EFFECT) and c:IsLinkAttribute(ATTRIBUTE_FIRE)
end
-- ①效果的发动条件：该卡是以连接召唤方式特殊召唤成功的场合。
function c41463181.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 对象过滤条件：对方魔陷区（不含场地区）的卡且能够回到卡组。
function c41463181.tdfilter(c)
	return c:GetSequence()<5 and c:IsAbleToDeck()
end
-- ①效果的发动时处理：选择对方魔陷区1张能回卡组的卡作为对象，并设置回卡组的操作信息。
function c41463181.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c41463181.tdfilter(chkc) end
	-- 发动合法性检查：确认对方魔陷区存在至少1张满足条件的卡片。
	if chk==0 then return Duel.IsExistingTarget(c41463181.tdfilter,tp,0,LOCATION_SZONE,1,nil) end
	-- 向玩家显示选择提示，提示文字为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从对方魔陷区选择1张满足条件的卡作为效果对象。
	local g=Duel.SelectTarget(tp,c41463181.tdfilter,tp,0,LOCATION_SZONE,1,1,nil)
	-- 登记本次操作信息：将选择的对象卡送入卡组（CATEGORY_TODECK），供相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ①效果处理：取得对象卡，若仍与效果关联，则将其送回持有者卡组并洗牌。
function c41463181.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中登记的第一张（也是唯一一张）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将该卡送回持有者卡组，并标记为需要洗牌（弹回卡组）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- e2的触发条件：该卡是连接召唤成功，并且素材检查中确认已用「转生炎兽 炽热多头狮」作为素材（label为1）。
function c41463181.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- e2效果操作：为本卡注册一个起动效果（②效果），使其满足条件后可在自己主要阶段发动。
function c41463181.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：1回合1次，以场上1只表侧表示怪兽和自己墓地1只怪兽为对象才能发动。作为对象的场上的怪兽的攻击力直到回合结束时变成和作为对象的墓地的怪兽的攻击力相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41463181,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c41463181.atktg)
	e1:SetOperation(c41463181.atkop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 场上怪兽的选择过滤：怪兽必须表侧表示，并且自己墓地存在可与其攻击力比较的怪兽。
function c41463181.atkfilter1(c,tp)
	-- 过滤条件具体判断：该怪兽表侧表示，且自己墓地存在至少1只满足atkfilter2的怪兽。
	return c:IsFaceup() and Duel.IsExistingTarget(c41463181.atkfilter2,tp,LOCATION_GRAVE,0,1,nil,c)
end
-- 墓地怪兽的选择过滤：是怪兽卡、攻击力与场上对象怪兽的攻击力不同，且原始攻击力不为负数。
function c41463181.atkfilter2(c,tc)
	return c:IsType(TYPE_MONSTER) and c:GetAttack()~=tc:GetAttack() and c:GetTextAttack()>=0
end
-- ②效果的发动时处理：先选择场上1只表侧表示怪兽，再选择自己墓地1只攻击力不同的怪兽作为对象，并将场上对象存入label。
function c41463181.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检查：场上和墓地中是否存在满足条件的一组对象组合。
	if chk==0 then return Duel.IsExistingTarget(c41463181.atkfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 向玩家显示选择提示，提示文字为“请选择表侧表示的卡”，用于选择场上对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为对象，并将它记录到效果的label中。
	local g=Duel.SelectTarget(tp,c41463181.atkfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	-- 向玩家显示选择提示，提示文字为“请选择效果的对象”，用于选择墓地对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1只满足条件且攻击力与场上对象不同的怪兽作为第二个对象。
	Duel.SelectTarget(tp,c41463181.atkfilter2,tp,LOCATION_GRAVE,0,1,1,nil,g:GetFirst())
end
-- ②效果处理：取得两个对象，验证关联后，将墓地对象怪兽的攻击力设为场上对象怪兽的最终攻击力，持续到回合结束。
function c41463181.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 取得当前连锁处理时的所有对象卡片组（包括场上怪兽和墓地怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sc=g:GetFirst()
	if sc==tc then sc=g:GetNext() end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or not sc:IsRelateToEffect(e) then return end
	local ac=e:GetLabelObject()
	if tc==ac then tc=sc end
	local atk=tc:GetAttack()
	-- 作为对象的场上的怪兽的攻击力直到回合结束时变成和作为对象的墓地的怪兽的攻击力相同。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	ac:RegisterEffect(e1)
end
-- 素材检查函数：检查该卡连接召唤时使用的素材中是否包含「转生炎兽 炽热多头狮」，是则将辅助效果e2的label设为1，否则设为0。
function c41463181.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,41463181) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
