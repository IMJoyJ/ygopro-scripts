--凍てつく呪いの神碑
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。这张卡的发动后，下次的自己战斗阶段跳过。
-- ●以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。那之后，从对方卡组上面把3张卡除外。
-- ●从额外卡组把1只「神碑」怪兽在额外怪兽区域特殊召唤。
local s,id,o=GetID()
-- 创建两个连锁效果，分别对应两种发动效果。
function s.initial_effect(c)
	-- 效果①的第一个效果：以对方场上1只效果怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"怪兽无效"
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 效果①的第二个效果：从额外卡组把1只「神碑」怪兽在额外怪兽区域特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 设置效果①的第一个效果的发动条件和目标选择。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 设置效果①的第一个效果的目标筛选条件。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 判断是否满足效果①的第一个效果的发动条件。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
		-- 判断对方卡组顶部是否有3张可除外的卡。
		and Duel.GetDecktopGroup(1-tp,3):FilterCount(Card.IsAbleToRemove,nil)==3 end
	-- 提示对方玩家选择了效果①的第一个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要无效的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上的1只效果怪兽作为目标。
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果①的第一个效果的后续处理信息。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,1-tp,LOCATION_DECK)
end
-- 处理效果①的第一个效果的发动效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标怪兽相关的连锁无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 获取对方卡组顶部的3张卡。
		local g=Duel.GetDecktopGroup(1-tp,3)
		if #g>0 then
			-- 中断当前效果处理。
			Duel.BreakEffect()
			-- 禁止接下来的除外操作进行洗切卡组检查。
			Duel.DisableShuffleCheck()
			-- 将对方卡组顶部的3张卡除外。
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
	s.skipop(e,tp)
end
-- 设置特殊召唤「神碑」怪兽的筛选条件。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x17f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断是否有足够的额外怪兽区域进行特殊召唤。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)>0
end
-- 设置效果①的第二个效果的发动条件和处理信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果①的第二个效果的发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 提示对方玩家选择了效果①的第二个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果①的第二个效果的后续处理信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果①的第二个效果的发动效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一只符合条件的「神碑」怪兽进行特殊召唤。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)
	end
	s.skipop(e,tp)
end
-- 设置发动后跳过下次自己战斗阶段的效果。
function s.skipop(e,tp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 获取当前游戏阶段。
		local ph=Duel.GetCurrentPhase()
		-- 创建跳过战斗阶段的效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		-- 判断是否在自己的主要阶段1到主要阶段2之间。
		if Duel.GetTurnPlayer()==tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2 then
			-- 记录当前回合数用于条件判断。
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(s.skipcon)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
		end
		-- 注册跳过战斗阶段的效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 跳过战斗阶段效果的条件函数。
function s.skipcon(e)
	-- 判断当前回合数是否与记录的回合数不同。
	return Duel.GetTurnCount()~=e:GetLabel()
end
