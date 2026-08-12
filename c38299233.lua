--ニードル・ウォール
-- 效果：
-- 自己的准备阶段时投掷1个骰子。对方的主要怪兽区域，这张卡的控制者从右面看起对应的怪兽区的怪兽算1至5，投掷出的数目对应的怪兽破坏。投掷出6的场合再投掷1次。
function c38299233.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 创建一个诱发必发效果，用于在准备阶段时触发骰子投掷和破坏效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38299233,0))  --"投掷骰子"
	e2:SetCategory(CATEGORY_DICE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c38299233.rdcon)
	e2:SetTarget(c38299233.rdtg)
	e2:SetOperation(c38299233.rdop)
	c:RegisterEffect(e2)
end
-- 效果条件函数，判断是否为当前回合玩家
function c38299233.rdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家是否为回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 过滤函数，用于筛选对方主要怪兽区域中序号小于5的怪兽
function c38299233.mzfilter(c)
	return c:GetSequence()<5
end
-- 效果目标设定函数，设置骰子投掷和可能的破坏目标
function c38299233.rdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，声明将进行一次骰子投掷
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	-- 获取对方主要怪兽区域中满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c38299233.mzfilter,tp,0,LOCATION_MZONE,nil)
	if #g>=5 then
		-- 设置操作信息，若对方怪兽区有5只怪兽则会破坏其中一只
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理函数，执行骰子投掷并根据结果破坏对应位置的怪兽
function c38299233.rdop(e,tp,eg,ep,ev,re,r,rp)
	local d1=6
	while d1==6 do
		-- 让当前玩家投掷一次骰子
		d1=Duel.TossDice(tp,1)
	end
	if d1>5 then return end
	-- 获取对方怪兽区中对应骰子结果位置的怪兽
	local tc=Duel.GetFieldCard(1-tp,LOCATION_MZONE,d1-1)
	if tc then
		-- 将指定怪兽因效果而破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
