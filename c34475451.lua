--工作列車シグナル・レッド
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤，那只对方怪兽的攻击对象转移为这张卡进行伤害计算。这张卡不会被那次战斗破坏。
function c34475451.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤，那只对方怪兽的攻击对象转移为这张卡进行伤害计算。这张卡不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34475451,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c34475451.condition)
	e1:SetTarget(c34475451.target)
	e1:SetOperation(c34475451.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：检查攻击宣言的怪兽是否由对方控制，只有对方怪兽进行攻击宣言时本效果才满足发动条件。
function c34475451.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击宣言的怪兽，若其控制者不是本效果发动者（即攻击者为对方怪兽），则条件成立。
	return Duel.GetAttacker():GetControler()~=tp
end
-- 效果发动时的合法检查：确认这张卡在手牌且满足特殊召唤条件，同时自己主要怪兽区有空位；chk==0时进行发动合法性判定。
function c34475451.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动判定时，检查自己场上主要怪兽区是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次效果的操作信息：将进行这张卡的1次特殊召唤，以供连锁判定和时点提示；targets设为自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，先将其表侧表示特殊召唤；成功后取得攻击怪兽，若其仍可攻击且不免疫本效果，则给这张卡附加不会被这次战斗破坏的效果，并让其与攻击怪兽进行伤害计算（即攻击对象转移）。
function c34475451.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联且已经成功被特殊召唤（若召唤失败则中断处理）；然后进入后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 取得当前攻击宣言的怪兽，作为将被转移攻击的对象（攻击方）。
		local a=Duel.GetAttacker()
		if a:IsAttackable() and not a:IsImmuneToEffect(e) then
			-- 这张卡不会被那次战斗破坏。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
			c:RegisterEffect(e1)
			-- 使攻击怪兽a与这张卡c进行伤害计算，从而将攻击对象转移为这张卡并进行战斗伤害计算。
			Duel.CalculateDamage(a,c)
		end
	end
end
