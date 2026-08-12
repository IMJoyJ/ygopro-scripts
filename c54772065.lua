--B・F－連撃のツインボウ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是昆虫族怪兽不能从额外卡组特殊召唤。
-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
function c54772065.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是昆虫族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54772065,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,54772065)
	e1:SetTarget(c54772065.sptg)
	e1:SetOperation(c54772065.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 特殊召唤效果的发动检测，判断自身是否能特殊召唤以及场上是否有空位
function c54772065.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测当前玩家的主要怪兽区域是否有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，用于后续连锁处理的判定
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行，将自身特殊召唤并对玩家施加不能从额外卡组特殊召唤昆虫族以外怪兽的限制
function c54772065.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到当前玩家的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是昆虫族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c54772065.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制特殊召唤的效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件，限制不能特殊召唤非昆虫族的额外卡组怪兽
function c54772065.splimit(e,c)
	return not c:IsRace(RACE_INSECT) and c:IsLocation(LOCATION_EXTRA)
end
