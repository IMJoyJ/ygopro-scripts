--ボーン・テンプル・ブロック
-- 效果：
-- 丢弃1张手卡。双方从对方墓地选择1只4星以下的怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段时破坏。
function c47778083.initial_effect(c)
	-- 效果发动时的初始化设置，包括类型、分类、触发条件、目标和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c47778083.target)
	e1:SetOperation(c47778083.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选等级不超过4星且可以特殊召唤的怪兽
function c47778083.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的处理目标函数，检查是否满足发动条件并选择目标怪兽
function c47778083.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		-- 检查当前玩家手牌数量是否大于0
		return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=0
			-- 检查当前玩家对方墓地是否存在符合条件的怪兽
			and Duel.IsExistingTarget(c47778083.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp)
			-- 检查当前玩家场上是否有足够的怪兽区域
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查对方玩家墓地是否存在符合条件的怪兽
			and Duel.IsExistingTarget(c47778083.filter,1-tp,0,LOCATION_GRAVE,1,nil,e,1-tp)
			-- 检查对方玩家场上是否有足够的怪兽区域
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)>0
	end
	local tg=Group.CreateGroup()
	-- 遍历双方玩家，为每方选择目标怪兽
	for p in aux.TurnPlayers() do
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从指定区域选择满足条件的怪兽作为目标
		local g=Duel.SelectTarget(p,c47778083.filter,p,0,LOCATION_GRAVE,1,1,nil,e,p)
		tg:Merge(g)
	end
	-- 设置效果处理信息，告知连锁将特殊召唤两只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,2,0,0)
end
-- 效果的处理函数，执行丢弃手卡并特殊召唤怪兽的操作
function c47778083.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 丢弃一张手牌作为发动代价
	if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD)==0 then return end
	-- 获取与当前连锁相关的怪兽目标组
	local tg=Duel.GetTargetsRelateToChain()
	if #tg==0 then return end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	local sg=Group.CreateGroup()
	-- 遍历双方玩家，为每方特殊召唤对应的怪兽
	for p in aux.TurnPlayers() do
		local tc=tg:Filter(Card.IsControler,nil,1-p):GetFirst()
		-- 尝试特殊召唤指定的怪兽
		if tc and Duel.SpecialSummonStep(tc,0,p,p,false,false,POS_FACEUP) then
			tc:RegisterFlagEffect(47778083,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tg:RemoveCard(tc)
			sg:AddCard(tc)
		end
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
	if #sg==0 then return end
	sg:KeepAlive()
	-- 创建一个在回合结束时触发的效果，用于破坏特殊召唤的怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCondition(c47778083.descon)
	e1:SetOperation(c47778083.desop)
	-- 设置效果标签，记录当前场ID和回合数
	e1:SetLabel(fid,Duel.GetTurnCount())
	e1:SetLabelObject(sg)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	-- 将该效果注册到全局环境中
	Duel.RegisterEffect(e1,tp)
end
-- 用于判断怪兽是否属于本次特殊召唤的标识
function c47778083.desfilter(c,fid)
	return c:GetFlagEffectLabel(47778083)==fid
end
-- 判断是否到了回合结束阶段且目标怪兽仍存在
function c47778083.descon(e,tp,eg,ep,ev,re,r,rp)
	local fid,turnc=e:GetLabel()
	-- 如果当前回合数等于记录的回合数，则不触发破坏效果
	if Duel.GetTurnCount()==turnc then return false end
	local g=e:GetLabelObject()
	if not g:IsExists(c47778083.desfilter,1,nil,fid) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 执行破坏操作，将符合条件的怪兽破坏
function c47778083.desop(e,tp,eg,ep,ev,re,r,rp)
	local fid,turnc=e:GetLabel()
	local g=e:GetLabelObject()
	local tg=g:Filter(c47778083.desfilter,nil,fid)
	-- 以效果原因破坏指定的怪兽
	Duel.Destroy(tg,REASON_EFFECT)
end
