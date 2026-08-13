--選律のヴァルモニカ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「异响鸣」怪兽卡存在的场合，从以下效果选1个适用。自己场上有「异响鸣」连接怪兽存在的场合，可以选两方适用。
-- ●自己回复500基本分。这个回合中，对方不能把自己场上的「异响鸣」怪兽卡作为效果的对象。
-- ●自己受到500伤害。那之后，可以把对方场上1只效果怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 创建并注册该卡的发动效果：对应对手主要阶段可发动的魔法卡效果，设置其描述、类别、类型、发动时点、1回合1次限制、发动条件和处理函数。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「异响鸣」怪兽卡存在的场合，从以下效果选1个适用。自己场上有「异响鸣」连接怪兽存在的场合，可以选两方适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：表侧表示且卡名含「异响鸣」字段，并且原本种类为怪兽卡（用于判断是否存在「异响鸣」怪兽）。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a3) and c:GetOriginalType()&TYPE_MONSTER>0
end
-- 发动条件：自己场上有1张以上满足s.cfilter的「异响鸣」怪兽卡存在。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以tp视角的自己场上（怪兽区+魔陷区）是否存在至少1张满足s.cfilter的「异响鸣」怪兽卡。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 筛选条件：表侧表示且卡名含「异响鸣」字段，并且是连接怪兽（用于判断能否选择两方适用）。
function s.afilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a3) and c:IsType(TYPE_LINK)
end
-- 效果处理：根据op值依次处理所选选项。若选择回复则回复500并赋予己方「异响鸣」怪兽不受对方效果对象的保护；若选择伤害则自己受到500伤害，并可选择将对方场上1只效果怪兽的效果无效。若选择两方适用则两个效果均处理，并用BreakEffect使其错开时点。
function s.activate(e,tp,eg,ep,ev,re,r,rp,op)
	if op==nil and not s.condition(e,tp) then return end
	local c=e:GetHandler()
	if op==nil then
		-- 检查自己场上是否存在表侧表示的「异响鸣」连接怪兽，作为能否选择“选两方适用”的依据。
		local chk=Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_MZONE,0,1,nil)
		-- 从三个选项中选择要适用的效果：选项1为回复500，选项2为受到500伤害，选项3为（存在连接怪兽时）两方适用。
		op=aux.SelectFromOptions(tp,
			{true,aux.Stringid(id,1)},  --"自己回复500基本分"
			{true,aux.Stringid(id,2)},  --"自己受到500伤害"
			{chk,aux.Stringid(id,3)})  --"选两方适用"
	end
	-- 若op包含回复项（bit0）且回复500LP成功，则执行回复并进入后续保护效果的处理。
	if op&1>0 and Duel.Recover(tp,500,REASON_EFFECT)>0 then
		-- ●自己回复500基本分。这个回合中，对方不能把自己场上的「异响鸣」怪兽卡作为效果的对象。●自己受到500伤害。那之后，可以把对方场上1只效果怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetTargetRange(LOCATION_ONFIELD,0)
		e1:SetTarget(s.target)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 设置该保护效果的Value函数：只有效果持有者（己方）的对手发动效果时，才会使其成为“不能成为效果对象”的对象。
		e1:SetValue(aux.tgoval)
		-- 将“己方场上的「异响鸣」怪兽卡不会成为对方效果的对象”的永续效果注册，持续到结束阶段。
		Duel.RegisterEffect(e1,tp)
		-- 若选择了“两方适用”（op==3），则在回复效果结算后中断连锁，使后续伤害/无效处理作为另一个时点处理，避免回复与伤害合并为同一时点。
		if op==3 then Duel.BreakEffect() end
	end
	-- 若op包含伤害项（bit1）且自己受到500伤害成功，则继续处理后续无效效果。
	if op&2>0 and Duel.Damage(tp,500,REASON_EFFECT)>0 then
		-- 获取对方场上所有满足aux.NegateEffectMonsterFilter的怪兽：表侧表示、未被无效的效果怪兽，作为可选无效对象。
		local g=Duel.GetMatchingGroup(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,nil)
		-- 存在可选对象时，询问玩家是否选择将对方1只怪兽的效果无效。
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否把对方1只怪兽的效果无效？"
			-- 显示选择提示，让玩家从可选怪兽中选择1只要无效的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 给选中的卡显示对象选择动画，并将其记录为本连锁的对象。
			Duel.HintSelection(sg)
			local tc=sg:GetFirst()
			-- 在伤害处理完成后中断效果处理，使无效效果错开时点再处理。
			Duel.BreakEffect()
			-- 将与所选怪兽相关的连锁效果无效化，并在该卡变里侧表示时重置。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 那之后，可以把对方场上1只效果怪兽的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
		end
	end
end
-- 保护效果的筛选函数：卡名含「异响鸣」字段且原本种类为怪兽卡的卡，才会受到“不能成为效果对象”的保护。
function s.target(e,c)
	return c:IsSetCard(0x1a3) and c:GetOriginalType()&TYPE_MONSTER>0
end
