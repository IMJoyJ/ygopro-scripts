--出目出し
-- 效果：
-- 对方对怪兽的特殊召唤成功时，掷1次骰子。出现的数目和那特殊召唤的怪兽的等级相同的场合，那怪兽回到持有者手卡。
function c31863912.initial_effect(c)
	-- 效果原文：对方对怪兽的特殊召唤成功时，掷1次骰子。出现的数目和那特殊召唤的怪兽的等级相同的场合，那怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_SPSUMMON)
	e1:SetTarget(c31863912.target1)
	e1:SetOperation(c31863912.operation)
	c:RegisterEffect(e1)
	-- 效果原文：对方对怪兽的特殊召唤成功时，掷1次骰子。出现的数目和那特殊召唤的怪兽的等级相同的场合，那怪兽回到持有者手卡。
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
-- 检查目标怪兽是否为表侧表示且为对方特殊召唤的怪兽
function c31863912.cfilter(c,sp)
	return c:IsFaceup() and c:IsSummonPlayer(sp)
end
-- 检查是否为对方特殊召唤成功的时点，若是则设置标签为1并设置目标卡片和操作信息
function c31863912.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查当前是否为特殊召唤成功时点并获取相关信息
	local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if res and teg:IsExists(c31863912.cfilter,1,nil,1-tp) then
		e:SetLabel(1)
		-- 设置当前处理的连锁的目标卡片为特殊召唤成功的怪兽
		Duel.SetTargetCard(teg)
		-- 设置当前处理的连锁的操作信息为骰子效果和回手牌效果
		Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	else
		e:SetLabel(0)
	end
end
-- 检查是否为对方特殊召唤成功的时点，若是则设置目标卡片和操作信息
function c31863912.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c31863912.cfilter,1,nil,1-tp) end
	-- 设置当前处理的连锁的目标卡片为特殊召唤成功的怪兽
	Duel.SetTargetCard(eg)
	-- 设置当前处理的连锁的操作信息为骰子效果
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 检查目标怪兽是否为表侧表示且为对方特殊召唤的怪兽、等级匹配、可送入手牌且与效果相关
function c31863912.filter(c,sp,e,lv)
	return c:IsFaceup() and c:IsSummonPlayer(sp) and c:IsLevel(lv) and c:IsAbleToHand() and c:IsRelateToEffect(e)
end
-- 若标签为0或卡片与效果无关则返回，否则投掷骰子并筛选满足条件的怪兽送回手牌
function c31863912.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 让玩家投掷1次骰子并返回结果
	local dc=Duel.TossDice(tp,1)
	-- 根据骰子结果筛选满足等级条件的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c31863912.filter,nil,1-tp,e,dc)
	if g:GetCount()>0 then
		-- 将符合条件的怪兽送回持有者手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
