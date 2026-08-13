--ヤジロベーダー
-- 效果：
-- ①：这张卡往中央以外的主要怪兽区域召唤·特殊召唤的场合破坏。
-- ②：1回合1次，自己主要阶段才能发动。这张卡向相邻的没有使用的主要怪兽区域移动。
-- ③：每次对方场上只有怪兽1只召唤·特殊召唤发动。那只对方怪兽的位置是和这张卡不同纵列的场合，这张卡向要往那只对方怪兽靠近的相邻的主要怪兽区域移动。那之后，和移动过的这张卡相同纵列的其他卡全部破坏。
function c10852583.initial_effect(c)
	-- ①：这张卡往中央以外的主要怪兽区域召唤·特殊召唤的场合破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c10852583.descon)
	e1:SetOperation(c10852583.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。这张卡向相邻的没有使用的主要怪兽区域移动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10852583,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c10852583.seqcon)
	e3:SetOperation(c10852583.seqop)
	c:RegisterEffect(e3)
	-- ③：每次对方场上只有怪兽1只召唤·特殊召唤发动。那只对方怪兽的位置是和这张卡不同纵列的场合，这张卡向要往那只对方怪兽靠近的相邻的主要怪兽区域移动。那之后，和移动过的这张卡相同纵列的其他卡全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(10852583,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c10852583.mvcon)
	e4:SetTarget(c10852583.mvtg)
	e4:SetOperation(c10852583.mvop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 效果①的诱发条件：此卡所在位置的序号不是中央格（序号2），即位于中央以外时，触发破坏。
function c10852583.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSequence()~=2
end
-- 效果①的破坏操作：将这张卡破坏，破坏原因为效果。
function c10852583.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡以效果破坏，执行①的自毁处理。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- ②效果的发动条件：此卡位于主要怪兽区域（序号0-4），且其左侧或右侧至少有一个相邻的主要怪兽区域空格可用。
function c10852583.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	if seq>4 then return false end
	-- 检查此卡左侧相邻的主要怪兽区域格子是否为空闲（seq>0 且该位置可用）。
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 检查此卡右侧相邻的主要怪兽区域格子是否为空闲（seq<4 且该位置可用）；与左侧检查共同构成“相邻空格可用”的发动条件。
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- ②效果处理：确认此卡仍可处理且控制权未变后，若存在相邻空格，则让玩家选择要移动到的相邻格子，并计算目标格子序号。
function c10852583.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	local seq=c:GetSequence()
	if seq>4 then return end
	-- 若此卡不在最左端且左邻格可用，则将左侧格作为可移动的候选。
	if (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 若此卡不在最右端且右邻格可用，则将右侧格作为可移动的候选；左右任一可用即可继续。
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1)) then
		local flag=0
		-- 在可选位置标记flag中启用左侧空格，使其成为玩家可选的移动目标。
		if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=bit.replace(flag,0x1,seq-1) end
		-- 在可选位置标记flag中启用右侧空格，使其成为玩家可选的移动目标。
		if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=bit.replace(flag,0x1,seq+1) end
		flag=bit.bxor(flag,0xff)
		-- 向玩家发送“请选择要移动到的位置”的提示，用于选择移动目标格子。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
		-- 让玩家从可用格子中选择1个位置，返回该位置的标记（s），用于确定目标序号。
		local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,flag)
		local nseq=0
		if s==1 then nseq=0
		elseif s==2 then nseq=1
		elseif s==4 then nseq=2
		elseif s==8 then nseq=3
		else nseq=4 end
		-- 将这张卡移动到所选的目标主要怪兽区域格子，完成②的移动效果。
		Duel.MoveSequence(c,nseq)
	end
end
-- ③效果的诱发条件：对方召唤/特殊召唤成功时，这次召唤/特殊召唤的怪兽只有1只且控制者为对方。
function c10852583.mvcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:GetFirst():IsControler(1-tp)
end
-- ③效果发动时，将对方那只召唤/特殊召唤成功的怪兽与效果建立联系，以便效果处理时确认其仍是有效对象。
function c10852583.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=eg:GetFirst()
	tc:CreateEffectRelation(e)
end
-- ③效果处理开始时的校验：若此卡或对方怪兽已与效果失去联系，或此卡不在自己场上/对方怪兽不在对方场上，则中止处理。
function c10852583.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp)
		or not tc:IsRelateToEffect(e) or tc:IsControler(tp) then return end
	local seq1=c:GetSequence()
	local seq2=tc:GetSequence()
	if seq1>4 then return end
	if seq2==5 then seq2=1 end
	if seq2==6 then seq2=3 end
	seq2=4-seq2
	-- 若此卡纵列位于对方怪兽纵列的右侧，且此卡左侧相邻主要怪兽区域空格可用，则满足向对方靠近一格的条件。
	if (seq1>seq2 and Duel.CheckLocation(tp,LOCATION_MZONE,seq1-1))
		-- 若此卡纵列位于对方怪兽纵列的左侧，且此卡右侧相邻主要怪兽区域空格可用，则满足向对方靠近一格的条件。
		or (seq1<seq2 and Duel.CheckLocation(tp,LOCATION_MZONE,seq1+1)) then
		local nseq=0
		-- 若满足向左移动的条件，则将目标移动位置设为此卡左侧相邻格子（seq1-1）。
		if seq1>seq2 and Duel.CheckLocation(tp,LOCATION_MZONE,seq1-1) then nseq=seq1-1
		else nseq=seq1+1 end
		-- 将这张卡移动到目标格子，实现向那只对方怪兽靠近的移动。
		Duel.MoveSequence(c,nseq)
		local g=c:GetColumnGroup()
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续破坏与之前的移动错开时点，对应“那之后”的先后顺序。
			Duel.BreakEffect()
			-- 将移动后的这张卡同一纵列的其他卡全部破坏，即③中“相同纵列的其他卡全部破坏”的处理。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
