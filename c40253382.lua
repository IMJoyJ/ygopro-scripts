--TG－SX1
-- 效果：
-- 自己场上存在的名字带有「科技属」的怪兽战斗破坏对方怪兽送去墓地时才能发动。选择自己墓地存在的1只名字带有「科技属」的同调怪兽特殊召唤。
function c40253382.initial_effect(c)
	-- 效果原文内容：自己场上存在的名字带有「科技属」的怪兽战斗破坏对方怪兽送去墓地时才能发动。选择自己墓地存在的1只名字带有「科技属」的同调怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c40253382.condition)
	e1:SetTarget(c40253382.target)
	e1:SetOperation(c40253382.activate)
	c:RegisterEffect(e1)
end
-- 规则层面操作：检查被战斗破坏送入墓地的怪兽是否为玩家控制且名字带有「科技属」的怪兽
function c40253382.cfilter(c,tp)
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
		and rc:IsSetCard(0x27) and rc:IsControler(tp) and rc:IsRelateToBattle()
end
-- 规则层面操作：确认是否有满足条件的怪兽被战斗破坏并送入墓地
function c40253382.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c40253382.cfilter,1,nil,tp)
end
-- 规则层面操作：筛选墓地中名字带有「科技属」且为同调怪兽的卡片
function c40253382.filter(c,e,tp)
	return c:IsSetCard(0x27) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：设置效果的目标为满足条件的墓地中的同调怪兽
function c40253382.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40253382.filter(chkc,e,tp) end
	-- 规则层面操作：判断玩家场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：确认玩家墓地中是否存在满足条件的同调怪兽
		and Duel.IsExistingTarget(c40253382.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面操作：向玩家发送提示信息，提示其选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：选择满足条件的墓地中的同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c40253382.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面操作：设置连锁的操作信息，表明将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果原文内容：自己场上存在的名字带有「科技属」的怪兽战斗破坏对方怪兽送去墓地时才能发动。选择自己墓地存在的1只名字带有「科技属」的同调怪兽特殊召唤。
function c40253382.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面操作：将目标卡片特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
