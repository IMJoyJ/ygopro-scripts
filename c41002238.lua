--カイザー・グライダー－ゴールデン・バースト
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把自己场上1只怪兽解放才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
-- ②：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。这张卡的攻击力直到回合结束时变成和那只怪兽的攻击力相同。
function c41002238.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：把自己场上1只怪兽解放才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41002238,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,41002238)
	e1:SetCost(c41002238.spcost)
	e1:SetTarget(c41002238.sptg)
	e1:SetOperation(c41002238.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。这张卡的攻击力直到回合结束时变成和那只怪兽的攻击力相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41002238,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c41002238.atktg)
	e2:SetOperation(c41002238.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 作为①效果的发动代价，获取自己场上可解放的怪兽组，检查是否存在1只满足解放后仍有怪兽区空位的怪兽；若存在则提示玩家选择，消耗代替解放次数后将其解放作为COST。
function c41002238.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家tp可解放的怪兽组（默认不含手卡），用于选择解放代价。
	local g=Duel.GetReleaseGroup(tp)
	-- 在代价检查阶段（chk==0）判断可解放组中是否存在1张怪兽，使解放后主怪兽区仍有空位且可被正常解放，以决定能否发动。
	if chk==0 then return g:CheckSubGroup(aux.mzctcheckrel,1,1,tp) end
	-- 向玩家tp显示选择提示，要求其选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家tp从可解放组中选出1张满足解放后空位条件的怪兽，作为本次解放代价。
	local rg=g:SelectSubGroup(tp,aux.mzctcheckrel,false,1,1,tp)
	-- 如果使用了类似暗影敌托邦等代替解放的效果，这里强制消耗其解放次数，确保解放能够正常执行。
	aux.UseExtraReleaseCount(rg,tp)
	-- 将选中的怪兽正式解放，解放原因为COST（代价），完成发动代价的支付。
	Duel.Release(rg,REASON_COST)
end
-- ①效果的发动条件检查：确认这张卡能够被特殊召唤（满足召唤条件和苏生限制）；若可行则登记操作信息为特殊召唤这张卡。
function c41002238.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将当前连锁的操作信息登记为“特殊召唤”分类，预定处理时将这张卡特殊召唤1张，以便其他卡进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理时：若这张卡仍与效果关联，则将其从手卡以表侧表示特殊召唤到自己场上。
function c41002238.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上，同时正常检查召唤条件和苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果的对象筛选条件：对象必须是表侧表示怪兽，且其攻击力不等于这张卡当前的攻击力。
function c41002238.filter(c,atk)
	return c:IsFaceup() and not c:IsAttack(atk)
end
-- ②效果的发动判定与取对象：确认这张卡仍与效果关联，且对方场上有满足条件的表侧表示怪兽可选；若为连锁处理中指定对象，则校验对象满足位置、控制者和筛选条件。
function c41002238.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c41002238.filter(chkc,c:GetAttack()) end
	if chk==0 then return c:IsRelateToEffect(e)
		-- 在对方场上检查是否存在至少1只满足filter条件的表侧表示怪兽，可作为本效果的对象。
		and Duel.IsExistingTarget(c41002238.filter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()) end
	-- 向玩家tp显示选择提示，要求其选择②效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家tp从对方场上选择1只满足filter条件的表侧表示怪兽，并将其设置为当前连锁的处理对象。
	Duel.SelectTarget(tp,c41002238.filter,tp,0,LOCATION_MZONE,1,1,nil,c:GetAttack())
end
-- ②效果处理时：若发动时的这张卡和对象怪兽都仍在场上且与效果关联有效，则创建一个持续到回合结束的攻击力变更效果，将这张卡的攻击力变为对象怪兽当前的攻击力。
function c41002238.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中记录的②效果所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这张卡的攻击力直到回合结束时变成和那只怪兽的攻击力相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
