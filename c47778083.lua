--ボーン・テンプル・ブロック
-- 效果：
-- 丢弃1张手卡。双方从对方墓地选择1只4星以下的怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段时破坏。
function c47778083.initial_effect(c)
	-- 丢弃1张手卡。双方从对方墓地选择1只4星以下的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c47778083.target)
	e1:SetOperation(c47778083.operation)
	c:RegisterEffect(e1)
end
-- 判断卡片是否满足条件：4星以下且能够被效果特殊召唤。
function c47778083.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标选择函数：检查发动条件，并让双方玩家各选择对方墓地1只可特殊召唤的4星以下怪兽作为对象。
function c47778083.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		-- 检查自己手牌数量不为0，确保有手卡可以丢弃作为发动代价。
		return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=0
			-- 检查自己的对方墓地存在至少1只满足条件的4星以下怪兽，可供自己选择为特殊召唤对象。
			and Duel.IsExistingTarget(c47778083.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp)
			-- 检查自己的主要怪兽区有空位，可以特殊召唤怪兽到自己场上。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查对方的对方墓地存在至少1只满足条件的4星以下怪兽，可供对方选择为特殊召唤对象。
			and Duel.IsExistingTarget(c47778083.filter,1-tp,0,LOCATION_GRAVE,1,nil,e,1-tp)
			-- 检查对方的主要怪兽区有空位，可以特殊召唤怪兽到对方场上。
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)>0
	end
	local tg=Group.CreateGroup()
	-- 依次遍历当前回合玩家和对方玩家，让双方各自选择要特殊召唤的怪兽。
	for p in aux.TurnPlayers() do
		-- 提示当前玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家p从对方墓地选择1张满足条件的怪兽卡，并设为这张卡的效果对象。
		local g=Duel.SelectTarget(p,c47778083.filter,p,0,LOCATION_GRAVE,1,1,nil,e,p)
		tg:Merge(g)
	end
	-- 将本次效果的操作信息设置为特殊召唤，对象为已选择的两只怪兽，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,2,0,0)
end
-- 效果处理：丢弃1张手卡作为代价，将之前选择的两只怪兽分别特殊召唤到各自玩家的场上，并记录这些怪兽，准备在下个回合结束阶段将其破坏。
function c47778083.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 丢弃1张手卡作为发动代价；若未能成功丢弃（如手卡数量不足），则效果不处理。
	if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD)==0 then return end
	-- 取得当前连锁中与这个效果关联的对象卡组，即双方选择的那两只怪兽。
	local tg=Duel.GetTargetsRelateToChain()
	if #tg==0 then return end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	local sg=Group.CreateGroup()
	-- 再次遍历双方玩家，逐个处理对应怪兽的特殊召唤。
	for p in aux.TurnPlayers() do
		local tc=tg:Filter(Card.IsControler,nil,1-p):GetFirst()
		-- 若存在属于对方玩家的对象怪兽，则将其以表侧表示特殊召唤到当前玩家p场上；成功则为其附加标记以跟踪。
		if tc and Duel.SpecialSummonStep(tc,0,p,p,false,false,POS_FACEUP) then
			tc:RegisterFlagEffect(47778083,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tg:RemoveCard(tc)
			sg:AddCard(tc)
		end
	end
	-- 结束整个特殊召唤处理流程，统一触发特殊召唤成功的时点。
	Duel.SpecialSummonComplete()
	if #sg==0 then return end
	sg:KeepAlive()
	-- 这个效果特殊召唤的怪兽在下个回合的结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCondition(c47778083.descon)
	e1:SetOperation(c47778083.desop)
	-- 记录本次效果的标识fid和当前回合数，用于判断“下个回合”并进行精准破坏。
	e1:SetLabel(fid,Duel.GetTurnCount())
	e1:SetLabelObject(sg)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	-- 将结束阶段破坏怪兽的效果注册到场上，由玩家tp控制。
	Duel.RegisterEffect(e1,tp)
end
-- 筛选函数：判断怪兽是否带有本次效果赋予的标记，用于确定哪些怪兽应被破坏。
function c47778083.desfilter(c,fid)
	return c:GetFlagEffectLabel(47778083)==fid
end
-- 触发条件函数：在非当回合的结束阶段，若仍存在本次特殊召唤的怪兽，则允许破坏；若已不存在，则清理并重置效果。
function c47778083.descon(e,tp,eg,ep,ev,re,r,rp)
	local fid,turnc=e:GetLabel()
	-- 若当前回合仍是特殊召唤的那个回合，则尚未到“下个回合”，不触发破坏。
	if Duel.GetTurnCount()==turnc then return false end
	local g=e:GetLabelObject()
	if not g:IsExists(c47778083.desfilter,1,nil,fid) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 破坏处理：在结束阶段将之前特殊召唤且仍存在的怪兽全部破坏。
function c47778083.desop(e,tp,eg,ep,ev,re,r,rp)
	local fid,turnc=e:GetLabel()
	local g=e:GetLabelObject()
	local tg=g:Filter(c47778083.desfilter,nil,fid)
	-- 将这些怪兽以效果原因破坏。
	Duel.Destroy(tg,REASON_EFFECT)
end
