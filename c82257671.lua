--ガッチリ＠イグニスター
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：以自己场上1只电子界族效果怪兽为对象才能发动。那只怪兽的效果无效，这张卡从手卡特殊召唤。
-- ②：自己场上的电子界族怪兽在1回合各有1次不会被效果破坏。
-- ③：这张卡从场上送去墓地的场合，以自己场上1只表侧表示怪兽为对象才能发动。那只自己的表侧表示怪兽直到对方回合结束时不受对方的效果影响。
function c82257671.initial_effect(c)
	-- ①：以自己场上1只电子界族效果怪兽为对象才能发动。那只怪兽的效果无效，这张卡从手卡特殊召唤。（这个卡名的①③的效果1回合各能使用1次。）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82257671,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,82257671)
	e1:SetTarget(c82257671.sptg)
	e1:SetOperation(c82257671.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的电子界族怪兽在1回合各有1次不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c82257671.indtg)
	e2:SetValue(c82257671.indct)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合，以自己场上1只表侧表示怪兽为对象才能发动。那只自己的表侧表示怪兽直到对方回合结束时不受对方的效果影响。（这个卡名的①③的效果1回合各能使用1次。）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(82257671,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,82257672)
	e3:SetCondition(c82257671.imcon)
	e3:SetTarget(c82257671.imtg)
	e3:SetOperation(c82257671.imop)
	c:RegisterEffect(e3)
end
-- 定义用于筛选自己场上未被无效的电子界族效果怪兽的过滤函数
function c82257671.cfilter(c)
	-- 判断卡片是否为电子界族，且处于表侧表示、未被无效化且是效果怪兽
	return c:IsRace(RACE_CYBERSE) and aux.NegateEffectMonsterFilter(c)
end
-- 效果①的发动准备与目标选择阶段
function c82257671.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c82257671.cfilter(chkc) end
	-- 在发动效果的准备阶段，检查自己场上是否有空余的怪兽区域，以及手牌中的这张卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且检查自己场上是否存在可以作为效果无效对象的电子界族效果怪兽
		and Duel.IsExistingTarget(c82257671.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要无效的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择自己场上1只符合条件的电子界族效果怪兽作为效果的对象
	Duel.SelectTarget(tp,c82257671.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁信息，表明该效果包含将这张卡特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理阶段：使作为对象的怪兽效果无效，并将这张卡特殊召唤
function c82257671.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动阶段选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与该怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if c:IsRelateToEffect(e) then
			-- 将手牌中的这张卡以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果②的过滤函数，确定不受效果破坏影响的对象为自己场上表侧表示的电子界族怪兽
function c82257671.indtg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
-- 效果②的破坏次数判定，若因效果破坏则提供1次免于破坏的保护
function c82257671.indct(e,re,r,rp)
	if bit.band(r,REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
-- 效果③的发动条件：这张卡必须是从场上送去墓地
function c82257671.imcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果③的发动准备与目标选择阶段
function c82257671.imtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 在发动效果的准备阶段，检查自己场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只表侧表示的怪兽作为效果的对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果③的效果处理阶段：使作为对象的怪兽获得不受对方效果影响的抗性
function c82257671.imop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToEffect(e) then
		-- 那只自己的表侧表示怪兽直到对方回合结束时不受对方的效果影响。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c82257671.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1)
	end
end
-- 定义抗性过滤函数，判断效果是否来源于对方玩家（即不受对方的效果影响）
function c82257671.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
