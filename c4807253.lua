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
	-- 判断是否满足效果发动条件：给与自己伤害的魔法·陷阱·怪兽的效果发动时
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
-- 检查特殊召唤的条件：场上是否有空位且此卡可以被特殊召唤
function c4807253.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有空位可用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理特殊召唤效果：将此卡从手牌特殊召唤到场上，并设置相关效果
function c4807253.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡是否还在场上且成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前连锁的ID
		local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
		-- 创建一个影响伤害数值的效果，使特定连锁造成的伤害变为0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(cid)
		e1:SetValue(c4807253.damval)
		e1:SetReset(RESET_CHAIN)
		-- 将该效果注册给玩家
		Duel.RegisterEffect(e1,tp)
		-- 创建一个使此卡离开场时被移除的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
	end
	-- 创建一个限制本回合不能特殊召唤非娱乐法师怪兽的效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c4807253.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册给玩家
	Duel.RegisterEffect(e3,tp)
end
-- 判断是否为当前处理的连锁且为效果伤害，若是则将伤害设为0
function c4807253.damval(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return val end
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return val end
	return 0
end
-- 限制非娱乐法师怪兽在本回合不能特殊召唤
function c4807253.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xc6)
end
-- 设置伤害效果的目标：双方玩家各受到500点伤害
function c4807253.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：造成500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,500)
end
-- 执行伤害效果：给双方玩家各造成500点伤害
function c4807253.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给对方玩家造成500点伤害
	Duel.Damage(1-tp,500,REASON_EFFECT,true)
	-- 给自己玩家造成500点伤害
	Duel.Damage(tp,500,REASON_EFFECT,true)
	-- 完成伤害处理流程
	Duel.RDComplete()
end
