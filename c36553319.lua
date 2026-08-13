--彼岸の悪鬼 ファーファレル
-- 效果：
-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
-- ③：这张卡被送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽直到结束阶段除外。
function c36553319.initial_effect(c)
	-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c36553319.sdcon)
	c:RegisterEffect(e1)
	-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36553319,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,36553319)
	e2:SetCondition(c36553319.sscon)
	e2:SetTarget(c36553319.sstg)
	e2:SetOperation(c36553319.ssop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽直到结束阶段除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36553319,1))  --"除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,36553319)
	e3:SetTarget(c36553319.rmtg)
	e3:SetOperation(c36553319.rmop)
	c:RegisterEffect(e3)
end
-- 过滤条件：判断怪兽是否为里侧表示或不属于「彼岸」系列，用于识别“彼岸怪兽以外的怪兽”（里侧怪兽无法确认也视为非彼岸）。
function c36553319.sdfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xb1)
end
-- 自爆效果的发动条件：检查自己怪兽区是否存在里侧表示或非「彼岸」系列的怪兽，若存在则满足②的破坏条件。
function c36553319.sdcon(e)
	-- 检测自己场上是否有里侧表示或非「彼岸」系列的怪兽，存在则条件成立。
	return Duel.IsExistingMatchingCard(c36553319.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：判断卡片是否为魔法·陷阱卡，用于检查场上是否存在魔法·陷阱卡。
function c36553319.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ①的发动条件：自己场上没有魔法·陷阱卡存在时才能从手卡特殊召唤，因此检查场上不存在魔法·陷阱卡。
function c36553319.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上不存在任何魔法·陷阱卡，则返回 true，满足①的发动条件。
	return not Duel.IsExistingMatchingCard(c36553319.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①的发动时合法性检查：确认自己主要怪兽区有空位，且此卡能够被特殊召唤。
function c36553319.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次操作信息登记为特殊召唤，以便后续时点或相关效果进行检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的效果处理：若此卡仍与效果关联，则将其从手卡特殊召唤到自己场上。
function c36553319.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 以表侧表示将此卡特殊召唤到自己的主要怪兽区（不检查召唤条件与苏生限制）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ③的发动目标处理：从双方场上选择1只可以除外的怪兽作为对象，并设置除外操作信息。
function c36553319.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 发动时确认场上是否存在至少1只可以被除外的怪兽，作为取对象的前提条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从双方场上选择1只可以除外的怪兽，并将其设为效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 将操作信息登记为除外所选择的对象（1张卡）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ③的效果处理：将对象怪兽暂时除外，并在结束阶段将其返回场上，同时注册返回用效果。
function c36553319.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象仍与效果关联，则将其以效果原因暂时除外；成功后才继续设置结束阶段返回处理。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(36553319,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 那只怪兽直到结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c36553319.retcon)
		e1:SetOperation(c36553319.retop)
		-- 将结束阶段返回效果注册到场上（由tp方控制），使被暂时除外的对象在结束阶段时返回。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 返回条件：检查被暂时除外的对象是否仍带有标记，确认其未被其他效果移动或重置，若仍存在则执行返回。
function c36553319.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(36553319)~=0
end
-- 结束阶段处理：将被暂时除外的对象怪兽返回场上。
function c36553319.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对象怪兽以离场前的表示形式返回场上。
	Duel.ReturnToField(e:GetLabelObject())
end
