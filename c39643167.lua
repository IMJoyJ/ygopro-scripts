--ウサミミ導師
-- 效果：
-- ①：「兔耳导师」以外的场上的怪兽的效果发动时才能发动（同一连锁上最多1次）。给那只怪兽放置1个兔耳指示物。有兔耳指示物放置的怪兽不会被战斗破坏。
-- ②：1回合1次，以有兔耳指示物放置的1只怪兽为对象才能发动。那只怪兽和这张卡直到下个回合的准备阶段除外。这个效果在对方回合也能发动。
local s,id,o=GetID()
-- 初始化这张卡的两个效果：①为场上发动的怪兽效果连锁放置兔耳指示物的诱发即时效果，②为以有兔耳指示物的1只怪兽为对象将其与这张卡暂时除外的诱发即时效果（1回合1次）
function s.initial_effect(c)
	-- ①：「兔耳导师」以外的场上的怪兽的效果发动时才能发动（同一连锁上最多1次）。给那只怪兽放置1个兔耳指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以有兔耳指示物放置的1只怪兽为对象才能发动。那只怪兽和这张卡直到下个回合的准备阶段除外。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"怪兽除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
s.mentioned_counter={
	[0x1065]=true,
}
-- 发动条件判定：连锁发动的效果的处理者是场上表侧表示的怪兽、且该效果是怪兽效果、那只怪兽不是「兔耳导师」自身
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsOnField() and rc:IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER) and not rc:IsCode(id)
end
-- 发动可行性判定：连锁发动效果的那只怪兽可以放置1个兔耳指示物（0x1065），且本连锁上尚未因同一连锁最多1次的限制发动过此效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return re:GetHandler():IsCanAddCounter(0x1065,1)
		and c:GetFlagEffect(id)==0 end
	-- 向对方玩家提示我方选择发动了「放置指示物」效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	-- 设置连锁操作信息为指示物类，声明将放置1个兔耳指示物，供发动检测（如王家长眠之谷等）使用
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1065)
end
-- 效果处理：若连锁发动效果的那只怪兽在场上表侧表示且仍与该效果关联，则给它放置1个兔耳指示物，成功后为它注册一个持续效果：只要有兔耳指示物放置就不会被战斗破坏
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsFaceup() and rc:IsRelateToEffect(re) and rc:AddCounter(0x1065,1) then
		-- 有兔耳指示物放置的怪兽不会被战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetCondition(s.indes)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		rc:RegisterEffect(e1)
	end
end
-- 不会被战斗破坏的适用条件判定：该怪兽上放置有兔耳指示物（数量大于0）
function s.indes(e)
	return e:GetHandler():GetCounter(0x1065)>0
end
-- 目标筛选条件：怪兽放置有兔耳指示物且可以被除外
function s.filter(c)
	return c:GetCounter(0x1065)>0 and c:IsAbleToRemove()
end
-- 除外效果的目标选择阶段：确认对象候选须在怪兽区域、满足筛选条件且不是这张卡自身；发动可行性判定为这张卡可以被除外且双方怪兽区域存在可作为对象的有兔耳指示物的怪兽
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) and chkc~=c end
	if chk==0 then return c:IsAbleToRemove()
		-- 检查双方怪兽区域是否存在至少1只满足条件（有兔耳指示物且可除外）的可以作为对象的怪兽（这张卡除外）
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 向对方玩家提示我方选择发动了「怪兽除外」效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 向发动方玩家显示选卡提示「请选择要除外的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从双方怪兽区域选择1只有兔耳指示物放置的怪兽作为这个效果的对象（这张卡除外）
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置连锁操作信息为除外类，声明将把对象怪兽和这张卡共2张卡除外，供发动检测使用
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g+c,2,0,0)
end
-- 效果处理：取对象怪兽，若它和这张卡都与效果关联，则将这2张卡暂时除外；除外成功时记录这张卡的场上识别ID、按当前阶段计算返回所需的准备阶段计数，给每张被除外的卡注册标记效果，并注册一个在下个回合的准备阶段触发的持续效果用于把它们返回场上
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象卡（有兔耳指示物放置的那只怪兽）
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end
	local g=Group.FromCards(c,tc)
	-- 将这张卡和对象怪兽以表侧表示以外的默认表示形式、作为暂时除外从游戏中除外，并判断是否实际除外成功
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local fid=c:GetFieldID()
		-- 根据当前所处阶段计算返回用的准备阶段计数：当前处于准备阶段或之前则为2（隔过一个准备阶段），否则为1（下个准备阶段返回）
		local ct=Duel.GetCurrentPhase()<=PHASE_STANDBY and 2 or 1
		-- 取得本次除外操作实际被除外的卡片组
		local og=Duel.GetOperatedGroup()
		-- 遍历实际被除外的每张卡，为它们逐一注册返回用的标记效果
		for oc in aux.Next(og) do
			oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,ct,fid)
		end
		og:KeepAlive()
		-- 那只怪兽和这张卡直到下个回合的准备阶段除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		-- 将这张卡的场上识别ID和下1个回合数记录到持续效果的标签中，作为届时返回场上的判定依据
		e1:SetLabel(fid,Duel.GetTurnCount()+1)
		e1:SetLabelObject(og)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY,ct)
		-- 把「下个回合的准备阶段将除外的卡返回场上」的持续效果注册到全局环境，使其在准备阶段自动检查并处理
		Duel.RegisterEffect(e1,tp)
	end
end
-- 返回判定用的筛选条件：卡的标记效果标签与记录的场上识别ID一致，即属于本次被除外的那批卡
function s.retfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 返回效果的发动条件判定：已到达记录的目标回合，且被除外的卡中仍存在与本次除外对应的卡，否则清理卡片组并重置该效果
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local fid,ct=e:GetLabel()
	-- 判定当前回合数是否尚未到达记录的目标回合数，未到则不触发返回处理
	if Duel.GetTurnCount()<ct then return false end
	local g=e:GetLabelObject()
	if not g:IsExists(s.retfilter,1,nil,fid) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 返回处理：从被除外的卡片组中筛选出属于本次除外的卡，清理临时卡片组，并将这些卡逐一返回场上
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local fid,ct=e:GetLabel()
	local g=e:GetLabelObject()
	local sg=g:Filter(s.retfilter,nil,fid)
	g:DeleteGroup()
	-- 将每张属于本次除外的卡以离场前的表示形式返回场上
	for tc in aux.Next(sg) do Duel.ReturnToField(tc) end
end
