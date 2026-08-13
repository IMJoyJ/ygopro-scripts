--魔霧雨
-- 效果：
-- 这张卡发动的回合，自己不能进行战斗阶段。
-- ①：以自己的怪兽区域1只「恶魔召唤」或者雷族怪兽为对象才能发动。持有那只怪兽的攻击力以下的守备力的对方场上的怪兽全部破坏。
function c27827272.initial_effect(c)
	-- 这张卡发动的回合，自己不能进行战斗阶段。①：以自己的怪兽区域1只「恶魔召唤」或者雷族怪兽为对象才能发动。持有那只怪兽的攻击力以下的守备力的对方场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c27827272.cost)
	e1:SetTarget(c27827272.target)
	e1:SetOperation(c27827272.activate)
	c:RegisterEffect(e1)
end
-- cost函数整体：作为发动限制，检查当前阶段是否为主要阶段1，若是则为发动者玩家注册一个本回合不能进入战斗阶段的誓约效果，以此作为这张卡发动时附带的“这张卡发动的回合，自己不能进行战斗阶段”限制。
function c27827272.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查：只有当前阶段是主要阶段1时才允许发动这张卡。
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1 end
	-- 这张卡发动的回合，自己不能进行战斗阶段。①：以自己的怪兽区域1只「恶魔召唤」或者雷族怪兽为对象才能发动。持有那只怪兽的攻击力以下的守备力的对方场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将禁止战斗阶段的永续效果注册给发动者tp，该效果带有誓约标记，会在结束阶段重置，使tp在这个回合内不能进入战斗阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 定义对象选择过滤器：自己怪兽区域表侧表示且卡名为「恶魔召唤」或雷族，同时对方场上有表侧表示且守备力不高于该怪兽当前攻击力的怪兽存在。
function c27827272.filter(c,tp)
	return c:IsFaceup() and (c:IsCode(70781052) or c:IsRace(RACE_THUNDER))
		-- 确认对方场上存在表侧表示且守备力不高于该怪兽当前攻击力的怪兽，以保证选择该对象后一定能有可破坏的对方怪兽。
		and Duel.IsExistingMatchingCard(c27827272.filter2,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 定义破坏目标过滤器：对方场上表侧表示且守备力不高于传入的攻击力atk的怪兽。
function c27827272.filter2(c,atk)
	return c:IsFaceup() and c:IsDefenseBelow(atk)
end
-- target函数：进行发动合法性检查，选择自己场上的1只符合条件的怪兽作为对象，并根据该对象的攻击力获取对方场上将被破坏的怪兽组，设置破坏的操作信息。
function c27827272.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c27827272.filter(chkc,tp) end
	-- 效果发动合法性检查：自己场上是否存在1只以上满足filter条件的怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c27827272.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家显示选择对象的提示信息“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让发动者从自己怪兽区域选择1只符合条件的怪兽作为效果对象，并建立与当前连锁的关联。
	local g=Duel.SelectTarget(tp,c27827272.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 根据所选对象的攻击力，筛选出对方场上所有表侧表示且守备力小于等于该攻击力的怪兽，得到本次破坏的候选集合。
	local dg=Duel.GetMatchingGroup(c27827272.filter2,tp,0,LOCATION_MZONE,nil,g:GetFirst():GetAttack())
	-- 将准备破坏的怪兽组及数量写入连锁操作信息，供星尘龙等卡牌对此效果进行检测和连锁。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- activate函数：效果处理时，若对象仍然表侧表示且与效果关联，则以对象当前攻击力重新筛选对方怪兽并全部破坏。
function c27827272.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁正在处理的效果所选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以对象当前的攻击力为基准，重新获取对方场上所有表侧表示且守备力小于等于该攻击力的怪兽。
		local dg=Duel.GetMatchingGroup(c27827272.filter2,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
		-- 将这些怪兽以效果原因全部破坏。
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
