--メタファイズ・ラグナロク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己卡组上面把3张卡除外。这张卡的攻击力上升这个效果除外的「玄化」卡数量×300。
-- ②：这张卡给与对方战斗伤害时才能发动。从卡组把1只5星以上的「玄化」怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
function c19476824.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己卡组上面把3张卡除外。这张卡的攻击力上升这个效果除外的「玄化」卡数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19476824,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,19476824)
	e1:SetTarget(c19476824.rmtg)
	e1:SetOperation(c19476824.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡给与对方战斗伤害时才能发动。从卡组把1只5星以上的「玄化」怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19476824,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCountLimit(1,19476825)
	e3:SetCondition(c19476824.spcon)
	e3:SetTarget(c19476824.sptg)
	e3:SetOperation(c19476824.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动阶段（目标判定）：从自己卡组上方取3张卡，若这3张都能被除外，则允许发动，并将这3张卡登记为本次除外操作的对象。
function c19476824.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组最上方的3张卡，存入本地变量rg，作为准备除外的候选卡。
	local rg=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return rg:FilterCount(Card.IsAbleToRemove,nil)==3 end
	-- 设置当前连锁的除外操作信息：指定将刚才获取的rg这3张卡以除外处理，数量为3，持有者为tp，原位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,3,0,0)
end
-- ①效果的实际处理：从卡组顶将3张卡表侧除外；若成功除外且本卡仍表侧表示且与本效果保持关联，则统计实际除外的「玄化」卡数量，并让本卡攻击力上升该数量×300。
function c19476824.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时重新从卡组顶获取3张卡，防止卡组顺序在发动后发生变化导致误处理。
	local g=Duel.GetDecktopGroup(tp,3)
	if #g<=0 then return end
	-- 关闭接下来一次操作的洗切检测，因为从卡组顶除外卡片不需要洗切卡组。
	Duel.DisableShuffleCheck()
	-- 将3张卡以表侧表示除外（原因为效果），返回值不为0代表有卡被成功除外；同时确认本卡仍表侧表示且与当前效果链相关联。
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0
		and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 获取刚才实际被除外的卡组，用于后续统计其中包含了多少张「玄化」卡。
		local og=Duel.GetOperatedGroup()
		local oc=og:FilterCount(Card.IsSetCard,nil,0x105)
		if oc==0 then return end
		-- 这张卡的攻击力上升这个效果除外的「玄化」卡数量×300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(oc*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：受到战斗伤害的玩家不是本卡持有者，即本卡给对方造成了战斗伤害。
function c19476824.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 定义特殊召唤候选怪兽的过滤条件：必须是「玄化」卡、等级5以上，并且能够被效果特殊召唤。
function c19476824.spfilter(c,e,tp)
	return c:IsSetCard(0x105) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件检查：自己怪兽区有空位，且卡组中存在至少1只满足条件的「玄化」怪兽，满足则允许发动。
function c19476824.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己场上主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在1只符合特殊召唤条件的「玄化」怪兽。
		and Duel.IsExistingMatchingCard(c19476824.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的特殊召唤操作信息：从卡组特殊召唤1只怪兽，数量为1，持有者为tp，预取位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：如果自己场上仍有空格，则从卡组中选择1只符合条件的「玄化」怪兽特殊召唤；若特殊召唤成功，为其设置标记，并注册一个在下一回合结束阶段将其除外的持续效果。
function c19476824.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己的主要怪兽区有空位，若没有则特殊召唤失败。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向玩家显示选择框提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中筛选出满足条件的「玄化」怪兽，由玩家选择1只，并取第一张作为待特殊召唤对象。
	local tc=Duel.SelectMatchingCard(tp,c19476824.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	-- 若成功选择了怪兽并把它以表侧表示特殊召唤到自己场上，则进入后续的除外跟踪处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:RegisterFlagEffect(19476824,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 记录触发除外的目标回合：当前回合数+1，即下一个回合的结束阶段。
		e2:SetLabel(Duel.GetTurnCount()+1)
		e2:SetLabelObject(tc)
		e2:SetCondition(c19476824.descon)
		e2:SetOperation(c19476824.desop)
		-- 将跟踪除外的持续效果注册到当前决斗中，由tp方控制，使该效果在满足条件时自动处理。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判断是否到了除外时机：若该怪兽仍带有特殊召唤标记，则比较当前回合是否达到了预设的下一个回合；若标记已不存在（例如怪兽离场），则失效并移除该跟踪效果。
function c19476824.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(19476824)~=0 then
		-- 判定当前回合数是否等于预设的下一回合数，是则返回true，触发除外。
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 实际执行除外：取出被跟踪的怪兽，将其表侧表示除外（原因为效果）。
function c19476824.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将指定的怪兽卡以表侧表示除外，完成效果中‘下个回合的结束阶段除外’的处理。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
