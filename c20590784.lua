--星墜つる地に立つ閃珖
-- 效果：
-- 「立于星坠之地的闪珖」在1回合只能发动1张。
-- ①：特殊召唤的对方怪兽的直接攻击宣言时，那只怪兽的攻击力是自己基本分以上的场合才能发动。那次攻击无效，自己从卡组抽1张。那之后，可以从自己的额外卡组·墓地选1只「星尘」怪兽特殊召唤。
function c20590784.initial_effect(c)
	-- 效果原文内容：「立于星坠之地的闪珖」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,20590784+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c20590784.condition)
	e1:SetTarget(c20590784.target)
	e1:SetOperation(c20590784.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断攻击怪兽是否为对方特殊召唤的怪兽且未被攻击目标
function c20590784.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前攻击的怪兽
	local at=Duel.GetAttacker()
	-- 效果作用：攻击怪兽为对方控制且未攻击其他怪兽
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果原文内容：①：特殊召唤的对方怪兽的直接攻击宣言时，那只怪兽的攻击力是自己基本分以上的场合才能发动。
function c20590784.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：获取当前攻击的怪兽
	local at=Duel.GetAttacker()
	-- 效果作用：检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 效果作用：检查攻击怪兽在场且攻击力大于等于玩家基本分
		and at:IsOnField() and at:GetAttack()>=Duel.GetLP(tp)
		and at:IsSummonType(SUMMON_TYPE_SPECIAL) end
end
-- 效果原文内容：那之后，可以从自己的额外卡组·墓地选1只「星尘」怪兽特殊召唤。
function c20590784.filter(c,e,tp)
	return c:IsSetCard(0xa3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 效果作用：检查怪兽在墓地且场上存在可用怪兽区
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 效果作用：检查怪兽在额外卡组且存在可用额外召唤区
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果作用：无效攻击并抽1张卡，若成功则检索符合条件的星尘怪兽并询问是否特殊召唤
function c20590784.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：无效攻击并抽1张卡，若成功则继续处理后续效果
	if Duel.NegateAttack() and Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		-- 效果作用：检索满足条件的星尘怪兽（包括墓地和额外卡组）
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c20590784.filter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e,tp)
		-- 效果作用：若检索到符合条件的怪兽且玩家选择发动，则继续处理特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(20590784,0)) then  --"是否要特殊召唤？"
			-- 效果作用：中断当前效果处理，防止错时点
			Duel.BreakEffect()
			-- 效果作用：提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 效果作用：将选中的星尘怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
