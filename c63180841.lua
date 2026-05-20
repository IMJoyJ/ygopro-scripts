--シューティング・スター・ドラゴン・TG－EX
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上的怪兽为对象的怪兽的效果发动时，从自己墓地把1只调整除外才能发动。那个发动无效并破坏。
-- ②：对方怪兽的攻击宣言时才能发动。那次攻击无效。
-- ③：对方回合，这张卡在墓地存在的场合，把自己场上2只同调怪兽解放才能发动。这张卡特殊召唤。
function c63180841.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续：同调怪兽调整＋调整以外的同调怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1)
	-- ①：自己场上的怪兽为对象的怪兽的效果发动时，从自己墓地把1只调整除外才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63180841,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c63180841.discon)
	e1:SetCost(c63180841.discost)
	e1:SetTarget(c63180841.distg)
	e1:SetOperation(c63180841.disop)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的攻击宣言时才能发动。那次攻击无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63180841,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,63180841)
	e2:SetCondition(c63180841.atkcon)
	e2:SetOperation(c63180841.atkop)
	c:RegisterEffect(e2)
	-- ③：对方回合，这张卡在墓地存在的场合，把自己场上2只同调怪兽解放才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63180841,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,63180842)
	e3:SetCondition(c63180841.spcon)
	e3:SetCost(c63180841.spcost)
	e3:SetTarget(c63180841.sptg)
	e3:SetOperation(c63180841.spop)
	c:RegisterEffect(e3)
end
c63180841.material_type=TYPE_SYNCHRO
-- 过滤条件：自己场上的怪兽
function c63180841.tfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 过滤条件：自己墓地的调整怪兽且可以作为代价除外
function c63180841.disfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
-- 效果①的发动条件判定：以自己场上的怪兽为对象的怪兽效果发动时
function c63180841.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not re:IsActiveType(TYPE_MONSTER) then return false end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判定对象中是否存在自己场上的怪兽，且该发动可以被无效
	return tg and tg:IsExists(c63180841.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 效果①的发动代价：从自己墓地把1只调整除外
function c63180841.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查自己墓地是否存在可作为代价除外的调整怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c63180841.disfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地1只满足条件的调整怪兽
	local g=Duel.SelectMatchingCard(tp,c63180841.disfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的调整怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果①的目标判定：设置无效发动与破坏的操作信息
function c63180841.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①的效果处理：使发动无效并破坏
function c63180841.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且该卡在场上关系成立
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 效果②的发动条件判定：对方怪兽攻击宣言时
function c63180841.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击怪兽的控制者是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果②的效果处理：那次攻击无效
function c63180841.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该次攻击
	Duel.NegateAttack()
end
-- 过滤条件：自己场上的同调怪兽
function c63180841.spfilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果③的发动条件判定：对方回合
function c63180841.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果③的发动代价：把自己场上2只同调怪兽解放
function c63180841.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可解放的同调怪兽
	local g=Duel.GetReleaseGroup(tp):Filter(c63180841.spfilter,nil,tp)
	-- 在chk==0时，检查是否能选择2只同调怪兽解放，且解放后有足够的怪兽区域用于特殊召唤
	if chk==0 then return g:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 让玩家选择2只满足解放条件的同调怪兽
	local rg=g:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 应用代替解放等相关效果（如适用）
	aux.UseExtraReleaseCount(rg,tp)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(rg,REASON_COST)
end
-- 效果③的目标判定：设置特殊召唤的操作信息
function c63180841.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将墓地的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理：这张卡特殊召唤
function c63180841.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
