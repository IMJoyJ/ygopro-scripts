--糾罪都市－エニアポリス
-- 效果：
-- 这个卡名在规则上也当作「纠罪巧」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上的「纠罪巧」灵摆怪兽卡任意数量为对象才能发动。那些卡回到手卡。
-- ②：自己场上的「纠罪巧」灵摆怪兽在主要阶段反转的场合才能发动。选那之内的1只回到手卡或在自己的灵摆区域放置。
-- ③：自己·对方的结束阶段发动。自己场上的纠罪指示物全部取除，对方受到那个数量×900伤害。
local s,id,o=GetID()
-- 初始化卡片效果：注册场地卡发动用的空效果e1、①效果e2（取对象的回手起动效果，1回合1次）、②效果e3（灵摆怪兽反转时诱发的选发效果，1回合1次）、③效果e4（结束阶段必发的取除指示物并造成伤害的效果）
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
	-- 为这张卡注册监听EVENT_FLIP（反转）事件的合并延迟事件，使②效果在同一连锁中只触发一次
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
-- 过滤函数：筛选自己场上表侧表示的原本种类为灵摆怪兽的「纠罪巧」怪兽卡
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d4) and c:GetOriginalType()&TYPE_PENDULUM~=0
end
-- ①效果的对象选择处理：确认场上存在可作为对象的「纠罪巧」灵摆怪兽，提示并选择任意数量（1～99张）作为对象，并设置回到手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 发动条件检测：确认自己场上存在至少1张可以成为对象的表侧表示「纠罪巧」灵摆怪兽卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家提示「请选择要返回手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择自己场上1～99张表侧表示的「纠罪巧」灵摆怪兽卡作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,99,nil)
	-- 设置操作信息：将选择的卡作为回到手卡效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- ①效果的处理：取得与本连锁关联的对象卡，将它们回到持有者的手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得与本连锁关联（仍满足对象条件）的卡组
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 then
		-- 将那些对象卡回到持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤函数：筛选自己怪兽区域表侧表示的「纠罪巧」怪兽，且自己的灵摆区域有空位或该卡可以回到手卡
function s.pthfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x1d4) and c:IsControler(tp) and c:IsFaceup()
		-- 检查自己的灵摆区域左端（0号位）是否有空格可用
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0)
		-- 或者检查自己的灵摆区域右端（1号位）是否有空格可用
		or Duel.CheckLocation(tp,LOCATION_PZONE,1)
		or c:IsAbleToHand())
end
-- ②效果的发动条件：反转的怪兽中存在满足条件的自己场上「纠罪巧」灵摆怪兽，且当前处于主要阶段
function s.pthcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.pthfilter,1,nil,tp)
		-- 并且当前处于主要阶段
		and Duel.IsMainPhase()
end
-- ②效果的目标处理：筛选出满足条件的反转怪兽，发动时要求至少存在1只，并将它们设为本连锁的对象
function s.pthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.pthfilter,nil,tp)
	if chk==0 then return #g>0 end
	-- 将筛选出的反转怪兽设置为本连锁的对象（广义对象）
	Duel.SetTargetCard(g)
end
-- ②效果的处理：从满足条件的反转怪兽中选1只，让玩家选择将其在自己的灵摆区域放置或回到手卡，并执行对应处理
function s.pthop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.pthfilter,nil,tp)
	local mg=g:Filter(Card.IsRelateToChain,nil)
	if mg:GetCount()>0 then
		-- 向玩家提示「请选择效果的对象」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		local og=mg:Select(tp,1,1,nil)
		-- 为选出的那只怪兽显示被选为对象的动画并记录为对象
		Duel.HintSelection(og)
		local tc=og:GetFirst()
		-- 判断自己的灵摆区域是否有空格可用（作为「放置灵摆区域」选项的有效性）
		local b1=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
		local b2=tc:IsAbleToHand()
		-- 让玩家从「放置灵摆区域」和「加入手卡」两个选项中选择处理方式
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,3),1},  --"放置灵摆区域"
			{b2,aux.Stringid(id,4),2})  --"加入手卡"
		if op==1 then
			if not tc:IsImmuneToEffect(e) then
				-- 将那只怪兽表侧表示移动到自己的灵摆区域并立即适用其效果
				Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		else
			-- 将那只怪兽回到持有者的手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- ③效果的目标处理：计算自己场上纠罪指示物的数量，将对象玩家设为对方、对象参数设为指示物数量×900的伤害值，并设置伤害操作信息
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检测自己场上是否存在纠罪指示物（存在才设置伤害信息）
	if Duel.GetCounter(tp,1,0,0x71)>0 then
		-- 计算伤害值：自己场上的纠罪指示物数量×900
		local dam=Duel.GetCounter(tp,1,0,0x71)*900
		-- 将本连锁的对象玩家设置为对方玩家
		Duel.SetTargetPlayer(1-tp)
		-- 将本连锁的对象参数设置为伤害数值
		Duel.SetTargetParam(dam)
		-- 设置操作信息：对对方造成dam点伤害的伤害效果
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
end
-- 过滤函数：筛选放置有纠罪指示物的卡
function s.ctfilter(c)
	return c:GetCounter(0x71)>0
end
-- ③效果的处理：取除自己场上全部的纠罪指示物并累计数量，给对方造成那个数量×900的伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上所有放置有纠罪指示物的卡
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
		-- 以效果原因给对方造成取除的纠罪指示物数量×900的伤害
		Duel.Damage(1-tp,rmct*900,REASON_EFFECT)
	end
end
