--星墜つる地に立つ閃珖
-- 效果：
-- 「立于星坠之地的闪珖」在1回合只能发动1张。
-- ①：特殊召唤的对方怪兽的直接攻击宣言时，那只怪兽的攻击力是自己基本分以上的场合才能发动。那次攻击无效，自己从卡组抽1张。那之后，可以从自己的额外卡组·墓地选1只「星尘」怪兽特殊召唤。
function c20590784.initial_effect(c)
	-- 「立于星坠之地的闪珖」在1回合只能发动1张。①：特殊召唤的对方怪兽的直接攻击宣言时，那只怪兽的攻击力是自己基本分以上的场合才能发动。那次攻击无效，自己从卡组抽1张。那之后，可以从自己的额外卡组·墓地选1只「星尘」怪兽特殊召唤。
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
-- 效果发动条件：对方怪兽进行了直接攻击宣言（攻击目标为空），且该攻击怪兽的控制者是对方，效果才能发动。
function c20590784.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前宣告攻击的怪兽，作为后续条件判断的对象。
	local at=Duel.GetAttacker()
	-- 判断攻击怪兽是对方控制的怪兽，并且当前攻击是直接攻击（没有攻击对象）。
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果发动时的合法性检查：确认能够抽1张卡，且攻击怪兽仍在场上、其攻击力不低于自己的基本分，并且该怪兽是以特殊召唤方式出场的怪兽。
function c20590784.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击宣言的怪兽，用于后续的攻击力/召唤方式判定。
	local at=Duel.GetAttacker()
	-- 效果发动合法性检查（chk==0）时，首先确认自己可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 同时确认攻击怪兽仍在场上，并且其当前攻击力在自己的基本分以上（满足『攻击力是自己基本分以上』的发动条件）。
		and at:IsOnField() and at:GetAttack()>=Duel.GetLP(tp)
		and at:IsSummonType(SUMMON_TYPE_SPECIAL) end
end
-- 定义可特殊召唤的「星尘」怪兽筛选条件：属于「星尘」字段、可以被效果特殊召唤，并且根据其所在位置（墓地或额外卡组）确认存在可用的怪兽区域。
function c20590784.filter(c,e,tp)
	return c:IsSetCard(0xa3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若候选卡在墓地，则要求自己场上有可用的怪兽区域空位，之后才能将其从墓地特殊召唤。
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 若候选卡在额外卡组，则要求场上存在可供从额外卡组特殊召唤的怪兽区域空位（例如额外怪兽区或条件允许的主怪兽区）。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果处理：先无效攻击并抽1张卡，若成功且存在符合条件的「星尘」怪兽，则询问玩家是否进行后续的特殊召唤；玩家选择是后，从中选1只表侧表示特殊召唤。
function c20590784.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 先无效那次攻击，若无效成功，则自己因效果抽1张卡，并确认确实抽出1张后才进行后续处理。
	if Duel.NegateAttack() and Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		-- 从自己的墓地·额外卡组中收集满足条件的「星尘」怪兽，并通过aux.NecroValleyFilter排除会受到王家长眠之谷效果影响的卡。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c20590784.filter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e,tp)
		-- 存在可特殊召唤的候选卡，且玩家选择“是”（即选择发动后续特殊召唤效果）时，才进行特殊召唤处理。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(20590784,0)) then  --"是否要特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤与前面的无效攻击/抽卡不在同一时点处理，以正确结算时点。
			Duel.BreakEffect()
			-- 向玩家显示“请选择要特殊召唤的卡”的选择提示，供下一步从候选组中选择1张。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选出的1只「星尘」怪兽以正面表示特殊召唤到自己的场上（会检查特殊召唤条件与苏生限制）。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
