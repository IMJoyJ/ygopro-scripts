--糾罪都市－エニアポリス
-- 效果：
-- 这个卡名在规则上也当作「纠罪巧」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上的「纠罪巧」灵摆怪兽卡任意数量为对象才能发动。那些卡回到手卡。
-- ②：自己场上的「纠罪巧」灵摆怪兽在主要阶段反转的场合才能发动。选那之内的1只回到手卡或在自己的灵摆区域放置。
-- ③：自己·对方的结束阶段发动。自己场上的纠罪指示物全部取除，对方受到那个数量×900伤害。
local s,id,o=GetID()
-- 注册场地魔法卡的通用发动效果，使该卡可以被正常发动
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
	-- 注册一个自定义的翻转触发事件，用于实现效果②的触发条件
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
-- 定义用于筛选「纠罪巧」灵摆怪兽的过滤函数
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d4) and c:GetOriginalType()&TYPE_PENDULUM~=0
end
-- 效果①的发动时点处理函数，用于选择目标怪兽并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查效果①是否满足发动条件
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的「纠罪巧」灵摆怪兽作为目标
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,99,nil)
	-- 设置效果①的处理信息，包括目标数量和处理类型
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 效果①的处理函数，将目标怪兽送回手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与当前连锁相关的选中目标
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 then
		-- 将目标怪兽送回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 定义用于筛选可触发效果②的怪兽的过滤函数
function s.pthfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x1d4) and c:IsControler(tp) and c:IsFaceup()
		-- 检查玩家0号灵摆区域是否可用
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0)
		-- 检查玩家1号灵摆区域是否可用
		or Duel.CheckLocation(tp,LOCATION_PZONE,1)
		or c:IsAbleToHand())
end
-- 效果②的发动条件函数，判断是否满足翻转触发条件
function s.pthcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.pthfilter,1,nil,tp)
		-- 判断是否处于主要阶段
		and Duel.IsMainPhase()
end
-- 效果②的发动时点处理函数，设置目标怪兽
function s.pthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.pthfilter,nil,tp)
	if chk==0 then return #g>0 end
	-- 设置当前处理的连锁目标为指定怪兽
	Duel.SetTargetCard(g)
end
-- 效果②的处理函数，选择将怪兽送回手牌或放置于灵摆区域
function s.pthop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.pthfilter,nil,tp)
	local mg=g:Filter(Card.IsRelateToChain,nil)
	if mg:GetCount()>0 then
		-- 提示玩家选择效果②的目标
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		local og=mg:Select(tp,1,1,nil)
		local tc=og:GetFirst()
		-- 判断灵摆区域是否可用以供放置怪兽
		local b1=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
		local b2=tc:IsAbleToHand()
		-- 根据玩家选择决定将怪兽放置于灵摆区域或送回手牌
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,3),1},  --"放置灵摆区域"
			{b2,aux.Stringid(id,4),2})  --"加入手卡"
		if op==1 then
			-- 将目标怪兽移动到灵摆区域
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		else
			-- 显示目标怪兽被选中的动画效果
			Duel.HintSelection(og)
			-- 将目标怪兽送回手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- 效果③的发动时点处理函数，计算伤害并设置目标
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查场上是否存在纠罪指示物
	if Duel.GetCounter(tp,1,0,0x71)>0 then
		-- 计算伤害值，为指示物数量乘以900
		local dam=Duel.GetCounter(tp,1,0,0x71)*900
		-- 设置伤害目标为对方玩家
		Duel.SetTargetPlayer(1-tp)
		-- 设置伤害值参数
		Duel.SetTargetParam(dam)
		-- 设置效果③的处理信息，包括伤害类型和伤害值
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
end
-- 定义用于筛选拥有纠罪指示物的怪兽的过滤函数
function s.ctfilter(c)
	return c:GetCounter(0x71)>0
end
-- 效果③的处理函数，移除指示物并造成伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有拥有纠罪指示物的怪兽
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
		-- 对对方造成伤害，伤害值为指示物数量乘以900
		Duel.Damage(1-tp,rmct*900,REASON_EFFECT)
	end
end
