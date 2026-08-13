--月光蒼猫
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合，以「月光苍猫」以外的自己场上1只「月光」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成原本攻击力的2倍。
-- ②：场上的这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「月光」怪兽特殊召唤。
function c11439455.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡特殊召唤成功的场合，以「月光苍猫」以外的自己场上1只「月光」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成原本攻击力的2倍。
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
-- ①效果的对象筛选函数：对象必须是表侧表示、属于「月光」系列、且卡名不是「月光苍猫」自身的怪兽。
function c11439455.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xdf) and not c:IsCode(11439455)
end
-- ①效果的发动时点与取对象处理：先检查是否存在符合条件的「月光」怪兽可以作为对象；若存在，则提示玩家选择1只，并将该卡登记为效果对象，同时设置攻击力变化的操作信息。
function c11439455.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c11439455.atkfilter(chkc) end
	-- 发动合法性检查：确认自己场上有至少1只满足对象筛选条件的表侧表示「月光」怪兽可选。
	if chk==0 then return Duel.IsExistingTarget(c11439455.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择对象的提示信息，告诉玩家需要选择一张表侧表示的怪兽卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只满足条件的「月光」怪兽，并将其设置为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c11439455.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记操作信息：本连锁将对选中的对象执行攻击力变更处理，涉及1张卡。
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end
-- ①效果处理：取得对象怪兽，若其仍在场上表侧表示且与效果关联，则给它赋予一个直到结束阶段生效的“攻击力变为原本攻击力2倍”的效果，且该效果不会被无效。
function c11439455.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的第1只对象怪兽（即①选择的「月光」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时变成原本攻击力的2倍。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(tc:GetBaseAttack()*2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- ②效果的发动条件：这张卡是因为战斗或效果而被破坏，并且被破坏前位于场上，条件才成立。
function c11439455.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果特殊召唤的筛选条件：从卡组中选出属于「月光」系列、且能够被当前效果特殊召唤的怪兽。
function c11439455.spfilter(c,e,tp)
	return c:IsSetCard(0xdf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标检查：自己主要怪兽区有空位，且卡组中存在符合条件的「月光」怪兽可以特殊召唤。
function c11439455.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上是否还有空余的主要怪兽格，以保证特殊召唤可行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中是否存在至少1只满足「月光」系列且可以被特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c11439455.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本连锁将从卡组特殊召唤1只「月光」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若仍有空位，则从卡组选择1只符合条件的「月光」怪兽，以表侧表示特殊召唤到自己场上。
function c11439455.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查自己场上是否有空余的主要怪兽格，若没有则直接结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择要特殊召唤的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中筛选出所有符合条件的「月光」怪兽，让玩家从中选择1只用于特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c11439455.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将玩家选择的「月光」怪兽以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
