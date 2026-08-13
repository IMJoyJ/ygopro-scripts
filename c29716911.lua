--コンデンサー・デスストーカー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时，以这张卡以外的自己场上1只电子界族怪兽为对象才能发动。这只怪兽表侧表示存在期间，那只怪兽的攻击力上升800。
-- ②：怪兽区域的这张卡被效果破坏送去墓地的场合发动。双方玩家受到800伤害。
function c29716911.initial_effect(c)
	-- ①：这张卡召唤成功时，以这张卡以外的自己场上1只电子界族怪兽为对象才能发动。这只怪兽表侧表示存在期间，那只怪兽的攻击力上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29716911,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c29716911.atktg)
	e1:SetOperation(c29716911.atkop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：怪兽区域的这张卡被效果破坏送去墓地的场合发动。双方玩家受到800伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29716911,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,29716911)
	e2:SetCondition(c29716911.condition)
	e2:SetTarget(c29716911.target)
	e2:SetOperation(c29716911.operation)
	c:RegisterEffect(e2)
end
-- 筛选满足条件的卡：表侧表示且为电子界族怪兽，用于选择攻击力上升效果的适用对象。
function c29716911.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
-- ①效果的发动条件与对象选择：确认场上存在本卡以外的表侧电子界族怪兽可作为对象，并让玩家选择其中1只作为对象。
function c29716911.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c29716911.atkfilter(chkc) and chkc~=c end
	-- 发动时（非效果处理时）检查自己场上是否存在1只满足条件的电子界族怪兽（且不是本卡），作为效果可否发动的判定。
	if chk==0 then return Duel.IsExistingTarget(c29716911.atkfilter,tp,LOCATION_MZONE,0,1,c) end
	-- 给操作玩家显示选择表侧表示怪兽的提示信息（HINTMSG_FACEUP）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上表侧电子界族怪兽中选择1只（不能选本卡），并将其设为效果对象。
	Duel.SelectTarget(tp,c29716911.atkfilter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 处理①效果：若本卡和对象怪兽仍与效果关联且对象未免疫，则将对象设为本卡的永续对象，并给对象赋予攻击力上升800的效果；该效果随本卡或对象离场等标准状态重置。
function c29716911.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时的对象卡（①效果选择的电子界族怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 这只怪兽表侧表示存在期间，那只怪兽的攻击力上升800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetCondition(c29716911.rcon)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 攻击力上升效果的持续条件：检查本卡是否仍然以对象怪兽为永续对象（即本卡表侧存在且对象未离场/变里侧），满足时攻击力上升效果适用。
function c29716911.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
-- ②效果发动条件：这张卡从怪兽区域因效果被破坏送去墓地（r中同时含破坏与效果原因）。
function c29716911.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41 and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- ②效果的发动目标设定：发动时无条件允许，并设置操作信息为对双方玩家各造成800点伤害。
function c29716911.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的处理信息：效果分类为伤害，对双方玩家各造成800点伤害；由于不取对象且目标为双方玩家，targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,800)
end
-- 处理②效果：双方玩家各受到800点效果伤害，并作为分步处理以触发相关时点。
function c29716911.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给予当前效果发动者（自己）800点效果伤害，is_step=true以便插入时点。
	Duel.Damage(tp,800,REASON_EFFECT,true)
	-- 给予对方玩家800点效果伤害，is_step=true以便插入时点。
	Duel.Damage(1-tp,800,REASON_EFFECT,true)
	-- 完成伤害/恢复的逐步处理，触发因这次LP变动引发的时点。
	Duel.RDComplete()
end
