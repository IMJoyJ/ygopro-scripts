--出目出し
-- 效果：
-- 对方对怪兽的特殊召唤成功时，掷1次骰子。出现的数目和那特殊召唤的怪兽的等级相同的场合，那怪兽回到持有者手卡。
function c31863912.initial_effect(c)
	-- 对方对怪兽的特殊召唤成功时，掷1次骰子。出现的数目和那特殊召唤的怪兽的等级相同的场合，那怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_SPSUMMON)
	e1:SetTarget(c31863912.target1)
	e1:SetOperation(c31863912.operation)
	c:RegisterEffect(e1)
	-- 对方对怪兽的特殊召唤成功时，掷1次骰子。出现的数目和那特殊召唤的怪兽的等级相同的场合，那怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31863912,0))  --"投掷骰子"
	e1:SetCategory(CATEGORY_DICE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c31863912.target2)
	e2:SetOperation(c31863912.operation)
	e2:SetLabel(1)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为表侧表示，并且是由玩家sp特殊召唤的。
function c31863912.cfilter(c,sp)
	return c:IsFaceup() and c:IsSummonPlayer(sp)
end
-- e1的发动目标判定：检查当前是否为对方特殊召唤成功时点且存在对方特殊召唤的怪兽，若是则设置标签、将特殊召唤成功的怪兽设为对象并登记掷骰子效果信息；否则将标签设为0，使效果处理时不执行。
function c31863912.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查并获取当前事件是否为特殊召唤成功事件，teg为特殊召唤成功的怪兽集合。
	local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if res and teg:IsExists(c31863912.cfilter,1,nil,1-tp) then
		e:SetLabel(1)
		-- 将特殊召唤成功的那组怪兽设置为当前连锁的对象，使后续可通过CHAININFO_TARGET_CARDS取得它们。
		Duel.SetTargetCard(teg)
		-- 向系统登记本效果包含骰子分类，由tp玩家掷1次骰子，用于骰子相关效果的检测。
		Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	else
		e:SetLabel(0)
	end
end
-- e2的诱发效果发动判定：只要存在对方特殊召唤的表侧表示怪兽即可发动，并将这些特殊召唤成功的怪兽设为对象，同时登记掷骰子效果信息。
function c31863912.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c31863912.cfilter,1,nil,1-tp) end
	-- 将特殊召唤成功的那组怪兽设置为当前连锁的对象，确保效果处理时能正确筛选目标。
	Duel.SetTargetCard(eg)
	-- 向系统登记本效果包含骰子分类，由tp玩家掷1次骰子。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 筛选回手目标的条件：怪兽表侧表示、由对方特殊召唤、等级等于骰子点数、可以加入手卡，并且与当前效果仍有关联。
function c31863912.filter(c,sp,e,lv)
	return c:IsFaceup() and c:IsSummonPlayer(sp) and c:IsLevel(lv) and c:IsAbleToHand() and c:IsRelateToEffect(e)
end
-- 效果处理：若标签为0或卡片不关联则直接结束；否则掷1次骰子，从对象中筛出符合条件的怪兽并返回持有者手卡。
function c31863912.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 让tp玩家投掷1次骰子，得到点数dc。
	local dc=Duel.TossDice(tp,1)
	-- 从当前连锁的对象中筛选出满足条件（对方特殊召唤、等级等于dc、可回手且与效果关联）的怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c31863912.filter,nil,1-tp,e,dc)
	if g:GetCount()>0 then
		-- 将筛选出的怪兽送回其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
