--天昇星テンマ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：在只有对方场上才有怪兽存在的场合或者在自己场上有地属性怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把1只战士族·地属性·5星怪兽特殊召唤。
-- ③：1回合1次，自己场上的战士族怪兽为对象的对方的效果发动时才能发动。这张卡的攻击力下降500，那个发动无效并破坏。
function c33837653.initial_effect(c)
	-- ①：在只有对方场上才有怪兽存在的场合或者在自己场上有地属性怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33837653,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c33837653.ntcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把1只战士族·地属性·5星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33837653,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,33837653)
	e2:SetTarget(c33837653.sptg)
	e2:SetOperation(c33837653.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己场上的战士族怪兽为对象的对方的效果发动时才能发动。这张卡的攻击力下降500，那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(33837653,2))
	e4:SetCategory(CATEGORY_NEGATE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c33837653.discon)
	e4:SetTarget(c33837653.distg)
	e4:SetOperation(c33837653.disop)
	c:RegisterEffect(e4)
end
-- 该过滤器用于检测表侧表示的地属性怪兽，用于判断是否满足“自己场上有地属性怪兽存在”的条件。
function c33837653.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 无解放召唤的规则效果条件：仅当自己场上没有怪兽而对方场上有怪兽，或自己场上有表侧地属性怪兽时，且该怪兽等级在5以上、自己场上有可用怪兽区，才可不解放召唤。
function c33837653.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 召唤的怪兽必须是5星以上，并且自己场上有空余的怪兽区域（minc==0表示无需解放）。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 条件之一：对方场上有怪兽存在且自己场上没有怪兽（即只有对方场上才有怪兽存在的场合）。
		and ((Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0)
		-- 条件之二：自己场上有表侧表示的地属性怪兽存在，也满足无解放召唤条件。
		or Duel.IsExistingMatchingCard(c33837653.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
-- 用于筛选手卡中满足条件的特殊召唤对象：战士族、地属性、5星怪兽，且可以被玩家tp特殊召唤。
function c33837653.filter1(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsLevel(5) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时机的目标判定：检查自己场上有空位、手卡存在符合条件的战士族·地属性·5星怪兽；满足则准备从手卡特殊召唤1只。
function c33837653.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定手卡中是否存在至少1只满足filter1的战士族·地属性·5星怪兽。
		and Duel.IsExistingMatchingCard(c33837653.filter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡特殊召唤1只怪兽（目标区域为手卡）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果处理：若场上仍有空位，选择1只符合条件的怪兽从手卡特殊召唤。
function c33837653.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用怪兽区，则不进行特殊召唤，效果处理结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示消息，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1张满足filter1的怪兽。
	local g=Duel.SelectMatchingCard(tp,c33837653.filter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 该过滤器用于判定自己场上表侧表示的战士族怪兽，作为③效果中的“自己场上的战士族怪兽”的判定条件。
function c33837653.filter2(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_WARRIOR)
end
-- ③效果的发动条件：本卡未被战斗破坏、对方发动的效果为取对象效果、该效果对象中包含自己场上的表侧战士族怪兽，且该连锁可以被无效。
function c33837653.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得当前连锁中对方发动的效果所选取的对象卡组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 对方效果（rp==1-tp）、对象中存在自己的表侧战士族怪兽，且该发动可被无效时，③效果才满足发动条件。
	return rp==1-tp and g and g:IsExists(c33837653.filter2,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- ③效果发动目标判定：本卡攻击力必须在500以上；设置无效该发动的操作信息，如果对方效果来源卡可破坏则同时设置破坏操作信息。
function c33837653.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackAbove(500) end
	-- 设置操作信息：本次连锁将包含“使效果发动无效”的分类，用于后续检测。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若对方效果来源卡可被破坏且与效果仍有关联，则追加设置“破坏”的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ③效果处理：本卡仍存在于场上且表侧表示、攻击力在500以上时，下降500攻击力；然后无效对方效果的发动，并破坏对方效果来源卡。
function c33837653.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsAttackAbove(500) then
		-- 这张卡的攻击力下降500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 若无效对方发动成功，且对方效果来源卡仍与该效果关联，则继续执行破坏处理。
			if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
				-- 破坏对方发动效果的那张卡（连锁来源卡）。
				Duel.Destroy(eg,REASON_EFFECT)
			end
		end
	end
end
