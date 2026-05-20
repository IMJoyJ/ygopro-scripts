--トリックスターバンド・ドラマチス
-- 效果：
-- 「淘气仙星」怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。同名卡不在自己的场上·墓地存在的1张「淘气仙星」卡从卡组加入手卡。
-- ②：有这张卡位于所连接区的自己的「淘气仙星」连接怪兽的攻击力上升1000。
-- ③：自己或对方受到效果伤害的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤手续、①效果（融合召唤成功时检索）、②效果（所连接区怪兽攻击力上升）、③效果（受到效果伤害时使怪兽攻击力变0）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，素材为2只「淘气仙星」怪兽
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xfb),2,true)
	-- ①：这张卡融合召唤的场合才能发动。同名卡不在自己的场上·墓地存在的1张「淘气仙星」卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索「淘气仙星」卡"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：有这张卡位于所连接区的自己的「淘气仙星」连接怪兽的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.latktg)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- ③：自己或对方受到效果伤害的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"改变攻击力"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
-- 判定此卡是否为融合召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤函数：用于检查场上表侧表示或墓地中是否存在同名卡
function s.cfilter(c,code)
	return c:IsCode(code) and (c:IsFaceup() or not c:IsOnField())
end
-- 过滤函数：筛选卡组中可以加入手牌且同名卡不在自己场上或墓地存在的「淘气仙星」卡
function s.thfilter(c,tp)
	return c:IsAbleToHand() and c:IsSetCard(0xfb)
		-- 判定同名卡是否不存在于自己的场上（表侧表示）和墓地
		and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- ①效果的发动准备，检查卡组中是否存在符合条件的卡并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组中是否存在符合条件的「淘气仙星」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的效果处理，从卡组将1张符合条件的「淘气仙星」卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的「淘气仙星」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：筛选位于这张卡所连接区的自己的「淘气仙星」连接怪兽
function s.latktg(e,c)
	return c:IsSetCard(0xfb) and c:IsType(TYPE_LINK) and c:GetLinkedGroup():IsContains(e:GetHandler())
end
-- 判定受到的伤害是否为效果伤害
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 过滤函数：筛选场上表侧表示且攻击力不为0的怪兽
function s.atkfilter(c)
	return c:IsFaceup() and not c:IsAttack(0)
end
-- ③效果的发动准备，选择场上1只表侧表示怪兽作为效果对象
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
	-- 判定场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ③效果的效果处理，使作为对象的怪兽攻击力变成0
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) and not tc:IsAttack(0) then
		-- 那只怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
