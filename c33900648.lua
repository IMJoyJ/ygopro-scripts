--クリアー・ワールド
-- 效果：
-- 这张卡的控制者在每次自己结束阶段支付500基本分或把这张卡破坏。
-- ①：双方让自身场上的怪兽属性的以下效果对自身适用。
-- ●光：手卡全部持续公开。
-- ●暗：自己场上的怪兽是2只以上的场合，不能攻击宣言。
-- ●地：自己准备阶段把自己1只表侧守备表示怪兽破坏。
-- ●水：自己结束阶段选1张手卡丢弃。
-- ●炎：自己结束阶段受到1000伤害。
-- ●风：若不支付500基本分则不能把魔法卡发动。
function c33900648.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡的控制者在每次自己结束阶段支付500基本分或把这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33900648,4))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c33900648.mtcon)
	e2:SetOperation(c33900648.mtop)
	c:RegisterEffect(e2)
	-- 效果原文：●光：手卡全部持续公开。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_PUBLIC)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_HAND,0)
	e4:SetCondition(c33900648.lightcon1)
	c:RegisterEffect(e4)
	local e4_=e4:Clone()
	e4_:SetTargetRange(0,LOCATION_HAND)
	e4_:SetCondition(c33900648.lightcon2)
	c:RegisterEffect(e4_)
	-- 效果原文：●暗：自己场上的怪兽是2只以上的场合，不能攻击宣言。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,0)
	e5:SetCondition(c33900648.darkcon1)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCondition(c33900648.darkcon2)
	e6:SetTargetRange(0,1)
	c:RegisterEffect(e6)
	-- 效果原文：●地：自己准备阶段把自己1只表侧守备表示怪兽破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(33900648,1))  --"破坏"
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetRange(LOCATION_FZONE)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetCountLimit(1)
	e7:SetCondition(c33900648.descon)
	e7:SetTarget(c33900648.destg)
	e7:SetOperation(c33900648.desop)
	c:RegisterEffect(e7)
	-- 效果原文：●水：自己结束阶段选1张手卡丢弃。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(33900648,2))  --"丢弃手牌"
	e8:SetCategory(CATEGORY_HANDES)
	e8:SetCode(EVENT_PHASE+PHASE_END)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCountLimit(1)
	e8:SetCondition(c33900648.hdcon)
	e8:SetTarget(c33900648.hdtg)
	e8:SetOperation(c33900648.hdop)
	c:RegisterEffect(e8)
	-- 效果原文：●炎：自己结束阶段受到1000伤害。
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(33900648,3))  --"1000伤害"
	e9:SetCategory(CATEGORY_DAMAGE)
	e9:SetCode(EVENT_PHASE+PHASE_END)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e9:SetRange(LOCATION_FZONE)
	e9:SetCountLimit(1)
	e9:SetCondition(c33900648.damcon)
	e9:SetTarget(c33900648.damtg)
	e9:SetOperation(c33900648.damop)
	c:RegisterEffect(e9)
	-- 效果原文：●风：若不支付500基本分则不能把魔法卡发动。
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD)
	e10:SetCode(EFFECT_ACTIVATE_COST)
	e10:SetRange(LOCATION_FZONE)
	e10:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e10:SetTargetRange(1,0)
	e10:SetTarget(c33900648.actarget)
	e10:SetCondition(c33900648.windcon1)
	e10:SetCost(c33900648.costchk)
	e10:SetOperation(c33900648.costop)
	c:RegisterEffect(e10)
	local e11=e10:Clone()
	e11:SetTargetRange(0,1)
	e11:SetCondition(c33900648.windcon2)
	c:RegisterEffect(e11)
end
-- 规则层面：判断是否为当前回合玩家
function c33900648.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 规则层面：处理结束阶段的支付或破坏选择
function c33900648.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：检查是否能支付500基本分并询问玩家是否支付
	if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(33900648,0)) then  --"是否要支付500基本分维持「清透世界」？"
		-- 规则层面：支付500基本分
		Duel.PayLPCost(tp,500)
	else
		-- 规则层面：破坏自身
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 规则层面：获取玩家场上怪兽属性的函数
function c33900648.attributechk(tp)
	local attchk=0
	-- 规则层面：判断玩家是否被效果97811903影响
	if Duel.IsPlayerAffectedByEffect(tp,97811903) then
		attchk=0
	-- 规则层面：判断玩家是否被效果6089145影响
	elseif Duel.IsPlayerAffectedByEffect(tp,6089145) then
		attchk=ATTRIBUTE_LIGHT|ATTRIBUTE_DARK|ATTRIBUTE_EARTH|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_WIND
	else
		-- 规则层面：获取玩家场上表侧表示怪兽的集合
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local tc=g:GetFirst()
		while tc do
			attchk=attchk|tc:GetAttribute()
			tc=g:GetNext()
		end
	end
	return attchk
end
-- 规则层面：判断光属性是否生效
function c33900648.lightcon1(e)
	local tp=e:GetHandlerPlayer()
	return c33900648.attributechk(tp)&ATTRIBUTE_LIGHT~=0
end
-- 规则层面：判断对方光属性是否生效
function c33900648.lightcon2(e)
	local tp=e:GetHandlerPlayer()
	return c33900648.attributechk(1-tp)&ATTRIBUTE_LIGHT~=0
end
-- 规则层面：判断暗属性是否生效且己方场上怪兽数量≥2
function c33900648.darkcon1(e)
	local tp=e:GetHandlerPlayer()
	return c33900648.attributechk(tp)&ATTRIBUTE_DARK~=0
		-- 规则层面：判断己方场上怪兽数量≥2
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>=2
end
-- 规则层面：判断对方暗属性是否生效且己方场上怪兽数量≥2
function c33900648.darkcon2(e)
	local tp=e:GetHandlerPlayer()
	return c33900648.attributechk(1-tp)&ATTRIBUTE_DARK~=0
		-- 规则层面：判断己方场上怪兽数量≥2
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=2
end
-- 规则层面：判断地属性是否生效
function c33900648.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断地属性是否生效
	return c33900648.attributechk(Duel.GetTurnPlayer())&ATTRIBUTE_EARTH~=0
end
-- 规则层面：破坏目标怪兽的过滤函数
function c33900648.desfilter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE)
end
-- 规则层面：设置破坏效果的目标选择
function c33900648.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：获取当前回合玩家
	local turnp=Duel.GetTurnPlayer()
	-- 规则层面：检查是否存在满足条件的破坏目标
	if chk==0 then return Duel.IsExistingMatchingCard(c33900648.desfilter,turnp,LOCATION_MZONE,0,1,nil) end
	-- 规则层面：提示对方选择了破坏效果
	Duel.Hint(HINT_OPSELECTED,1-turnp,aux.Stringid(33900648,1))  --"破坏"
end
-- 规则层面：执行破坏操作
function c33900648.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前回合玩家
	local turnp=Duel.GetTurnPlayer()
	-- 规则层面：提示选择破坏目标
	Duel.Hint(HINT_SELECTMSG,turnp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面：选择破坏目标
	local tg=Duel.SelectMatchingCard(turnp,c33900648.desfilter,turnp,LOCATION_MZONE,0,1,1,nil)
	-- 规则层面：提示选择破坏目标
	Duel.HintSelection(tg)
	-- 规则层面：破坏目标怪兽
	Duel.Destroy(tg,REASON_EFFECT)
end
-- 规则层面：判断水属性是否生效
function c33900648.hdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断水属性是否生效
	return c33900648.attributechk(Duel.GetTurnPlayer())&ATTRIBUTE_WATER~=0
end
-- 规则层面：设置丢弃手牌效果的目标选择
function c33900648.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：获取当前回合玩家
	local turnp=Duel.GetTurnPlayer()
	-- 规则层面：检查是否存在手牌
	if chk==0 then return Duel.GetFieldGroupCount(turnp,LOCATION_HAND,0)>0 end
	-- 规则层面：提示对方选择了丢弃手牌效果
	Duel.Hint(HINT_OPSELECTED,1-turnp,aux.Stringid(33900648,2))  --"丢弃手牌"
end
-- 规则层面：执行丢弃手牌操作
function c33900648.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前回合玩家
	local turnp=Duel.GetTurnPlayer()
	-- 规则层面：丢弃1张手牌
	Duel.DiscardHand(turnp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
end
-- 规则层面：判断炎属性是否生效
function c33900648.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断炎属性是否生效
	return c33900648.attributechk(Duel.GetTurnPlayer())&ATTRIBUTE_FIRE~=0
end
-- 规则层面：设置造成伤害效果的目标选择
function c33900648.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：获取当前回合玩家
	local turnp=Duel.GetTurnPlayer()
	-- 规则层面：提示对方选择了1000伤害效果
	Duel.Hint(HINT_OPSELECTED,1-turnp,aux.Stringid(33900648,3))  --"1000伤害"
end
-- 规则层面：执行造成伤害操作
function c33900648.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前回合玩家
	local turnp=Duel.GetTurnPlayer()
	-- 规则层面：对玩家造成1000伤害
	Duel.Damage(turnp,1000,REASON_EFFECT)
end
-- 规则层面：判断风属性是否生效
function c33900648.windcon1(e)
	local tp=e:GetHandlerPlayer()
	return bit.band(c33900648.attributechk(tp),ATTRIBUTE_WIND)~=0
end
-- 规则层面：判断对方风属性是否生效
function c33900648.windcon2(e)
	local tp=e:GetHandlerPlayer()
	return bit.band(c33900648.attributechk(1-tp),ATTRIBUTE_WIND)~=0
end
-- 规则层面：判断是否为魔法卡发动的过滤函数
function c33900648.actarget(e,te,tp)
	return te:IsHasType(EFFECT_TYPE_ACTIVATE) and te:IsActiveType(TYPE_SPELL)
end
-- 规则层面：判断是否能支付500基本分作为发动魔法卡的代价
function c33900648.costchk(e,te_or_c,tp)
	-- 规则层面：判断是否能支付500基本分
	return Duel.CheckLPCost(tp,500)
end
-- 规则层面：支付500基本分作为发动魔法卡的代价
function c33900648.costop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：支付500基本分
	Duel.PayLPCost(tp,500)
end
