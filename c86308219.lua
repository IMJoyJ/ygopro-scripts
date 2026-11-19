--ハーピィ・レディ －鳳凰の陣－
-- 效果：
-- 这张卡发动的回合，自己不能从卡组·额外卡组把怪兽特殊召唤，不能进行战斗阶段。
-- ①：自己场上有「鹰身女郎」「鹰身女郎三姐妹」合计3只以上存在的场合，尽可能以最多有那个数量的对方场上的怪兽为对象才能发动。作为对象的怪兽破坏，给与对方破坏的怪兽之内原本攻击力最高的怪兽的那个数值的伤害。
function c86308219.initial_effect(c)
	-- 记录这张卡文本中记述了「鹰身女郎」(76812113)和「鹰身女郎三姐妹」(12206212)卡名的事实
	aux.AddCodeList(c,76812113,12206212)
	-- ①：自己场上有「鹰身女郎」「鹰身女郎三姐妹」合计3只以上存在的场合，尽可能以最多有那个数量的对方场上的怪兽为对象才能发动。作为对象的怪兽破坏，给与对方破坏的怪兽之内原本攻击力最高的怪兽的那个数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c86308219.condition)
	e1:SetCost(c86308219.cost)
	e1:SetTarget(c86308219.target)
	e1:SetOperation(c86308219.activate)
	c:RegisterEffect(e1)
	-- 注册编号为86308219的自定义操作计数器，监测玩家本回合是否从卡组·额外卡组进行过特殊召唤
	Duel.AddCustomActivityCounter(86308219,ACTIVITY_SPSUMMON,c86308219.counterfilter)
end
-- 活动计数器过滤函数，判断怪兽是否并非从卡组·额外卡组特殊召唤
function c86308219.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤函数，筛选场上表侧表示的「鹰身女郎」(76812113)或「鹰身女郎三姐妹」(12206212)
function c86308219.cfilter(c)
	return c:IsFaceup() and c:IsCode(76812113,12206212)
end
-- ①效果的Condition函数，检查自己怪兽区域是否存在合计3只以上的「鹰身女郎」或「鹰身女郎三姐妹」
function c86308219.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区域中满足cfilter条件的怪兽是否至少有3只
	return Duel.IsExistingMatchingCard(c86308219.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
-- 发动代价与誓约函数，确认本回合未从卡组·额外卡组特招且处于主要阶段1，并注册本回合的誓约限制效果
function c86308219.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测时，检查玩家tp本回合从卡组·额外卡组特殊召唤的次数是否为0
	if chk==0 then return Duel.GetCustomActivityCount(86308219,tp,ACTIVITY_SPSUMMON)==0
		-- 同时检查当前是否处于主要阶段1
		and Duel.GetCurrentPhase()==PHASE_MAIN1 end
	-- 这张卡发动的回合，自己不能从卡组·额外卡组把怪兽特殊召唤，
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c86308219.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家tp注册持续到回合结束的不能从卡组·额外卡组特殊召唤的誓约效果e1
	Duel.RegisterEffect(e1,tp)
	-- 不能进行战斗阶段。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_BP)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家tp注册持续到回合结束的不能进入战斗阶段的誓约效果e2
	Duel.RegisterEffect(e2,tp)
end
-- 特殊召唤限制过滤函数，禁止玩家从卡组或额外卡组特殊召唤怪兽
function c86308219.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- ①效果的Target函数，统计己方鹰身数量ct并选择对方场上对应数量的怪兽作为对象，设置破坏和伤害操作信息
function c86308219.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动条件检测时，检查对方怪兽区域是否存在至少1只可作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 统计自己场上表侧表示「鹰身女郎」与「鹰身女郎三姐妹」的总数量ct
	local ct=Duel.GetMatchingGroupCount(c86308219.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 向自己发送选择提示信息：“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让自己在对方怪兽区域选择ct只怪兽作为连锁对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,ct,ct,nil)
	-- 设置操作信息，声明将破坏对象卡组g中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息，声明将给与对方效果伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- ①效果的Operation函数，破坏仍与效果关联的对象怪兽，并取被破坏怪兽中原本攻击力最高值给与对方伤害
function c86308219.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁对象卡组中依然与效果保持关联的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果破坏对象怪兽组g，并检查是否至少有1只被成功破坏
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取刚才破坏操作中实际被破坏的怪兽卡片组
		local og=Duel.GetOperatedGroup()
		local mg,matk=og:GetMaxGroup(Card.GetBaseAttack)
		if matk>0 then
			-- 以效果给与对方玩家等于原本攻击力最大值matk的效果伤害
			Duel.Damage(1-tp,matk,REASON_EFFECT)
		end
	end
end
