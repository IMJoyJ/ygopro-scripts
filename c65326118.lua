--天盃龍ファドラ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合或者怪兽进行战斗的伤害步骤开始时，以自己墓地1只4星以下的龙族·炎属性怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己的龙族·炎属性怪兽不会被战斗破坏。
-- ③：1回合1次，自己·对方的战斗阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
function c65326118.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合或者怪兽进行战斗的伤害步骤开始时，以自己墓地1只4星以下的龙族·炎属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65326118,0))  --"特殊召唤墓地怪兽"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,65326118)
	e1:SetTarget(c65326118.sptg)
	e1:SetOperation(c65326118.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，自己的龙族·炎属性怪兽不会被战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(c65326118.indtg)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ③：1回合1次，自己·对方的战斗阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(65326118,2))  --"同调召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_STEP_END+TIMING_BATTLE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c65326118.sccon)
	e5:SetTarget(c65326118.sctg)
	e5:SetOperation(c65326118.scop)
	c:RegisterEffect(e5)
end
-- 过滤条件：自己墓地4星以下的龙族·炎属性且能特殊召唤的怪兽
function c65326118.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备与目标选择
function c65326118.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c65326118.filter(chkc,e,tp) end
	-- 发动条件判定：检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件判定：检查自己墓地是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingTarget(c65326118.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方玩家提示发动了“特殊召唤墓地怪兽”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(65326118,0))  --"特殊召唤墓地怪兽"
	-- 向自己提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c65326118.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息：包含特殊召唤分类，操作对象为选择的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①号效果的处理：将选择的墓地怪兽特殊召唤
function c65326118.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②号效果的适用对象过滤：自己的龙族·炎属性怪兽
function c65326118.indtg(e,c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- ③号效果的发动条件：自己或对方的战斗阶段
function c65326118.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- ③号效果的发动准备与同调召唤可行性判定
function c65326118.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：检查额外卡组是否存在可以用这张卡作为素材进行同调召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 向对方玩家提示发动了“同调召唤”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(65326118,2))  --"同调召唤"
	-- 设置连锁信息：包含从额外卡组特殊召唤1只怪兽的分类
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③号效果的处理：用包含这张卡的自己场上的怪兽为素材进行同调召唤
function c65326118.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有可以用这张卡作为素材进行同调召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 向自己提示选择要特殊召唤（同调召唤）的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡为素材，对选择的怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
