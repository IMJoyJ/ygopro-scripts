--転生炎獣アルミラージ
-- 效果：
-- 通常召唤的攻击力1000以下的怪兽1只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己·对方回合，把这张卡解放，以自己场上1只怪兽为对象才能发动。这个回合，那只怪兽不会被对方的效果破坏。
-- ②：这张卡在墓地存在的状态，通常召唤的自己怪兽被战斗破坏时才能发动。这张卡特殊召唤。
function c60303245.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要1只满足过滤条件的怪兽作为素材
	aux.AddLinkProcedure(c,c60303245.matfilter,1,1)
	-- ①：自己·对方回合，把这张卡解放，以自己场上1只怪兽为对象才能发动。这个回合，那只怪兽不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60303245,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c60303245.immcost)
	e1:SetTarget(c60303245.immtg)
	e1:SetOperation(c60303245.immop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，通常召唤的自己怪兽被战斗破坏时才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,60303245)
	e2:SetCondition(c60303245.spcon)
	e2:SetTarget(c60303245.sptg)
	e2:SetOperation(c60303245.spop)
	c:RegisterEffect(e2)
end
-- 过滤连接素材：通常召唤的攻击力1000以下的怪兽
function c60303245.matfilter(c)
	return c:IsSummonType(SUMMON_TYPE_NORMAL) and c:IsAttackBelow(1000)
end
-- 效果①的发动代价判定与执行：解放自身
function c60303245.immcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(c,REASON_COST)
end
-- 效果①的发动准备：检查并选择自己场上1只怪兽作为对象
function c60303245.immtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查自己场上是否存在除自身以外的怪兽可以作为效果对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要作为效果对象的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己场上1只怪兽作为效果对象
	Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的效果处理：使目标怪兽在本回合内获得“不会被对方的效果破坏”的效果
function c60303245.immop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽不会被对方的效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		-- 设置不被破坏的来源为对方的效果
		e1:SetValue(aux.indoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤被战斗破坏的怪兽：原本由自己控制且是通常召唤的怪兽
function c60303245.spcfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_NORMAL) and c:IsPreviousControler(tp)
end
-- 效果②的发动条件：被战斗破坏送去墓地的怪兽中存在自己通常召唤的怪兽
function c60303245.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c60303245.spcfilter,1,nil,tp)
end
-- 效果②的发动准备：检查怪兽区域空位以及自身是否能特殊召唤，并声明特殊召唤的操作信息
function c60303245.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表明该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的效果处理：将墓地的这张卡特殊召唤
function c60303245.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
