--スカーレッド・スーパーノヴァ・ドラゴン
-- 效果：
-- 调整3只＋调整以外的同调怪兽1只以上
-- 这张卡用同调召唤才能从额外卡组特殊召唤。
-- ①：这张卡的攻击力上升自己墓地的调整数量×500。
-- ②：场上的这张卡不会被对方的效果破坏。
-- ③：1回合1次，对方把怪兽的效果发动时或者对方怪兽的攻击宣言时才能发动。这张卡以及对方场上的卡全部除外。
-- ④：这张卡的③的效果除外的场合，下次的自己结束阶段发动。除外状态的这张卡特殊召唤。
function c99585850.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要3只调整为素材，再加上“调整以外的同调怪兽”1只以上（1~99只）作为素材。
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),aux.Tuner(nil),aux.Tuner(nil),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1,99)
	c:EnableReviveLimit()
	-- 这张卡用同调召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	-- 将特殊召唤条件设置为只能通过同调召唤才能特殊召唤（aux.synlimit判定）。
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升自己墓地的调整数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c99585850.atkval)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	-- 设置该卡不会被对方的效果破坏（aux.indoval判定）。
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ③：1回合1次，对方把怪兽的效果发动时或者对方怪兽的攻击宣言时才能发动。这张卡以及对方场上的卡全部除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(99585850,0))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCondition(c99585850.rmcon1)
	e4:SetTarget(c99585850.rmtg)
	e4:SetOperation(c99585850.rmop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetCondition(c99585850.rmcon2)
	c:RegisterEffect(e5)
	-- ④：这张卡的③的效果除外的场合，下次的自己结束阶段发动。除外状态的这张卡特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(99585850,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetRange(LOCATION_REMOVED)
	e6:SetCountLimit(1)
	e6:SetCondition(c99585850.spcon)
	e6:SetTarget(c99585850.sptg)
	e6:SetOperation(c99585850.spop)
	c:RegisterEffect(e6)
	e4:SetLabelObject(e6)
	e5:SetLabelObject(e6)
	-- 这张卡用同调召唤才能从额外卡组特殊召唤。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e7:SetCode(21142671)
	c:RegisterEffect(e7)
end
c99585850.material_type=TYPE_SYNCHRO
-- 攻击力提升值的计算函数：统计这张卡的控制者自己墓地的调整怪兽数量，每个调整怪兽提供500攻击力。
function c99585850.atkval(e,c)
	-- 返回自己墓地的调整怪兽数量乘以500，作为攻击力上升值。
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_TUNER)*500
end
-- ③效果的发动条件（对方发动效果时）：效果发动玩家是对方，且发动的是怪兽效果。
function c99585850.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- ③效果的发动条件（攻击宣言时）：攻击宣言的怪兽由对方控制。
function c99585850.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击宣言的怪兽是否由对方玩家控制。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- ③效果发动时选择要除外的卡：对方场上的所有卡以及自身（若自身可以被除外），并写入除外操作信息。
function c99585850.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 取得对方场上所有可以被除外的卡（怪兽·魔法·陷阱）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	if c:IsAbleToRemove() then g:AddCard(c) end
	if chk==0 then return g:GetCount()>0 end
	-- 设置本次效果处理为除外操作，对象为上述选中的卡组，数量为其中卡片数量。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- ③效果处理：再次获取对方场上可除外的卡，若自身仍可除外也加入，然后全部表侧除外；若自身被除外，则根据当前时机记录④效果的复活信息。
function c99585850.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，重新获取对方场上所有可以被除外的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	if c:IsAbleToRemove() and c:IsRelateToEffect(e) then g:AddCard(c) end
	-- 将选中的卡表侧表示除外，若实际除外了卡片则进入后续处理。
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 获取本次除外操作实际除外掉的卡片组，用于检查这张卡是否在内。
		local op=Duel.GetOperatedGroup()
		if op:IsContains(c) then
			local owner_player=c:GetOwner()
			local reset_flag=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
			if owner_player==tp then
				reset_flag=reset_flag+RESET_SELF_TURN
			else
				reset_flag=reset_flag+RESET_OPPO_TURN
			end
			-- 判断当前是否是这张卡持有者的结束阶段（影响④效果所在的“下次自己结束阶段”的判定）。
			if Duel.GetTurnPlayer()==owner_player and Duel.GetCurrentPhase()==PHASE_END then
				-- 将④效果的标记值设为当前回合数，用于和下次自己结束阶段的回合数比较。
				e:GetLabelObject():SetLabel(Duel.GetTurnCount())
				c:RegisterFlagEffect(99585850,reset_flag,0,2)
			else
				e:GetLabelObject():SetLabel(0)
				c:RegisterFlagEffect(99585850,reset_flag,0,1)
			end
		end
	end
end
-- ④效果的发动条件：在自己的结束阶段，当前回合数不等于记录的标记值（不是被除外的那个结束阶段），且该卡带有③除外标记。
function c99585850.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 满足④发动条件：回合玩家为这张卡的所有者、当前回合数不同于记录的回合数（确保是“下次”）、且存在③的除外标记。
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetLabel() and e:GetHandler():GetFlagEffect(99585850)~=0
end
-- ④效果发动时无取对象，直接为特殊召唤设置操作信息。
function c99585850.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将这张卡作为特殊召唤的对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ④效果处理：若这张卡仍在除外状态且与效果相关，则将其特殊召唤。
function c99585850.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以无特殊召唤类型、由持有者tp将其特殊召唤到持有者场上，攻击表示，并进行召唤条件/苏生限制检查。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
