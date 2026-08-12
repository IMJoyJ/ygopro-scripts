--極氷獣ブリザード・ウルフ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己或者对方的怪兽的攻击宣言时才能发动。那次攻击无效，从手卡把「极冰兽 雪暴狼」以外的1只4星以下的水属性怪兽特殊召唤。
-- ②：这张卡在墓地存在，自己场上没有怪兽存在的场合，对方战斗阶段开始时才能发动。这张卡攻击表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c43175027.initial_effect(c)
	-- ①：自己或者对方的怪兽的攻击宣言时才能发动。
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
	-- ②：这张卡在墓地存在，自己场上没有怪兽存在的场合，对方战斗阶段开始时才能发动。
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
-- 过滤函数，用于筛选满足条件的水属性4星以下的怪兽（不包括雪暴狼）
function c43175027.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelBelow(4) and not c:IsCode(43175027)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 攻击宣言时效果的处理函数，判断是否满足发动条件
function c43175027.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c43175027.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只手牌中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 攻击宣言时效果的处理函数，执行效果内容
function c43175027.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效此次攻击
	if Duel.NegateAttack() then
		-- 判断自己场上是否有空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的1只手牌怪兽
		local tc=Duel.SelectMatchingCard(tp,c43175027.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
		if tc then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 特殊召唤条件函数，判断是否满足发动条件
function c43175027.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是自己且自己场上没有怪兽
	return tp~=Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 战斗阶段开始时效果的处理函数，判断是否满足发动条件
function c43175027.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 战斗阶段开始时效果的处理函数，执行效果内容
function c43175027.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否可以特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)>0 then
		-- 设置效果，使该卡从场上离开时被除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
