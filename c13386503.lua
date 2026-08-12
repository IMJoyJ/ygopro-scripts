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
	-- 检测是否与对方怪兽战斗并战斗破坏对方怪兽送去墓地
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c13386503.sptg)
	e1:SetOperation(c13386503.spop)
	c:RegisterEffect(e1)
end
-- 设置效果的处理目标函数
function c13386503.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 判断场上是否有足够位置特殊召唤目标怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 将目标怪兽设置为效果处理对象
	Duel.SetTargetCard(bc)
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 设置效果的处理运算函数
function c13386503.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
