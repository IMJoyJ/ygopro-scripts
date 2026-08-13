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
-- 效果①的发动条件判断：仅当当前阶段为主要阶段1或主要阶段2时，才能发动（自己·对方的主要阶段）。
function c29884951.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否为主要阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 解放候选过滤器：候选卡必须是怪兽，且解放该卡后自己场上有空余的怪兽区，以便后续从手卡特殊召唤这张卡。
function c29884951.rfilter(c,tp)
	-- 判定候选卡是怪兽且解放后自己场上仍有可用的怪兽区。
	return c:IsType(TYPE_MONSTER) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的发动代价处理：从自己场上解放1只怪兽作为COST；先检查是否存在满足条件的可解放怪兽，再选择并解放。
function c29884951.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- COST检测：确认自己场上是否存在至少1只满足rfilter条件（是怪兽且解放后有空位）的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c29884951.rfilter,1,nil,tp) end
	-- 给玩家显示“请选择要解放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从自己场上选择1只满足条件的怪兽作为解放COST。
	local g=Duel.SelectReleaseGroup(tp,c29884951.rfilter,1,1,nil,tp)
	-- 将被选择的怪兽作为COST解放。
	Duel.Release(g,REASON_COST)
end
-- 效果①的目标阶段：确认这张卡本身能够被特殊召唤，并设置后续特殊召唤的操作信息。
function c29884951.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息：本次处理包含特殊召唤，对象是这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：若这张卡仍与该效果关联，则将其特殊召唤。
function c29884951.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到其控制者（tp）场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：自己的幻龙族怪兽与从额外卡组特殊召唤的对方怪兽进行战斗的伤害计算前，且双方怪兽均为表侧表示并与战斗相关。
function c29884951.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方和对方正在战斗中的怪兽。
	local a,d=Duel.GetBattleMonster(tp)
	return a and d and a:IsFaceup() and a:IsRelateToBattle() and a:IsRace(RACE_WYRM)
		and d:IsFaceup() and d:IsRelateToBattle() and d:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果②的目标设定：满足条件即可发动，将对方那只从额外卡组特殊召唤的战斗怪兽和这张卡作为破坏对象。
function c29884951.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取己方和对方正在战斗中的怪兽，用于设置目标。
	local a,d=Duel.GetBattleMonster(tp)
	local g=Group.FromCards(d,e:GetHandler())
	-- 设置破坏操作信息：将对方战斗怪兽和这张卡作为可能被破坏的卡，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 效果②的处理：若这张卡仍表侧且与效果相关，对方战斗怪兽仍与战斗相关，则将对方那只怪兽和这张卡破坏。
function c29884951.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前战斗中的双方怪兽，用于处理时确认对象。
	local a,d=Duel.GetBattleMonster(tp)
	if c:IsFaceup() and c:IsRelateToEffect(e) and d and d:IsRelateToBattle() then
		local g=Group.FromCards(d,c)
		-- 将对方战斗怪兽和这张卡因效果破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 效果③的发动条件：这张卡作为同调素材被送去墓地时才能发动。
function c29884951.remcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 除外候选过滤器：判断卡片是否可以被除外。
function c29884951.remfilter(c)
	return c:IsAbleToRemove()
end
-- 效果③的目标设定：选择双方场上·墓地中1张可以除外的卡作为对象，并设置除外操作信息。
function c29884951.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and c29884951.remfilter(chkc) end
	-- 目标检测：确认双方场上·墓地是否存在至少1张满足remfilter条件的卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c29884951.remfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 给玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 使用辅助选择函数，优先从场上选择满足条件的对象，若场上不足再从墓地等区域选择，最终选择1张。
	local g=aux.SelectTargetFromFieldFirst(tp,c29884951.remfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	-- 设置除外操作信息：确定将选中的卡作为除外对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果③的处理：将选中的目标卡除外。
function c29884951.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
