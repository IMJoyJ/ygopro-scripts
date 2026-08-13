--セットアッパー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己怪兽被战斗破坏时才能发动。把持有那只怪兽的攻击力以下的攻击力的1只怪兽从手卡·卡组里侧守备表示特殊召唤。
function c19590644.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己怪兽被战斗破坏时才能发动。把持有那只怪兽的攻击力以下的攻击力的1只怪兽从手卡·卡组里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,19590644+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c19590644.condition)
	e1:SetTarget(c19590644.target)
	e1:SetOperation(c19590644.activate)
	c:RegisterEffect(e1)
end
-- 作为条件筛选，判断被战斗破坏的怪兽上一控制者是否是我方，即确认是我方怪兽被战斗破坏。
function c19590644.cfilter(c,tp)
	return c:IsPreviousControler(tp)
end
-- 从战斗破坏的怪兽集合中选出我方怪兽；若没有则效果条件不成立；记录那只怪兽的攻击力（若为负数按0处理）到效果标签，供后续特殊召唤的数值判定使用。
function c19590644.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:Filter(c19590644.cfilter,nil,tp):GetFirst()
	if not tc then return false end
	local atk=tc:GetAttack()
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	return true
end
-- 特殊召唤候选的筛选：攻击力在记录的攻击力以下，且能够以里侧守备表示被特殊召唤。
function c19590644.spfilter(c,e,tp,atk)
	return c:IsAttackBelow(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果发动时的目标合法性检查：我方主要怪兽区有空位，且手卡·卡组中存在满足攻击力条件的可特殊召唤怪兽，才算满足发动条件。
function c19590644.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区域是否存在可用空格，用于放置即将特殊召唤的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在至少1只满足spfilter（攻击力以下且可里侧守备特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(c19590644.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,e:GetLabel()) end
	-- 设置操作信息：本效果将进行特殊召唤，处理时从手卡和卡组把1只怪兽特殊召唤，用于后续时点判定和连锁处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理阶段：实际执行从手卡·卡组选择1只符合条件的怪兽并以里侧守备表示特殊召唤，成功后让对手确认那只怪兽。
function c19590644.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认我方主要怪兽区仍有空格，若没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，告知玩家正在选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己手卡和卡组中选出1只满足spfilter条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c19590644.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	-- 若选到了怪兽，且成功将其以里侧守备表示特殊召唤到我方场上，则继续执行后续确认操作。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 特殊召唤成功后，向对方玩家展示该怪兽卡，让对手确认特殊召唤的怪兽。
		Duel.ConfirmCards(1-tp,g)
	end
end
