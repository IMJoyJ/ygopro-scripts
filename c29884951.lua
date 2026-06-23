--相剣瑞獣－純鈞
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把自己场上1只怪兽解放才能发动。这张卡从手卡特殊召唤。
-- ②：自己的幻龙族怪兽和从额外卡组特殊召唤的对方怪兽进行战斗的伤害计算前才能发动。那只对方怪兽和这张卡破坏。
-- ③：这张卡作为同调素材送去墓地的场合，以自己或者对方的场上·墓地1张卡为对象才能发动。那张卡除外。
function c29884951.initial_effect(c)
	-- ①：自己·对方的主要阶段，把自己场上1只怪兽解放才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29884951,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,29884951)
	e1:SetCondition(c29884951.spcon)
	e1:SetCost(c29884951.spcost)
	e1:SetTarget(c29884951.sptg)
	e1:SetOperation(c29884951.spop)
	c:RegisterEffect(e1)
	-- ②：自己的幻龙族怪兽和从额外卡组特殊召唤的对方怪兽进行战斗的伤害计算前才能发动。那只对方怪兽和这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29884951,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_CONFIRM)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c29884951.descon)
	e2:SetTarget(c29884951.destg)
	e2:SetOperation(c29884951.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡作为同调素材送去墓地的场合，以自己或者对方的场上·墓地1张卡为对象才能发动。那张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29884951,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,29884952)
	e3:SetCondition(c29884951.remcon)
	e3:SetTarget(c29884951.remtg)
	e3:SetOperation(c29884951.remop)
	c:RegisterEffect(e3)
end
-- 判断当前是否为自己的主要阶段1或主要阶段2
function c29884951.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 筛选满足条件的可解放怪兽（必须是怪兽类型且场上存在可用怪兽区）
function c29884951.rfilter(c,tp)
	-- 判断目标是否为怪兽类型且场上存在可用怪兽区
	return c:IsType(TYPE_MONSTER) and Duel.GetMZoneCount(tp,c)>0
end
-- 检查是否满足解放怪兽的条件并选择1张怪兽进行解放
function c29884951.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放怪兽的条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c29884951.rfilter,1,nil,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的1张怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c29884951.rfilter,1,1,nil,tp)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 设置特殊召唤的处理目标
function c29884951.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c29884951.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否满足破坏效果的发动条件
function c29884951.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的怪兽
	local a,d=Duel.GetBattleMonster(tp)
	return a and d and a:IsFaceup() and a:IsRelateToBattle() and a:IsRace(RACE_WYRM)
		and d:IsFaceup() and d:IsRelateToBattle() and d:IsSummonLocation(LOCATION_EXTRA)
end
-- 设置破坏效果的处理目标
function c29884951.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取当前战斗中的怪兽
	local a,d=Duel.GetBattleMonster(tp)
	local g=Group.FromCards(d,e:GetHandler())
	-- 设置破坏效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 执行破坏操作
function c29884951.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前战斗中的怪兽
	local a,d=Duel.GetBattleMonster(tp)
	if c:IsFaceup() and c:IsRelateToEffect(e) and d and d:IsRelateToBattle() then
		local g=Group.FromCards(d,c)
		-- 破坏目标怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 判断是否满足除外效果的发动条件
function c29884951.remcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 筛选可除外的卡片
function c29884951.remfilter(c)
	return c:IsAbleToRemove()
end
-- 设置除外效果的处理目标
function c29884951.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and c29884951.remfilter(chkc) end
	-- 检查是否存在满足条件的除外目标
	if chk==0 then return Duel.IsExistingTarget(c29884951.remfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张卡进行除外
	local g=aux.SelectTargetFromFieldFirst(tp,c29884951.remfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	-- 设置除外效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行除外操作
function c29884951.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
