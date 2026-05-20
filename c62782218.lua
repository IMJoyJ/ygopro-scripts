--スカル・コンダクター
-- 效果：
-- ①：把这张卡从手卡送去墓地才能发动。攻击力合计直到变成2000为止选手卡最多2只不死族怪兽，那些怪兽特殊召唤。
-- ②：自己·对方的战斗阶段结束时发动。场上的表侧表示的这张卡破坏。
function c62782218.initial_effect(c)
	-- ②：自己·对方的战斗阶段结束时发动。场上的表侧表示的这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62782218,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetTarget(c62782218.destg)
	e1:SetOperation(c62782218.desop)
	c:RegisterEffect(e1)
	-- ①：把这张卡从手卡送去墓地才能发动。攻击力合计直到变成2000为止选手卡最多2只不死族怪兽，那些怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62782218,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(c62782218.spcost)
	e2:SetTarget(c62782218.sptg)
	e2:SetOperation(c62782218.spop)
	c:RegisterEffect(e2)
end
-- 破坏效果的Target函数，确认发动并设置操作信息
function c62782218.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 破坏效果的Operation函数，若此卡在场上表侧表示则将其破坏
function c62782218.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 因效果破坏这张卡
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 特殊召唤效果的Cost函数，检测并执行将自身送去墓地
function c62782218.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 作为发动代价将这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤手卡中攻击力在2000以下、可以特殊召唤的不死族怪兽
function c62782218.spfilter(c,e,tp)
	return c:IsAttackBelow(2000) and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查选中的怪兽组的攻击力合计是否等于2000
function c62782218.fselect(g)
	return g:GetSum(Card.GetAttack)==2000
end
-- 特殊召唤效果的Target函数，检测手卡中是否存在符合条件的怪兽并设置特殊召唤操作信息
function c62782218.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 计算可特殊召唤的怪兽数量上限（空位与2的较小值）
		local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
		if ft<=0 then return false end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 获取手卡中除这张卡以外满足特殊召唤条件的不死族怪兽
		local g=Duel.GetMatchingGroup(c62782218.spfilter,tp,LOCATION_HAND,0,e:GetHandler(),e,tp)
		return g:CheckSubGroup(c62782218.fselect,1,ft)
	end
	-- 设置当前连锁的操作信息为从手卡特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的Operation函数，选择并特殊召唤攻击力合计为2000的不死族怪兽
function c62782218.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算可特殊召唤的怪兽数量上限（空位与2的较小值）
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取手卡中满足特殊召唤条件的不死族怪兽
	local g=Duel.GetMatchingGroup(c62782218.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if g:CheckSubGroup(c62782218.fselect,1,ft) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroup(tp,c62782218.fselect,false,1,ft)
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
