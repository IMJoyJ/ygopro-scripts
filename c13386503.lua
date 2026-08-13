--ジャッカルの霊騎士
-- 效果：
-- 可以将1只被这张卡战斗破坏并被送去墓地的对方怪兽以表侧守备表示特殊召唤到自己场上。
function c13386503.initial_effect(c)
	-- 可以将1只被这张卡战斗破坏并被送去墓地的对方怪兽以表侧守备表示特殊召唤到自己场上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13386503,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- 设置效果的发动条件：这张卡与对方怪兽战斗并战斗破坏对方怪兽送去墓地时才可发动（由aux.bdogcon检测本卡与战斗相关、对方怪兽在墓地且为怪兽）。
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c13386503.sptg)
	e1:SetOperation(c13386503.spop)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标处理（Target）：取得被这张卡战斗破坏的对方怪兽，检查自己主要怪兽区有空位且该怪兽可以以表侧守备表示特殊召唤，以满足发动条件。
function c13386503.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 作为发动条件之一：确认自己场上主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 将该被战斗破坏的对方怪兽设定为效果对象，使其与当前效果建立关联（用于效果处理时检索和检测关系）。
	Duel.SetTargetCard(bc)
	-- 设置操作信息：声明本效果为特殊召唤效果，目标为那只怪兽，数量为1，用于满足相关效果联动或检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 效果处理函数：在效果结算时，取得之前设定的对象，若其仍与该效果关联，则将其以表侧守备表示特殊召唤到自己场上。
function c13386503.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时设定的对象（即被这张卡战斗破坏并送去墓地的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上（不检查召唤条件和苏生限制，因为原效果没有限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
