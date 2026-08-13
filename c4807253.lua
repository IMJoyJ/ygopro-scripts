--Emフレイム・イーター
-- 效果：
-- ①：给与自己伤害的魔法·陷阱·怪兽的效果发动时才能发动。这张卡从手卡特殊召唤，那个效果让自己受到的伤害变成0。这个回合，自己不是「娱乐法师」怪兽不能特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡召唤·特殊召唤成功的场合发动。双方玩家受到500伤害。
function c4807253.initial_effect(c)
	-- ①：给与自己伤害的魔法·陷阱·怪兽的效果发动时才能发动。这张卡从手卡特殊召唤，那个效果让自己受到的伤害变成0。这个回合，自己不是「娱乐法师」怪兽不能特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	-- 设置e1的发动条件：当自己将要受到魔法·陷阱·怪兽效果的伤害时（aux.damcon1）才能发动。
	e1:SetCondition(aux.damcon1)
	e1:SetTarget(c4807253.sptg)
	e1:SetOperation(c4807253.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合发动。双方玩家受到500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTarget(c4807253.damtg)
	e2:SetOperation(c4807253.damop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 效果①的发动时点判定：检查自己场上是否有可用的主要怪兽格，且这张卡是否能被效果特殊召唤，满足则允许发动。
function c4807253.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动时（chk==0）确认自己主要怪兽区存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明效果将特殊召唤这张卡（不取对象），用于连锁处理时的时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理：若这张卡仍与效果关联，则将其特殊召唤；成功后对触发连锁的伤害适用变成0，并给这张卡附加离场除外；最后设置本回合自己只能特殊召唤「娱乐法师」怪兽的自肃效果。
function c4807253.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍然与效果关联，若关联则将其以表侧表示特殊召唤到自己场上，且特殊召唤成功时才继续后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取触发效果发动的那个连锁的ID（cid），用于识别哪一个连锁的伤害需要被变成0。
		local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
		-- 那个效果让自己受到的伤害变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(cid)
		e1:SetValue(c4807253.damval)
		e1:SetReset(RESET_CHAIN)
		-- 将“该连锁造成的对自己伤害变成0”的效果注册到场上，持续到当前连锁处理结束，且只影响己方玩家。
		Duel.RegisterEffect(e1,tp)
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
	end
	-- 这个回合，自己不是「娱乐法师」怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c4807253.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将“本回合不能特殊召唤非「娱乐法师」怪兽”的自肃效果注册到场上，持续到回合结束，只影响己方。
	Duel.RegisterEffect(e3,tp)
end
-- 伤害变更函数：若当前正在处理的连锁与之前记录的连锁ID一致，并且伤害来源为效果，则将该伤害改为0；否则保持原伤害。
function c4807253.damval(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号，用于判断是否处于连锁处理中及后续比对连锁ID。
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return val end
	-- 获取当前正在处理的连锁的ID，与效果保存的目标连锁ID进行比较。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return val end
	return 0
end
-- 自肃判定函数：若被特殊召唤的怪兽不是「娱乐法师」系列（0xc6），则禁止特殊召唤。
function c4807253.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xc6)
end
-- 效果②发动时处理：必定发动，设置效果信息为给双方玩家各500点伤害。
function c4807253.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：该效果将给双方玩家各500点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,500)
end
-- 效果②处理：依次给对方和自己造成500点效果伤害，并完成伤害处理时点。
function c4807253.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给对手造成500点效果伤害（采用分解伤害步骤）。
	Duel.Damage(1-tp,500,REASON_EFFECT,true)
	-- 给自己造成500点效果伤害（采用分解伤害步骤）。
	Duel.Damage(tp,500,REASON_EFFECT,true)
	-- 完成伤害/回复处理，触发“受到伤害”等时点。
	Duel.RDComplete()
end
