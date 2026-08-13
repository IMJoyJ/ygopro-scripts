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
	-- 自己的准备阶段时投掷1个骰子。对方的主要怪兽区域，这张卡的控制者从右面看起对应的怪兽区的怪兽算1至5，投掷出的数目对应的怪兽破坏。投掷出6的场合再投掷1次。
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
-- 效果发动条件判断：只有在己方准备阶段且当前回合玩家是自己时，才会触发该效果。
function c38299233.rdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果控制者（即自己），如果是则条件成立，允许效果发动。
	return tp==Duel.GetTurnPlayer()
end
-- 怪兽区域过滤函数：只筛选位于主要怪兽区域（序号0-4）的怪兽，排除额外怪兽区域（序号5-6）。
function c38299233.mzfilter(c)
	return c:GetSequence()<5
end
-- 效果发动时的目标设定：声明该效果涉及骰子和破坏；获取对方场上主要怪兽区域的怪兽组，若怪兽数量达到5只以上，则预设破坏对象信息用于后续处理。
function c38299233.rdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定操作信息：告知系统本次连锁包含骰子相关效果，且由控制者投掷1次骰子。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	-- 获取对方场上所有符合mzfilter条件的怪兽（即对方主要怪兽区域的怪兽），作为可能被破坏的候选集合。
	local g=Duel.GetMatchingGroup(c38299233.mzfilter,tp,0,LOCATION_MZONE,nil)
	if #g>=5 then
		-- 设定操作信息：如果对方主要怪兽区域存在至少5只怪兽，则预设破坏其中1只怪兽的对象信息，用于满足破坏效果的结算预判。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理操作：实际投掷骰子，若掷出6则重投直到不是6为止；然后根据骰子点数找到对方相应主要怪兽区域的怪兽并破坏。
function c38299233.rdop(e,tp,eg,ep,ev,re,r,rp)
	local d1=6
	while d1==6 do
		-- 由效果控制者投掷1次骰子，返回点数1-6。
		d1=Duel.TossDice(tp,1)
	end
	if d1>5 then return end
	-- 根据骰子点数（d1-1得到序号）获取对方位于该主要怪兽区域的怪兽卡；官方以右面看起对应序号，而字段序号从左到右为0-4，因此用点数-1对应从左到右的格子。
	local tc=Duel.GetFieldCard(1-tp,LOCATION_MZONE,d1-1)
	if tc then
		-- 以效果为破坏原因，将选中的怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
