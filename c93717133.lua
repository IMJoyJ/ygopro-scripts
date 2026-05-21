--銀河眼の光子竜
-- 效果：
-- ①：这张卡可以把自己场上2只攻击力2000以上的怪兽解放从手卡特殊召唤。
-- ②：这张卡和对方怪兽进行战斗的战斗步骤，以那1只对方怪兽为对象才能发动。那只对方怪兽和场上的这张卡除外。这个效果除外的怪兽在战斗阶段结束时回到场上，这个效果把超量怪兽除外的场合，这张卡的攻击力上升把那只超量怪兽除外时的超量素材数量×500。
function c93717133.initial_effect(c)
	-- ①：这张卡可以把自己场上2只攻击力2000以上的怪兽解放从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c93717133.spcon)
	e1:SetTarget(c93717133.sptg)
	e1:SetOperation(c93717133.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的战斗步骤，以那1只对方怪兽为对象才能发动。那只对方怪兽和场上的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93717133,0))  --"对方怪兽和这张卡从游戏中除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(TIMING_BATTLE_PHASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c93717133.rmcon)
	e2:SetTarget(c93717133.rmtg)
	e2:SetOperation(c93717133.rmop)
	c:RegisterEffect(e2)
end
-- 过滤场上攻击力2000以上的怪兽
function c93717133.rfilter(c,tp)
	return c:IsAttackAbove(2000) and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的Condition函数：检查场上是否存在可解放的2只攻击力2000以上的怪兽
function c93717133.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上可解放的且攻击力在2000以上的怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c93717133.rfilter,nil,tp)
	-- 检查是否能选出2只满足解放条件且解放后能腾出足够怪兽区域的怪兽
	return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp,REASON_SPSUMMON)
end
-- 特殊召唤规则的Target函数：选择要解放的怪兽
function c93717133.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可解放的且攻击力在2000以上的怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c93717133.rfilter,nil,tp)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择2只满足解放条件且解放后能腾出足够怪兽区域的怪兽
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,true,2,2,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的Operation函数：执行解放并特殊召唤
function c93717133.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选定的怪兽
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
	c:RegisterFlagEffect(0,RESET_EVENT+0x4fc0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(93717133,1))  --"出场方式为特殊召唤"
end
-- 除外效果的Condition函数：限制在战斗阶段且自身未在连锁中
function c93717133.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否处于战斗阶段，且这张卡没有在连锁处理中
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
-- 除外效果的Target函数：确认战斗对象并进行取对象和除外可行性检测
function c93717133.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() and bc:IsCanBeEffectTarget(e)
		and c:IsAbleToRemove() and bc:IsAbleToRemove() end
	-- 将对方战斗怪兽设为效果处理的对象
	Duel.SetTargetCard(bc)
	local g=Group.FromCards(c,bc)
	-- 设置效果处理信息：除外场上的这张卡和对方怪兽共2张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
-- 除外效果的Operation函数：执行除外并在战斗阶段结束时注册回到场上及加攻的效果
function c93717133.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时的对象怪兽（即对方战斗怪兽）
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or tc:IsControler(tp) then return end
	local g=Group.FromCards(c,tc)
	local mcount=0
	if tc:IsFaceup() then mcount=tc:GetOverlayCount() end
	-- 如果成功将自身和对方怪兽暂时除外
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 获取实际被除外的卡片组
		local og=Duel.GetOperatedGroup()
		if not og:IsContains(tc) then mcount=0 end
		local oc=og:GetFirst()
		while oc do
			oc:RegisterFlagEffect(93717133,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			oc=og:GetNext()
		end
		og:KeepAlive()
		-- 这个效果除外的怪兽在战斗阶段结束时回到场上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		e1:SetLabel(mcount)
		e1:SetCountLimit(1)
		e1:SetLabelObject(og)
		e1:SetOperation(c93717133.retop)
		-- 注册在战斗阶段结束时触发的全局时点效果，用于将除外的怪兽返回场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤出带有本效果特定标记的卡片
function c93717133.retfilter(c)
	return c:GetFlagEffect(93717133)~=0
end
-- 战斗阶段结束时，将除外的怪兽返回场上，并根据除外的超量怪兽素材数量给自身增加攻击力
function c93717133.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(c93717133.retfilter,nil)
	g:DeleteGroup()
	local tc=sg:GetFirst()
	while tc do
		-- 如果自身成功返回场上且呈表侧表示，并且被除外的对方怪兽是拥有超量素材的超量怪兽
		if Duel.ReturnToField(tc) and tc==e:GetOwner() and tc:IsFaceup() and e:GetLabel()~=0 then
			-- 这个效果把超量怪兽除外的场合，这张卡的攻击力上升把那只超量怪兽除外时的超量素材数量×500。
			local e1=Effect.CreateEffect(e:GetOwner())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			e1:SetValue(e:GetLabel()*500)
			e:GetOwner():RegisterEffect(e1)
		end
		tc=sg:GetNext()
	end
end
