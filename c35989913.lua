--永遠の絆
-- 效果：
-- 这个卡名在规则上也当作「超量」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从自己墓地把1只「No.39 希望皇 霍普」特殊召唤。那只怪兽的攻击力上升自己墓地的光属性「霍普」超量怪兽的攻击力的合计数值。
-- ②：原本属性是光属性的自己的「霍普」超量怪兽的攻击破坏对方怪兽时才能发动。那只自己怪兽的攻击力下降1000，那只怪兽可以继续攻击。
local s,id,o=GetID()
-- 注册这张卡的两个效果：①包含特殊召唤及相关攻击力变化的发动效果，以及②在光属性「霍普」超量怪兽战斗破坏对方怪兽后发动、下降攻击力并继续攻击的效果。
function s.initial_effect(c)
	-- 将卡号84013237（No.39 希望皇 霍普）登记到这张卡的关联卡名列表中，使这张卡在规则上也被视为记载了该卡名。
	aux.AddCodeList(c,84013237)
	-- ①：作为这张卡的发动时的效果处理，可以从自己墓地把1只「No.39 希望皇 霍普」特殊召唤。那只怪兽的攻击力上升自己墓地的光属性「霍普」超量怪兽的攻击力的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：原本属性是光属性的自己的「霍普」超量怪兽的攻击破坏对方怪兽时才能发动。那只自己怪兽的攻击力下降1000，那只怪兽可以继续攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"继续攻击"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 筛选墓地中卡号为84013237且可以被当前效果特殊召唤的「No.39 希望皇 霍普」。
function s.spfilter(c,e,sp)
	return c:IsCode(84013237) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 筛选自己墓地中卡名含有「霍普」、为超量怪兽且属性为光属性的怪兽。
function s.atkfilter(c)
	return c:IsSetCard(0x7f) and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- ①效果的处理：从自己墓地选择1只「No.39 希望皇 霍普」特殊召唤，并在特殊召唤成功后将其攻击力上升自己墓地所有满足条件的光属性「霍普」超量怪兽攻击力的合计数值。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中满足特殊召唤条件、且不受「王家长眠之谷」效果影响的「No.39 希望皇 霍普」的集合。
	local cg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 判断是否存在符合条件的特殊召唤目标，以及自己场上是否还有可用的怪兽区域。
	if #cg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否发动效果，从墓地特殊召唤「No.39 希望皇 霍普」。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 显示“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=cg:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		-- 将选中的「No.39 希望皇 霍普」以表侧表示特殊召唤；若特殊召唤成功则继续后续的攻击力上升处理。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 检索自己墓地中所有光属性「霍普」超量怪兽，用于计算攻击力的上升数值。
			local ag=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_GRAVE,0,nil)
			local atk=ag:GetSum(Card.GetAttack)
			-- 那只怪兽的攻击力上升自己墓地的光属性「霍普」超量怪兽的攻击力的合计数值。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(atk)
			tc:RegisterEffect(e1)
		end
		-- 完成整个特殊召唤流程，使特殊召唤的怪兽正式上场。
		Duel.SpecialSummonComplete()
	end
end
-- ②效果的发动条件判断：自己原本属性为光属性的「霍普」超量怪兽在攻击对方怪兽并战斗破坏对方怪兽，且自身表侧表示、攻击力在1000以上、未处于预定破坏状态等。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	-- 确认进行战斗破坏的正是当前攻击的怪兽，且该怪兽与对方怪兽进行了战斗、自身处于表侧表示。
	return rc==Duel.GetAttacker() and rc:IsStatus(STATUS_OPPO_BATTLE) and rc:IsFaceup()
		and rc:IsSetCard(0x7f) and rc:IsType(TYPE_XYZ)
		and rc:IsAttackAbove(1000) and rc:IsControler(tp)
		and (rc:GetOriginalAttribute()&ATTRIBUTE_LIGHT)~=0
		and not rc:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- ②效果的处理：将那只攻击怪兽的攻击力下降1000，并在没有攻击力反转效果影响时使其可以继续攻击。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得这次战斗中的攻击怪兽，即那只破坏了对方怪兽的「霍普」怪兽。
	local tc=Duel.GetAttacker()
	if tc:IsFaceup() and tc:IsControler(tp) and tc:IsType(TYPE_MONSTER) then
		-- 那只自己怪兽的攻击力下降1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 让该「霍普」怪兽在本次战斗阶段中可以继续进行下一次攻击。
			Duel.ChainAttack()
		end
	end
end
