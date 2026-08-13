--リンクリボー
-- 效果：
-- 1星怪兽1只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方怪兽的攻击宣言时，把这张卡解放才能发动。那只对方怪兽的攻击力直到回合结束时变成0。
-- ②：自己·对方回合，这张卡在墓地存在的场合，把自己场上1只1星怪兽解放才能发动。这张卡特殊召唤。
function c41999284.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：用1只1星怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLevel,1),1)
	-- ①：对方怪兽的攻击宣言时，把这张卡解放才能发动。那只对方怪兽的攻击力直到回合结束时变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c41999284.atkcon)
	e1:SetCost(c41999284.atkcost)
	e1:SetOperation(c41999284.atkop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方回合，这张卡在墓地存在的场合，把自己场上1只1星怪兽解放才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,41999284)
	e2:SetHintTiming(0,TIMING_BATTLE_START)
	e2:SetCost(c41999284.spcost)
	e2:SetTarget(c41999284.sptg)
	e2:SetOperation(c41999284.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：仅在对方回合且攻击宣言的怪兽为攻击力不为0的表侧表示怪兽时满足。
function c41999284.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前不是自己的回合，且攻击宣言的怪兽是表侧表示且攻击力不为0，满足①的发动条件。
	return tp~=Duel.GetTurnPlayer() and aux.nzatk(Duel.GetAttacker())
end
-- ①效果的发动代价：检查本卡是否可以被解放，并将自身解放作为代价。
function c41999284.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放发动效果的本卡，解放理由为Cost。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ①效果处理：获取攻击宣言的怪兽，若该怪兽仍与战斗相关且为表侧表示，则使其攻击力直到回合结束时变为0。
function c41999284.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击宣言的怪兽作为效果处理的对象。
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() and tc:IsFaceup() then
		-- 那只对方怪兽的攻击力直到回合结束时变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ②效果解放素材的过滤条件：候选怪兽需为1星，且将其解放后自己场上仍有空余的怪兽区，以便后续特殊召唤。
function c41999284.cfilter(c,tp)
	-- 候选怪兽是1星，且解放后tp场上仍有可用的怪兽区域。
	return c:IsLevel(1) and Duel.GetMZoneCount(tp,c)>0
end
-- ②效果的发动代价：检查自己场上是否存在满足条件的1星可解放怪兽，选择1只解放作为发动代价。
function c41999284.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认自己场上存在至少1只满足cfilter条件的可解放的1星怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c41999284.cfilter,1,nil,tp) end
	-- 发动代价选择时：玩家从自己场上选择1只满足条件的1星怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c41999284.cfilter,1,1,nil,tp)
	-- 解放所选怪兽，解放理由为Cost。
	Duel.Release(g,REASON_COST)
end
-- ②效果的发动目标判断：确认墓地的本卡可以特殊召唤，并登记特殊召唤的操作信息。
function c41999284.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次操作将要把墓地的本卡特殊召唤的信息，供连锁检测和使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若本卡仍与效果存在关联，则将其从墓地特殊召唤到自己场上。
function c41999284.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将本卡以表侧表示特殊召唤到自己场上（不无视召唤条件和苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
