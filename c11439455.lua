--月光蒼猫
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合，以「月光苍猫」以外的自己场上1只「月光」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成原本攻击力的2倍。
-- ②：场上的这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「月光」怪兽特殊召唤。
function c11439455.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合，以「月光苍猫」以外的自己场上1只「月光」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成原本攻击力的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11439455,0))  --"攻击力变成2倍"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,11439455)
	e1:SetTarget(c11439455.atktg)
	e1:SetOperation(c11439455.atkop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「月光」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11439455,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c11439455.spcon)
	e3:SetTarget(c11439455.sptg)
	e3:SetOperation(c11439455.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示的「月光」怪兽且不是月光苍猫本身。
function c11439455.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xdf) and not c:IsCode(11439455)
end
-- 设置效果目标选择函数，用于选择符合条件的「月光」怪兽作为攻击力变化的对象。
function c11439455.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c11439455.atkfilter(chkc) end
	-- 检查是否满足发动条件，即场上是否存在符合条件的「月光」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c11439455.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择符合条件的「月光」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c11439455.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表明将要改变目标怪兽的攻击力。
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end
-- 设置效果处理函数，用于执行攻击力翻倍的效果。
function c11439455.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个永久改变攻击力的效果，使其变为原本攻击力的2倍，并在回合结束时重置。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(tc:GetBaseAttack()*2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 设置效果发动条件，判断该卡是否因战斗或效果被破坏并离开场上的状态。
function c11439455.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于判断卡组中是否存在可以特殊召唤的「月光」怪兽。
function c11439455.spfilter(c,e,tp)
	return c:IsSetCard(0xdf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标选择函数，用于选择从卡组特殊召唤的「月光」怪兽。
function c11439455.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即场上是否有足够的召唤位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「月光」怪兽。
		and Duel.IsExistingMatchingCard(c11439455.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，表明将要从卡组特殊召唤一只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 设置效果处理函数，用于执行从卡组特殊召唤怪兽的操作。
function c11439455.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置，若无则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从卡组中选择一只满足条件的「月光」怪兽。
	local g=Duel.SelectMatchingCard(tp,c11439455.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
