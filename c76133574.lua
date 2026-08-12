--ゴーティスの紅玉ゼップ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把这张卡从手卡除外，以自己墓地1只鱼族怪兽为对象才能发动。那只怪兽除外。
-- ②：这张卡在对方回合被除外的场合才能发动。这张卡特殊召唤。
-- ③：这张卡特殊召唤的场合才能发动。用包含这张卡的自己场上的怪兽为素材进行1只鱼族同调怪兽的同调召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①手卡起动效果、②对方回合被除外诱发效果、③特召成功时同调召唤诱发效果
function s.initial_effect(c)
	-- ①：把这张卡从手卡除外，以自己墓地1只鱼族怪兽为对象才能发动。那只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	-- 设置发动代价为将手卡的这张卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡在对方回合被除外的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡特殊召唤的场合才能发动。用包含这张卡的自己场上的怪兽为素材进行1只鱼族同调怪兽的同调召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.syntg)
	e3:SetOperation(s.synop)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中可以除外的鱼族怪兽
function s.rmfilter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToRemove()
end
-- ①号效果的发动准备与目标选择（取自己墓地1只鱼族怪兽为对象）
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.rmfilter(chkc) end
	-- 检查自己墓地是否存在至少1只可以除外的鱼族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地1只鱼族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，表示该效果的操作为除外指定的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- ①号效果的处理（将作为对象的墓地鱼族怪兽除外）
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②号效果的发动条件判定（在对方回合被除外，且原本持有者是自己）
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定当前是否为对方回合，且这张卡被除外前由自己控制
	return Duel.GetTurnPlayer()==1-tp and c:IsPreviousControler(tp)
end
-- ②号效果的发动准备（特殊召唤自身）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域，且自身是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表示该效果的操作为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②号效果的处理（将自身特殊召唤）
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤额外卡组中，可以使用这张卡作为素材进行同调召唤的鱼族同调怪兽
function s.synfilter(c,mc)
	return c:IsRace(RACE_FISH) and c:IsSynchroSummonable(mc)
end
-- ③号效果的发动准备（进行鱼族同调召唤）
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前是否不处于伤害步骤
	if chk==0 then return Duel.GetCurrentPhase()~=PHASE_DAMAGE
		-- 检查额外卡组是否存在可以使用这张卡作为素材进行同调召唤的鱼族同调怪兽
		and Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 设置连锁信息，表示该效果的操作为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③号效果的处理（用包含这张卡的自己场上怪兽为素材，进行1只鱼族同调怪兽的同调召唤）
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有可以使用这张卡作为素材进行同调召唤的鱼族同调怪兽
	local g=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil,c)
	if #g>0 then
		-- 提示玩家选择要特殊召唤的同调怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 玩家以这张卡为素材，对选定的鱼族同调怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
