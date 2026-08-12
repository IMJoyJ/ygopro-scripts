--ハーピィ・レディ －鳳凰の陣－
-- 效果：
-- 这张卡发动的回合，自己不能从卡组·额外卡组把怪兽特殊召唤，不能进行战斗阶段。
-- ①：自己场上有「鹰身女郎」「鹰身女郎三姐妹」合计3只以上存在的场合，尽可能以最多有那个数量的对方场上的怪兽为对象才能发动。作为对象的怪兽破坏，给与对方破坏的怪兽之内原本攻击力最高的怪兽的那个数值的伤害。
function c86308219.initial_effect(c)
	-- 注册卡片密码，表示本卡记载了「鹰身女郎三姐妹」的卡名
	aux.AddCodeList(c,12206212)
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
	-- 注册一个自定义活动计数器，用于检测玩家是否从卡组或额外卡组特殊召唤过怪兽
	Duel.AddCustomActivityCounter(86308219,ACTIVITY_SPSUMMON,c86308219.counterfilter)
end
-- 计数器过滤函数：过滤出不是从卡组或额外卡组特殊召唤的怪兽
function c86308219.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤条件：场上表侧表示的「鹰身女郎」或「鹰身女郎三姐妹」
function c86308219.cfilter(c)
	return c:IsFaceup() and c:IsCode(76812113,12206212)
end
-- 效果发动条件：自己场上存在合计3只以上的「鹰身女郎」或「鹰身女郎三姐妹」
function c86308219.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少3张表侧表示的「鹰身女郎」或「鹰身女郎三姐妹」
	return Duel.IsExistingMatchingCard(c86308219.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
-- 效果发动代价与限制：检查本回合是否未从卡组·额外卡组特召，且当前为主要阶段1
function c86308219.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合玩家是否未进行过从卡组或额外卡组的特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(86308219,tp,ACTIVITY_SPSUMMON)==0
		-- 并且当前阶段必须是主要阶段1
		and Duel.GetCurrentPhase()==PHASE_MAIN1 end
	-- 这张卡发动的回合，自己不能从卡组·额外卡组把怪兽特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c86308219.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能从卡组·额外卡组特殊召唤的限制效果
	Duel.RegisterEffect(e1,tp)
	-- 不能进行战斗阶段。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_BP)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能进行战斗阶段的限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 特殊召唤限制函数：限制从卡组或额外卡组特殊召唤
function c86308219.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果发动目标选择：选择对方场上最多等同于自己场上「鹰身女郎」「鹰身女郎三姐妹」合计数量的怪兽为对象
function c86308219.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1只可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 计算自己场上表侧表示的「鹰身女郎」和「鹰身女郎三姐妹」的合计数量
	local ct=Duel.GetMatchingGroupCount(c86308219.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 给玩家发送提示信息：“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上数量正好等于合计数量的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,ct,ct,nil)
	-- 设置效果处理信息：破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置效果处理信息：给与对方玩家伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果处理：破坏作为对象的怪兽，并给与对方破坏怪兽中原本攻击力最高数值的伤害
function c86308219.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与此效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 尝试破坏这些对象怪兽，若成功破坏了至少1只则继续处理
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取实际被破坏并送去墓地的卡片组
		local og=Duel.GetOperatedGroup()
		local mg,matk=og:GetMaxGroup(Card.GetBaseAttack)
		if matk>0 then
			-- 给与对方玩家等同于被破坏怪兽中最高原本攻击力数值的伤害
			Duel.Damage(1-tp,matk,REASON_EFFECT)
		end
	end
end
