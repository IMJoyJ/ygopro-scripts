--ヴィサス＝スタフロスト
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以与这张卡是种族和属性不同的自己场上1只怪兽为对象才能发动。那只怪兽破坏，这张卡特殊召唤。
-- ②：这张卡战斗破坏对方怪兽时才能发动。这张卡的攻击力上升那只怪兽的原本攻击力和原本守备力之内较高方数值的一半。
function c56099748.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以与这张卡是种族和属性不同的自己场上1只怪兽为对象才能发动。那只怪兽破坏，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56099748,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,56099748)
	e1:SetTarget(c56099748.sptg)
	e1:SetOperation(c56099748.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时才能发动。这张卡的攻击力上升那只怪兽的原本攻击力和原本守备力之内较高方数值的一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56099748,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置发动条件为自身战斗破坏对方怪兽时。
	e2:SetCondition(aux.bdocon)
	e2:SetOperation(c56099748.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选自己场上表侧表示、且与手牌中该卡的种族和属性都不同的怪兽，并确保其离场后有空余怪兽区域。
function c56099748.tfilter(c,sc,tp)
	-- 判定目标怪兽是否表侧表示，且其离场后能腾出至少一个怪兽区域。
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
		and not c:IsAttribute(sc:GetAttribute()) and not c:IsRace(sc:GetRace())
end
-- 效果1的发动准备与合法性检测，包括自身能否特殊召唤以及场上是否存在可选择的对象。
function c56099748.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c56099748.tfilter(chkc,c,tp) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判定自己场上是否存在至少1只满足过滤条件的、可作为效果对象的怪兽。
		and Duel.IsExistingTarget(c56099748.tfilter,tp,LOCATION_MZONE,0,1,nil,c,tp) end
	-- 给玩家发送提示信息，提示选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只满足过滤条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c56099748.tfilter,tp,LOCATION_MZONE,0,1,1,nil,c,tp)
	-- 设置效果处理信息：破坏选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息：将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果1的效果处理：破坏作为对象的怪兽，若破坏成功，则将自身特殊召唤。
function c56099748.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用此效果，则将其因效果破坏，并确认是否破坏成功。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			-- 将自身以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果2的效果处理：获取被战斗破坏怪兽的原本攻防较高值，并使自身攻击力上升该数值的一半。
function c56099748.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local upatk=bc:GetBaseAttack()
	if bc:GetBaseAttack()<bc:GetBaseDefense() then upatk=bc:GetBaseDefense() end
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升那只怪兽的原本攻击力和原本守备力之内较高方数值的一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(upatk/2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
