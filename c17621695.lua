--糾罪都市－エニアポリス
-- 效果：
-- 这个卡名在规则上也当作「纠罪巧」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上的「纠罪巧」灵摆怪兽卡任意数量为对象才能发动。那些卡回到手卡。
-- ②：自己场上的「纠罪巧」灵摆怪兽在主要阶段反转的场合才能发动。选那之内的1只回到手卡或在自己的灵摆区域放置。
-- ③：自己·对方的结束阶段发动。自己场上的纠罪指示物全部取除，对方受到那个数量×900伤害。
local s,id,o=GetID()
-- 注册卡片的4个效果：①灵摆怪兽回手（起动效果）、②灵摆怪兽反转回手或放置（诱发选发效果）、③结束阶段去除指示物造成伤害（诱发必发效果）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上的「纠罪巧」灵摆怪兽卡任意数量为对象才能发动。那些卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"回手"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 为卡片注册自定义事件代码，用于检测灵摆怪兽反转事件（EVENT_FLIP），确保反转诱发效果不会在同一连锁中重复触发
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_FLIP)
	-- ②：自己场上的「纠罪巧」灵摆怪兽在主要阶段反转的场合才能发动。选那之内的1只回到手卡或在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回手"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(custom_code)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.pthcon)
	e3:SetTarget(s.pthtg)
	e3:SetOperation(s.pthop)
	c:RegisterEffect(e3)
	-- ③：自己·对方的结束阶段发动。自己场上的纠罪指示物全部取除，对方受到那个数量×900伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
s.mentioned_counter={
	[0x71]=true,
}
-- 过滤函数：筛选场上正面表示的、属于「纠罪巧」系列的灵摆怪兽
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d4) and c:GetOriginalType()&TYPE_PENDULUM~=0
end
-- ①效果的代价和对象选择：检查是否有满足条件的灵摆怪兽，让玩家选择要返回手牌的卡（最多99张），并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查是否存在符合条件的灵摆怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择1到99张符合条件的灵摆怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,99,nil)
	-- 设置操作信息，宣告此效果处理卡牌返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- ①效果的处理：将选择的灵摆怪兽返回手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果链中确定的对象卡
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 then
		-- 将对象卡以效果原因送回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤函数：筛选自己场上正面表示的「纠罪巧」灵摆怪兽，且该卡必须满足可放置到灵摆区域或可返回手牌的条件
function s.pthfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x1d4) and c:IsControler(tp) and c:IsFaceup()
		-- 检查玩家左灵摆区域是否有空位
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0)
		-- 检查玩家右灵摆区域是否有空位
		or Duel.CheckLocation(tp,LOCATION_PZONE,1)
		or c:IsAbleToHand())
end
-- ②效果的条件：主要阶段且场上有「纠罪巧」灵摆怪兽反转
function s.pthcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.pthfilter,1,nil,tp)
		-- 确保当前是主要阶段（②效果的必要条件）
		and Duel.IsMainPhase()
end
-- ②效果的对象设置：将符合条件的反转灵摆怪兽设为效果对象
function s.pthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.pthfilter,nil,tp)
	if chk==0 then return #g>0 end
	-- 将对象卡设置为当前效果的目标卡
	Duel.SetTargetCard(g)
end
-- ②效果的处理：玩家选择1只反转的灵摆怪兽，执行回手或放置灵摆区域
function s.pthop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.pthfilter,nil,tp)
	local mg=g:Filter(Card.IsRelateToChain,nil)
	if mg:GetCount()>0 then
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		local og=mg:Select(tp,1,1,nil)
		-- 显示被选中的卡的动画效果
		Duel.HintSelection(og)
		local tc=og:GetFirst()
		-- 检查灵摆区域是否有空位（作为可选选项的条件）
		local b1=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
		local b2=tc:IsAbleToHand()
		-- 让玩家在「放置灵摆区域」和「加入手卡」两个选项中选择
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,3),1},  --"放置灵摆区域"
			{b2,aux.Stringid(id,4),2})  --"加入手卡"
		if op==1 then
			if not tc:IsImmuneToEffect(e) then
				-- 将选中的灵摆怪兽移动到自己的灵摆区域
				Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		else
			-- 将选中的灵摆怪兽返回手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- ③效果的代价检查和伤害设置：检查是否有纠罪指示物，如有则设置伤害值
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查自己场上是否存在纠罪指示物（0x71类型）
	if Duel.GetCounter(tp,1,0,0x71)>0 then
		-- 计算伤害值：指示物数量×900
		local dam=Duel.GetCounter(tp,1,0,0x71)*900
		-- 设置伤害目标玩家为对方
		Duel.SetTargetPlayer(1-tp)
		-- 设置伤害数值参数
		Duel.SetTargetParam(dam)
		-- 设置伤害效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
end
-- 过滤函数：筛选场上有纠罪指示物的卡
function s.ctfilter(c)
	return c:GetCounter(0x71)>0
end
-- ③效果的处理：去除所有纠罪指示物并造成伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有有纠罪指示物的卡
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_ONFIELD,0,nil)
	local tc=g:GetFirst()
	local rmct=0
	while tc do
		local ct=tc:GetCounter(0x71)
		rmct=rmct+ct
		tc:RemoveCounter(tp,0x71,ct,REASON_EFFECT)
		tc=g:GetNext()
	end
	if rmct>0 then
		-- 对方受到去除的指示物数量×900的伤害
		Duel.Damage(1-tp,rmct*900,REASON_EFFECT)
	end
end
