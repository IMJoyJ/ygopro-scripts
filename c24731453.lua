--除雪機関車ハッスル・ラッセル
-- 效果：
-- ①：自己的魔法与陷阱区域有卡存在的场合，对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，自己的魔法与陷阱区域的卡全部破坏，给与对方破坏数量×200伤害。
-- ②：只要这张卡在怪兽区域存在，自己不是机械族怪兽不能特殊召唤。
function c24731453.initial_effect(c)
	-- ①：自己的魔法与陷阱区域有卡存在的场合，对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，自己的魔法与陷阱区域的卡全部破坏，给与对方破坏数量×200伤害。
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
	-- ②：只要这张卡在怪兽区域存在，自己不是机械族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c24731453.splimit)
	c:RegisterEffect(e2)
end
-- e2的过滤函数：当被特殊召唤的怪兽种族不是机械族时返回true，从而禁止其特殊召唤。
function c24731453.splimit(e,c)
	return c:GetRace()~=RACE_MACHINE
end
-- 过滤自己的魔法与陷阱区域中通常魔陷区的卡（排除场地魔法格，即序号<5）。用于①的发动条件判定。
function c24731453.cfilter(c)
	return c:GetSequence()<5
end
-- 效果①的发动条件：对方怪兽进行直接攻击宣言，且自己魔法与陷阱区域存在通常魔陷区的卡。
function c24731453.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认攻击怪兽为对方控制，且攻击目标为空（即直接攻击宣言）。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
		-- 确认自己的魔法与陷阱区域存在至少一张通常魔陷区的卡（序号<5），满足①的发动前提。
		and Duel.IsExistingMatchingCard(c24731453.cfilter,tp,LOCATION_SZONE,0,1,nil)
end
-- 过滤自己的魔法与陷阱区域中通常魔陷区的卡（序号<5），用于确定①效果要破坏的卡。
function c24731453.filter(c)
	return c:GetSequence()<5
end
-- 效果①的发动目标检查：自己主要怪兽区有空位，且这张手卡能够特殊召唤。
function c24731453.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区存在可用空格，才能特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 获取自己魔法与陷阱区域中全部通常魔陷区的卡，作为之后将要破坏的对象。
	local g=Duel.GetMatchingGroup(c24731453.filter,tp,LOCATION_SZONE,0,nil)
	-- 向系统登记本连锁将进行特殊召唤操作，特殊召唤对象为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 向系统登记本连锁将破坏上述魔陷区卡片，数量为g的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的解决处理：这张卡从手卡特殊召唤；若成功，则将自己魔法与陷阱区域的通常魔陷区卡全部破坏，每破坏1张给与对方200伤害。
function c24731453.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将这张卡以表侧表示特殊召唤到自己的主要怪兽区；只有特殊召唤成功时才继续处理后续破坏和伤害。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 特殊召唤成功后，再次获取自己魔法与陷阱区域中通常魔陷区的卡作为将要破坏的对象。
		local g=Duel.GetMatchingGroup(c24731453.filter,tp,LOCATION_SZONE,0,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续的破坏与伤害视为另一次处理，避免错过时点。
			Duel.BreakEffect()
			-- 以效果破坏上述所有卡，返回实际破坏数量ct。
			local ct=Duel.Destroy(g,REASON_EFFECT)
			-- 给予对方玩家破坏数量×200的伤害。
			Duel.Damage(1-tp,ct*200,REASON_EFFECT)
		end
	end
end
