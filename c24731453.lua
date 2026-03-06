--除雪機関車ハッスル・ラッセル
-- 效果：
-- ①：自己的魔法与陷阱区域有卡存在的场合，对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，自己的魔法与陷阱区域的卡全部破坏，给与对方破坏数量×200伤害。
-- ②：只要这张卡在怪兽区域存在，自己不是机械族怪兽不能特殊召唤。
function c24731453.initial_effect(c)
	-- 效果原文内容：①：自己的魔法与陷阱区域有卡存在的场合，对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，自己的魔法与陷阱区域的卡全部破坏，给与对方破坏数量×200伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24731453,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c24731453.spcon)
	e1:SetTarget(c24731453.sptg)
	e1:SetOperation(c24731453.spop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：只要这张卡在怪兽区域存在，自己不是机械族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c24731453.splimit)
	c:RegisterEffect(e2)
end
-- 规则层面作用：限制非机械族怪兽不能特殊召唤
function c24731453.splimit(e,c)
	return c:GetRace()~=RACE_MACHINE
end
-- 规则层面作用：过滤魔法与陷阱区域的卡（序列小于5）
function c24731453.cfilter(c)
	return c:GetSequence()<5
end
-- 规则层面作用：判断是否满足效果发动条件（对方怪兽直接攻击且己方魔法与陷阱区有卡）
function c24731453.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断攻击方是否为对方
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
		-- 规则层面作用：判断己方魔法与陷阱区是否存在卡
		and Duel.IsExistingMatchingCard(c24731453.cfilter,tp,LOCATION_SZONE,0,1,nil)
end
-- 规则层面作用：过滤魔法与陷阱区域的卡（序列小于5）
function c24731453.filter(c)
	return c:GetSequence()<5
end
-- 规则层面作用：判断是否满足特殊召唤的发动条件
function c24731453.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断场上是否有足够空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面作用：获取己方魔法与陷阱区所有卡的集合
	local g=Duel.GetMatchingGroup(c24731453.filter,tp,LOCATION_SZONE,0,nil)
	-- 规则层面作用：设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 规则层面作用：设置破坏操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面作用：执行效果处理流程（特殊召唤后破坏并造成伤害）
function c24731453.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 规则层面作用：将此卡特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 规则层面作用：获取己方魔法与陷阱区所有卡的集合
		local g=Duel.GetMatchingGroup(c24731453.filter,tp,LOCATION_SZONE,0,nil)
		if g:GetCount()>0 then
			-- 规则层面作用：中断当前连锁处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 规则层面作用：将指定卡破坏
			local ct=Duel.Destroy(g,REASON_EFFECT)
			-- 规则层面作用：给与对方相应数量×200的伤害
			Duel.Damage(1-tp,ct*200,REASON_EFFECT)
		end
	end
end
