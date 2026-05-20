--黒牙の魔術師
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成一半。那之后，这张卡破坏。
-- 【怪兽效果】
-- 这张卡在规则上也当作「超量龙」卡使用。
-- ①：这张卡被战斗·效果破坏的场合，以自己墓地1只魔法师族·暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
function c75672051.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动等）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成一半。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75672051,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c75672051.atktg)
	e1:SetOperation(c75672051.atkop)
	c:RegisterEffect(e1)
	-- ①：这张卡被战斗·效果破坏的场合，以自己墓地1只魔法师族·暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75672051,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c75672051.spcon)
	e3:SetTarget(c75672051.sptg)
	e3:SetOperation(c75672051.spop)
	c:RegisterEffect(e3)
end
-- 灵摆效果的发动准备与目标选择
function c75672051.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 判定对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表明此效果包含破坏自身的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果的执行处理（攻击力减半，之后破坏自身）
function c75672051.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的效果对象（即对方场上的那只表侧表示怪兽）
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 中断效果处理，使后续的破坏处理与前面的攻击力减半不视为同时发生
		Duel.BreakEffect()
		-- 破坏这张卡
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 判定此卡是否因战斗或效果被破坏
function c75672051.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤自己墓地中可以特殊召唤的暗属性、魔法师族怪兽
function c75672051.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果的发动准备与目标选择
function c75672051.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c75672051.spfilter(chkc,e,tp) end
	-- 判定自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且判定自己墓地是否存在符合条件的魔法师族·暗属性怪兽
		and Duel.IsExistingTarget(c75672051.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为特殊召唤的对象
	local g=Duel.SelectTarget(tp,c75672051.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明此效果包含特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 怪兽效果的执行处理（特殊召唤选中的怪兽）
function c75672051.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的效果对象（即自己墓地的那只魔法师族·暗属性怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
