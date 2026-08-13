--ディーヴジャン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上的表侧表示的「分裂机器人」全部解放才能发动。把最多有解放数量×2只的「机械衍生物」（机械族·炎·1星·攻/守200）在自己场上特殊召唤。这衍生物被破坏时对方受到每1只500伤害。
-- ②：这张卡被除外的场合，以自己场上的衍生物任意数量为对象才能发动。那衍生物破坏。
function c42427230.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把自己场上的表侧表示的「分裂机器人」全部解放才能发动。把最多有解放数量×2只的「机械衍生物」（机械族·炎·1星·攻/守200）在自己场上特殊召唤。这衍生物被破坏时对方受到每1只500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42427230,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,42427230)
	e1:SetCost(c42427230.spcost)
	e1:SetTarget(c42427230.sptg)
	e1:SetOperation(c42427230.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以自己场上的衍生物任意数量为对象才能发动。那衍生物破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42427230,1))  --"破坏衍生物"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,42427231)
	e2:SetTarget(c42427230.destg)
	e2:SetOperation(c42427230.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选自己场上的「分裂机器人」作为解放候选，条件是（控制者为tp或表侧表示）且卡名为42427230。
function c42427230.cfilter(c,tp)
	return (c:IsControler(tp) or c:IsFaceup()) and c:IsCode(42427230)
end
-- 代价检查阶段：获取自己场上所有「分裂机器人」组成候选组，确认其中全部可以解放、数量不为0，且解放后自己怪兽区仍有空位，才允许发动。
function c42427230.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己场上满足cfilter的所有「分裂机器人」组成候选组。
	local rg=Duel.GetMatchingGroup(c42427230.cfilter,tp,LOCATION_MZONE,0,nil,tp)
	if chk==0 then return rg:GetCount()==rg:FilterCount(Card.IsReleasable,nil)
		-- 代价检查后两个条件：候选组数量不为0，且解放这些卡后自己场上仍有可用怪兽区空格。
		and rg:GetCount()~=0 and Duel.GetMZoneCount(tp,rg)>0 end
	-- 实际执行代价：将候选组全部解放（REASON_COST），解放数量乘以2存入标签ct，作为可特殊召唤衍生物的数量上限。
	local ct=Duel.Release(rg,REASON_COST)*2
	e:SetLabel(ct)
end
-- ①效果的发动目标/条件判定与操作信息设置：检查能否特殊召唤「机械衍生物」，并声明本次效果包含衍生物生成和特殊召唤。
function c42427230.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：确认玩家tp能否特殊召唤1只「机械衍生物」（卡号42427231，机械族·炎·1星·攻/守200）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,42427231,0,TYPES_TOKEN_MONSTER,200,200,1,RACE_MACHINE,ATTRIBUTE_FIRE) end
	-- 向系统声明本次效果涉及衍生物生成（CATEGORY_TOKEN），预计生成1只（实际数量处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 向系统声明本次效果包含特殊召唤（CATEGORY_SPECIAL_SUMMON），预计特殊召唤1只（实际数量处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ①效果处理：根据解放数量×2与可用怪兽区空格数确定实际衍生物数量；若「青眼精灵龙」效果适用则只能特召1只；逐只生成「机械衍生物」并注册离场破坏时造成500伤害的效果，最后完成特殊召唤。
function c42427230.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上可用的怪兽区域空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=e:GetLabel()
	-- 判断是否满足实际特殊召唤条件：有空格、有可召唤数量、且玩家可以特殊召唤该衍生物。
	if ft>0 and ct>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,42427231,0,TYPES_TOKEN_MONSTER,200,200,1,RACE_MACHINE,ATTRIBUTE_FIRE) then
		local count=math.min(ft,ct)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then count=1 end
		if count>1 then
			local num={}
			local i=1
			while i<=count do
				num[i]=i
				i=i+1
			end
			-- 显示选择提示消息，要求玩家选择要特殊召唤的衍生物数量。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(42427230,2))  --"请选择要特殊召唤的衍生物数量"
			-- 让玩家在1至当前上限间宣言一个数字，作为实际特殊召唤的衍生物数量。
			count=Duel.AnnounceNumber(tp,table.unpack(num))
		end
		for i=1,count do
			-- 创建一只「机械衍生物」（卡号42427231）的token，持有者为tp。
			local token=Duel.CreateToken(tp,42427231)
			-- 以表侧表示将衍生物特殊召唤到tp场上（作为连锁处理中的一步），成功则继续注册效果。
			if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
				-- 这衍生物被破坏时对方受到每1只500伤害。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(42427230,3))
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
				e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_LEAVE_FIELD)
				e1:SetLabel(tp)
				e1:SetOperation(c42427230.damop)
				token:RegisterEffect(e1,true)
			end
		end
		-- 完成连锁处理中分步进行的特殊召唤，统一处理召唤成功时点并结束特殊召唤流程。
		Duel.SpecialSummonComplete()
	end
end
-- 衍生物离场时的效果处理：判定该衍生物是否因被破坏而离场，若是则给对手造成500伤害，随后重置该效果。
function c42427230.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=e:GetLabel()
	if c:IsReason(REASON_DESTROY) then
		-- 给衍生物持有者的对手（1-p）造成500点效果伤害。
		Duel.Damage(1-p,500,REASON_EFFECT)
	end
	e:Reset()
end
-- 过滤函数：判断卡是否为表侧表示且为衍生物。
function c42427230.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOKEN)
end
-- 过滤函数：在desfilter基础上，追加判定该衍生物是否能成为当前效果的对象。
function c42427230.desfilter2(c,e)
	return c42427230.desfilter(c) and c:IsCanBeEffectTarget(e)
end
-- ②效果的目标设定：从自己场上表侧表示的衍生物中选择任意数量（至少1只）作为对象，并设置破坏操作信息。
function c42427230.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c42427230.desfilter(chkc) end
	-- 获取自己场上满足条件的全部可成为对象的表侧衍生物组。
	local g=Duel.GetMatchingGroup(c42427230.desfilter2,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return g:GetCount()~=0 end
	-- 显示选择衍生物作为破坏对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=g:Select(tp,1,g:GetCount(),nil)
	-- 将玩家选择的衍生物组设置为当前连锁的处理对象（取对象）。
	Duel.SetTargetCard(sg)
	-- 向系统声明本次效果将破坏这些目标，数量为sg的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ②效果处理：从连锁对象中筛选仍与该效果有关联的衍生物，将其全部破坏。
function c42427230.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的目标卡组，并过滤出仍与效果e有关联的卡（未离场/未失效）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()~=0 then
		-- 以效果原因将选中的衍生物组破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
