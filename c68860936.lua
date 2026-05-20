--ティンダングル・エンジェル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡反转的场合才能发动。从自己的手卡·墓地选「廷达魔三角之天使」以外的1只反转怪兽里侧守备表示特殊召唤。这个效果在对方回合的战斗阶段发动的场合，再把那次战斗阶段结束。
function c68860936.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从自己的手卡·墓地选「廷达魔三角之天使」以外的1只反转怪兽里侧守备表示特殊召唤。这个效果在对方回合的战斗阶段发动的场合，再把那次战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68860936,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,68860936)
	e1:SetTarget(c68860936.target)
	e1:SetOperation(c68860936.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡·墓地中「廷达魔三角之天使」以外、可以里侧守备表示特殊召唤的反转怪兽
function c68860936.filter(c,e,tp)
	return c:IsType(TYPE_FLIP) and not c:IsCode(68860936) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果①的发动准备与合法性检测（检查怪兽区域空位及是否存在可特召的怪兽）
function c68860936.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或墓地是否存在至少1只满足过滤条件的反转怪兽
		and Duel.IsExistingMatchingCard(c68860936.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从手卡或墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的处理逻辑（特殊召唤怪兽，若在对方回合战斗阶段发动则结束战斗阶段）
function c68860936.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足条件的反转怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c68860936.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认特殊召唤的里侧表示怪兽
		Duel.ConfirmCards(1-tp,g)
	end
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否为对方回合的战斗阶段
	if tp~=Duel.GetTurnPlayer() and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE then
		-- 跳过对方的战斗阶段，使其直接结束
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
