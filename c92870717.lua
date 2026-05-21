--魔装戦士 ドラゴノックス
-- 效果：
-- ←7 【灵摆】 7→
-- ①：对方怪兽的攻击宣言时才能发动。这张卡破坏，那次战斗阶段结束。
-- 【怪兽效果】
-- ①：1回合1次，丢弃1张手卡，以自己墓地的攻击力2000以下的1只战士族或者魔法师族怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
function c92870717.initial_effect(c)
	-- 初始化灵摆怪兽的灵摆效果与灵摆召唤规则
	aux.EnablePendulumAttribute(c)
	-- ①：对方怪兽的攻击宣言时才能发动。这张卡破坏，那次战斗阶段结束。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c92870717.descon)
	e2:SetTarget(c92870717.destg)
	e2:SetOperation(c92870717.desop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，丢弃1张手卡，以自己墓地的攻击力2000以下的1只战士族或者魔法师族怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(c92870717.spcost)
	e3:SetTarget(c92870717.sptg)
	e3:SetOperation(c92870717.spop)
	c:RegisterEffect(e3)
end
-- 灵摆效果发动条件判定函数（对方怪兽攻击宣言时）
function c92870717.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 灵摆效果发动准备与目标确认函数
function c92870717.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时的操作信息为破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果处理函数（破坏自身并结束战斗阶段）
function c92870717.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试因效果破坏自身，并判定是否破坏成功
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		-- 跳过对方的战斗阶段，使其直接进入结束步骤（即结束战斗阶段）
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
-- 怪兽效果发动代价（cost）判定与执行函数
function c92870717.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查手牌中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_DISCARD+REASON_COST,nil)
end
-- 过滤出自己墓地中攻击力2000以下、种族为战士族或魔法师族且能特殊召唤的怪兽
function c92870717.spfilter(c,e,tp)
	return c:IsAttackBelow(2000) and c:IsRace(RACE_WARRIOR+RACE_SPELLCASTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 怪兽效果发动准备与目标选择函数
function c92870717.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c92870717.spfilter(chkc,e,tp) end
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己墓地中是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c92870717.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 在客户端弹出提示信息，提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c92870717.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时的操作信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 怪兽效果处理函数（将对象怪兽里侧守备表示特殊召唤）
function c92870717.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方玩家展示并确认被里侧特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
