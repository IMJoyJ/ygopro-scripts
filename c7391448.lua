--ゴヨウ・ガーディアン
-- 效果：
-- 地属性调整＋调整以外的怪兽1只以上
-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽在自己场上守备表示特殊召唤。
function c7391448.initial_effect(c)
	-- 设置同调召唤手续：地属性调整 + 调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽在自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7391448,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- 设置发动条件为：这张卡战斗破坏对方怪兽并送去墓地
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c7391448.sptg)
	e1:SetOperation(c7391448.spop)
	c:RegisterEffect(e1)
end
-- 效果发动检测：获取被战斗破坏的怪兽，并确认自己场上有空位且该怪兽可以被特殊召唤
function c7391448.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 将被战斗破坏的怪兽设为效果处理的对象
	Duel.SetTargetCard(bc)
	-- 设置连锁的操作信息为：特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 效果处理：获取对象怪兽，若其仍与效果相关联，则将其在自己场上守备表示特殊召唤
function c7391448.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的那只被战斗破坏的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽在自己场上表侧守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
