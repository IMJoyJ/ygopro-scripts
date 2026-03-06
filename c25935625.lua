--闇竜星－ジョクト
-- 效果：
-- 「暗龙星-椒图」的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「暗龙星-椒图」以外的1只「龙星」怪兽攻击表示特殊召唤。
-- ②：自己场上没有这张卡以外的怪兽存在的场合，把手卡2张「龙星」卡送去墓地才能发动。从卡组把攻击力0和守备力0的「龙星」怪兽各1只特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。
function c25935625.initial_effect(c)
	-- 效果原文：①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「暗龙星-椒图」以外的1只「龙星」怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25935625,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,25935625)
	e1:SetCondition(c25935625.condition)
	e1:SetTarget(c25935625.target)
	e1:SetOperation(c25935625.operation)
	c:RegisterEffect(e1)
	-- 效果原文：②：自己场上没有这张卡以外的怪兽存在的场合，把手卡2张「龙星」卡送去墓地才能发动。从卡组把攻击力0和守备力0的「龙星」怪兽各1只特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25935625,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,25935625)
	e2:SetCondition(c25935625.spcon)
	e2:SetCost(c25935625.spcost)
	e2:SetTarget(c25935625.sptg)
	e2:SetOperation(c25935625.spop)
	c:RegisterEffect(e2)
end
-- 规则层面：判断此卡是否因战斗或效果破坏而送入墓地且之前在场上控制者为玩家
function c25935625.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 规则层面：过滤满足「龙星」卡组且不是椒图本身、可以特殊召唤的怪兽
function c25935625.filter(c,e,tp)
	return c:IsSetCard(0x9e) and not c:IsCode(25935625) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 规则层面：判断是否满足发动条件，即玩家场上存在空位且卡组存在符合条件的怪兽
function c25935625.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断玩家场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：判断卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c25935625.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面：设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面：执行效果操作，选择并特殊召唤符合条件的怪兽
function c25935625.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断玩家场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c25935625.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面：将选中的怪兽以攻击表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
-- 规则层面：判断玩家场上是否只有椒图自己
function c25935625.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断玩家场上怪兽数量是否为1
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- 规则层面：过滤满足「龙星」卡组且可以送入墓地作为代价的卡
function c25935625.cfilter(c)
	return c:IsSetCard(0x9e) and c:IsAbleToGraveAsCost()
end
-- 规则层面：设置发动条件，检查玩家手牌中是否存在2张满足条件的卡
function c25935625.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查玩家手牌中是否存在2张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c25935625.cfilter,tp,LOCATION_HAND,0,2,nil) end
	-- 规则层面：丢弃满足条件的2张手牌作为发动代价
	Duel.DiscardHand(tp,c25935625.cfilter,2,2,REASON_COST)
end
-- 规则层面：过滤攻击力为0的「龙星」怪兽，且卡组中存在满足条件的守备力为0的怪兽
function c25935625.spfilter1(c,e,tp)
	return c:IsSetCard(0x9e) and c:IsAttack(0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 规则层面：检查卡组中是否存在满足条件的守备力为0的怪兽
		and Duel.IsExistingMatchingCard(c25935625.spfilter2,tp,LOCATION_DECK,0,1,c,e,tp)
end
-- 规则层面：过滤守备力为0的「龙星」怪兽，且可以特殊召唤
function c25935625.spfilter2(c,e,tp)
	return c:IsSetCard(0x9e) and c:IsDefense(0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面：判断是否满足发动条件，即未受青眼精灵龙影响、玩家场上存在空位且卡组存在符合条件的怪兽
function c25935625.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 规则层面：判断玩家场上是否存在空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 规则层面：判断卡组中是否存在满足条件的攻击力为0的怪兽
		and Duel.IsExistingMatchingCard(c25935625.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面：设置连锁操作信息，表示将要特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 规则层面：执行效果操作，选择并特殊召唤符合条件的2只怪兽，并设置结束阶段除外效果
function c25935625.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 规则层面：判断玩家场上是否还有至少2个空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 规则层面：提示玩家选择要特殊召唤的攻击力为0的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：选择攻击力为0的怪兽
	local g1=Duel.SelectMatchingCard(tp,c25935625.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 规则层面：提示玩家选择要特殊召唤的守备力为0的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：选择守备力为0的怪兽
	local g2=Duel.SelectMatchingCard(tp,c25935625.spfilter2,tp,LOCATION_DECK,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	if g1:GetCount()>0 then
		local fid=e:GetHandler():GetFieldID()
		local tc=g1:GetFirst()
		while tc do
			-- 规则层面：将选中的怪兽以正面表示特殊召唤到场上
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(25935625,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tc=g1:GetNext()
		end
		-- 规则层面：完成特殊召唤流程
		Duel.SpecialSummonComplete()
		g1:KeepAlive()
		-- 效果原文：这个效果特殊召唤的怪兽在结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(g1)
		e1:SetCondition(c25935625.rmcon)
		e1:SetOperation(c25935625.rmop)
		-- 规则层面：注册结束阶段除外效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 规则层面：过滤拥有特定FieldID标记的怪兽
function c25935625.rmfilter(c,fid)
	return c:GetFlagEffectLabel(25935625)==fid
end
-- 规则层面：判断是否满足结束阶段除外条件
function c25935625.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c25935625.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 规则层面：执行结束阶段除外操作
function c25935625.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c25935625.rmfilter,nil,e:GetLabel())
	-- 规则层面：将符合条件的怪兽以正面表示除外
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
