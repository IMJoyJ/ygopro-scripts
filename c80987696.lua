--時の機械－タイム・マシーン
-- 效果：
-- ①：自己或者对方的怪兽1只被战斗破坏送去墓地时才能发动。在那只怪兽被破坏时的控制者场上以相同表示形式把那只怪兽特殊召唤。
function c80987696.initial_effect(c)
	-- ①：自己或者对方的怪兽1只被战斗破坏送去墓地时才能发动。在那只怪兽被破坏时的控制者场上以相同表示形式把那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetTarget(c80987696.target)
	e1:SetOperation(c80987696.activate)
	c:RegisterEffect(e1)
end
-- 检查作为发动条件而被战斗破坏送去墓地的怪兽是否可以特殊召唤到其原本控制者的场上
function c80987696.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	-- 判断该怪兽原本控制者的怪兽区域是否有空位，且被战斗破坏送去墓地的怪兽数量是否刚好为1只
	if chk==0 then return Duel.GetLocationCount(tc:GetPreviousControler(),LOCATION_MZONE)>0 and eg:GetCount()==1
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,tc:GetPreviousPosition(),tc:GetPreviousControler()) end
	tc:CreateEffectRelation(e)
	-- 设置当前连锁的操作信息为特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,eg,1,0,0)
end
-- 效果处理：如果该怪兽与此效果有关联，则将其特殊召唤到其原本控制者的场上
function c80987696.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以其原本的表示形式特殊召唤到其原本控制者的场上
		Duel.SpecialSummon(tc,0,tp,tc:GetPreviousControler(),false,false,tc:GetPreviousPosition())
	end
end
