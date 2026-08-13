--極氷獣ブリザード・ウルフ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己或者对方的怪兽的攻击宣言时才能发动。那次攻击无效，从手卡把「极冰兽 雪暴狼」以外的1只4星以下的水属性怪兽特殊召唤。
-- ②：这张卡在墓地存在，自己场上没有怪兽存在的场合，对方战斗阶段开始时才能发动。这张卡攻击表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c43175027.initial_effect(c)
	-- “这个卡名的①②的效果1回合各能使用1次。①：自己或者对方的怪兽的攻击宣言时才能发动。那次攻击无效，从手卡把「极冰兽 雪暴狼」以外的1只4星以下的水属性怪兽特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43175027,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,43175027)
	e1:SetTarget(c43175027.atktg)
	e1:SetOperation(c43175027.atkop)
	c:RegisterEffect(e1)
	-- “这个卡名的①②的效果1回合各能使用1次。②：这张卡在墓地存在，自己场上没有怪兽存在的场合，对方战斗阶段开始时才能发动。这张卡攻击表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43175027,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,43175028)
	e2:SetCondition(c43175027.spcon)
	e2:SetTarget(c43175027.sptg)
	e2:SetOperation(c43175027.spop)
	c:RegisterEffect(e2)
end
-- 定义效果①特殊召唤的筛选条件：从手牌选择「极冰兽 雪暴狼」以外、水属性、等级4以下、且能被当前效果特殊召唤的怪兽。
function c43175027.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelBelow(4) and not c:IsCode(43175027)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：自己主要怪兽区有空位，且手牌中存在满足spfilter条件的怪兽。
function c43175027.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足spfilter条件的「极冰兽 雪暴狼」以外的4星以下水属性怪兽。
		and Duel.IsExistingMatchingCard(c43175027.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息，预告将从手牌特殊召唤1只怪兽（处理时选择对象），供连锁检测及效果联动使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：先无效攻击，若成功且怪兽区有空位，则由玩家从手牌选择1只满足条件的水属性怪兽表侧表示特殊召唤。
function c43175027.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效此次攻击，若无效成功则进入后续特殊召唤处理。
	if Duel.NegateAttack() then
		-- 若自己主要怪兽区没有空位，则无法进行特殊召唤，直接结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌中选择1只满足spfilter条件的水属性怪兽，并取第一张作为特殊召唤对象。
		local tc=Duel.SelectMatchingCard(tp,c43175027.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
		if tc then
			-- 将选择的怪兽表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②效果的发动条件判定：对方回合的战斗阶段开始时，且自己场上没有怪兽存在。
function c43175027.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前不是自己的回合（即对方回合），且自己场上没有怪兽。
	return tp~=Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- ②效果的发动条件判定：自己主要怪兽区有空位，且墓地的这张卡能够以表侧攻击表示特殊召唤。
function c43175027.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否有空位，用于特殊召唤墓地中的这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置操作信息，预告将特殊召唤墓地中的这张卡，特殊召唤对象为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联，则将其攻击表示特殊召唤，并给这张卡附加离场时除外的不受无效化影响的效果。
function c43175027.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍然与发动时的效果有联系，且攻击表示特殊召唤成功，才继续附加除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)>0 then
		-- “这个效果特殊召唤的这张卡从场上离开的场合除外。”
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
