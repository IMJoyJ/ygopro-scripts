--クリアウィング・ファスト・ドラゴン
-- 效果：
-- ←4 【灵摆】 4→
-- 「幻透翼疾速龙」的灵摆效果1回合只能使用1次。
-- ①：把等级合计直到7的自己场上的表侧表示的1只「疾行机人」调整和1只调整以外的怪兽送去墓地才能发动。灵摆区域的这张卡特殊召唤。
-- 【怪兽效果】
-- 调整＋调整以外的风属性怪兽1只以上
-- 「幻透翼疾速龙」的①的怪兽效果1回合只能使用1次。
-- ①：以从额外卡组特殊召唤的对方场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力变成0，效果无效化。这个效果在对方回合也能发动。
-- ②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c90036274.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的风属性怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_WIND),1)
	c:EnableReviveLimit()
	-- 为这张卡添加灵摆怪兽属性（不注册灵摆卡“卡的发动”的效果）
	aux.EnablePendulumAttribute(c,false)
	-- 「幻透翼疾速龙」的灵摆效果1回合只能使用1次。①：把等级合计直到7的自己场上的表侧表示的1只「疾行机人」调整和1只调整以外的怪兽送去墓地才能发动。灵摆区域的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90036274,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,90036274)
	e1:SetCost(c90036274.spcost)
	e1:SetTarget(c90036274.sptg)
	e1:SetOperation(c90036274.spop)
	c:RegisterEffect(e1)
	-- 「幻透翼疾速龙」的①的怪兽效果1回合只能使用1次。①：以从额外卡组特殊召唤的对方场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力变成0，效果无效化。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90036274,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,90036275)
	-- 限制该效果在伤害步骤中只能在伤害计算前发动
	e2:SetCondition(aux.dscon)
	e2:SetTarget(c90036274.distg)
	e2:SetOperation(c90036274.disop)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(90036274,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c90036274.pencon)
	e3:SetTarget(c90036274.pentg)
	e3:SetOperation(c90036274.penop)
	c:RegisterEffect(e3)
end
-- 定义用于过滤自己场上表侧表示、等级在7以下、可以送去墓地作为Cost的「疾行机人」调整怪兽的条件
function c90036274.cfilter1(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x2016) and c:IsType(TYPE_TUNER) and c:IsAbleToGraveAsCost() and c:IsLevelBelow(7)
		-- 检查自己场上是否存在与该调整怪兽等级合计为7的非调整怪兽
		and Duel.IsExistingMatchingCard(c90036274.cfilter2,tp,LOCATION_MZONE,0,1,c,c:GetLevel())
end
-- 定义用于过滤自己场上表侧表示、等级为(7-lv)、非调整、可以送去墓地作为Cost的怪兽的条件
function c90036274.cfilter2(c,lv)
	return c:IsFaceup() and not c:IsType(TYPE_TUNER) and c:IsLevel(7-lv) and c:IsAbleToGraveAsCost()
end
-- 定义灵摆效果①的Cost：选择自己场上等级合计为7的一只「疾行机人」调整和一只非调整怪兽送去墓地
function c90036274.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在满足条件的「疾行机人」调整怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90036274.cfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向发动效果的玩家提示“请选择要送去墓地的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1只满足条件的「疾行机人」调整怪兽
	local g1=Duel.SelectMatchingCard(tp,c90036274.cfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 向发动效果的玩家提示“请选择要送去墓地的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1只与已选调整怪兽等级合计为7的非调整怪兽
	local g2=Duel.SelectMatchingCard(tp,c90036274.cfilter2,tp,LOCATION_MZONE,0,1,1,g1:GetFirst(),g1:GetFirst():GetLevel())
	g1:Merge(g2)
	-- 将选中的两只怪兽送去墓地作为发动的Cost
	Duel.SendtoGrave(g1,REASON_COST)
end
-- 定义灵摆效果①的Target：检查怪兽区域是否有空位以及这张卡是否能特殊召唤，并设置特殊召唤的操作信息
function c90036274.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有足够的空位（因为Cost会送去2只怪兽，所以可用格子数大于-2即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤1张自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义灵摆效果①的Operation：将灵摆区域的这张卡特殊召唤
function c90036274.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义用于过滤对方场上表侧表示、从额外卡组特殊召唤、且攻击力大于0或效果未被无效的怪兽的条件
function c90036274.disfilter(c)
	-- 检查卡片是否为表侧表示、从额外卡组特殊召唤，且攻击力大于0或可以被无效化
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA) and (c:GetAttack()>0 or aux.NegateMonsterFilter(c))
end
-- 定义怪兽效果①的Target：选择对方场上1只从额外卡组特殊召唤的表侧表示怪兽作为对象
function c90036274.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c90036274.disfilter(chkc) end
	-- 检查对方场上是否存在满足条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c90036274.disfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家提示“请选择要无效的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择对方场上1只满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c90036274.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 定义怪兽效果①的Operation：使作为对象的怪兽攻击力变成0，效果无效化
function c90036274.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使与该怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 定义怪兽效果②的Condition：检查这张卡是否在怪兽区域被战斗或效果破坏
function c90036274.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 定义怪兽效果②的Target：检查自己的灵摆区域是否有空位
function c90036274.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的左或右灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 定义怪兽效果②的Operation：将这张卡在自己的灵摆区域放置
function c90036274.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示移动到自己的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
