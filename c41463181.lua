--転生炎獣ヒートライオ
-- 效果：
-- 炎属性效果怪兽2只以上
-- ①：这张卡连接召唤的场合，以对方的魔法与陷阱区域1张卡为对象才能发动。那张卡回到卡组。
-- ②：这张卡是已用「转生炎兽 炽热多头狮」为素材作连接召唤的场合，1回合1次，以场上1只表侧表示怪兽和自己墓地1只怪兽为对象才能发动。作为对象的场上的怪兽的攻击力直到回合结束时变成和作为对象的墓地的怪兽的攻击力相同。
function c41463181.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用至少2个满足过滤条件的怪兽作为连接素材
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
	-- ②：这张卡是已用「转生炎兽 炽热多头狮」为素材作连接召唤的场合，1回合1次，以场上1只表侧表示怪兽和自己墓地1只怪兽为对象才能发动。作为对象的场上的怪兽的攻击力直到回合结束时变成和作为对象的墓地的怪兽的攻击力相同。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(c41463181.condition)
	e2:SetOperation(c41463181.operation)
	c:RegisterEffect(e2)
	-- 检查连接召唤时是否使用了「转生炎兽 炽热多头狮」作为素材
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c41463181.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 连接素材必须是效果怪兽且属性为炎
function c41463181.matfilter(c)
	return c:IsLinkType(TYPE_EFFECT) and c:IsLinkAttribute(ATTRIBUTE_FIRE)
end
-- 效果发动时，确认此卡是否为连接召唤
function c41463181.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 筛选可返回卡组的魔法与陷阱区域的卡
function c41463181.tdfilter(c)
	return c:GetSequence()<5 and c:IsAbleToDeck()
end
-- 选择目标卡并设置操作信息
function c41463181.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c41463181.tdfilter(chkc) end
	-- 判断是否有满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c41463181.tdfilter,tp,0,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,c41463181.tdfilter,tp,0,LOCATION_SZONE,1,1,nil)
	-- 设置操作信息，指定将卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 执行将目标卡送回卡组的操作
function c41463181.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送回卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 确认此卡是否为连接召唤且使用了「转生炎兽 炽热多头狮」作为素材
function c41463181.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- 创建并注册1回合1次的起动效果，用于改变场上怪兽攻击力
function c41463181.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：这张卡是已用「转生炎兽 炽热多头狮」为素材作连接召唤的场合，1回合1次，以场上1只表侧表示怪兽和自己墓地1只怪兽为对象才能发动。作为对象的场上的怪兽的攻击力直到回合结束时变成和作为对象的墓地的怪兽的攻击力相同。
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
-- 筛选场上表侧表示且墓地有可作为对象的怪兽
function c41463181.atkfilter1(c,tp)
	-- 判断场上怪兽是否表侧表示且墓地有满足条件的怪兽
	return c:IsFaceup() and Duel.IsExistingTarget(c41463181.atkfilter2,tp,LOCATION_GRAVE,0,1,nil,c)
end
-- 筛选墓地中的怪兽，其攻击力与目标怪兽不同且攻击力有效
function c41463181.atkfilter2(c,tc)
	return c:IsType(TYPE_MONSTER) and c:GetAttack()~=tc:GetAttack() and c:GetTextAttack()>=0
end
-- 选择目标怪兽和墓地怪兽并设置操作信息
function c41463181.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否有满足条件的场上怪兽
	if chk==0 then return Duel.IsExistingTarget(c41463181.atkfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上表侧表示的怪兽
	local g=Duel.SelectTarget(tp,c41463181.atkfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择墓地中的怪兽作为对象
	Duel.SelectTarget(tp,c41463181.atkfilter2,tp,LOCATION_GRAVE,0,1,1,nil,g:GetFirst())
end
-- 执行攻击力变更效果
function c41463181.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取连锁中的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sc=g:GetFirst()
	if sc==tc then sc=g:GetNext() end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or not sc:IsRelateToEffect(e) then return end
	local ac=e:GetLabelObject()
	if tc==ac then tc=sc end
	local atk=tc:GetAttack()
	-- 设置攻击力变更效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	ac:RegisterEffect(e1)
end
-- 检查连接召唤时是否使用了「转生炎兽 炽热多头狮」作为素材
function c41463181.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,41463181) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
