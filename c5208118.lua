--動点するP
-- 效果：
-- ①：自己·对方的准备阶段发动。给这张卡放置1个T指示物。
-- ②：1回合1次，以自己的主要怪兽区域1只灵摆怪兽为对象才能发动。让这张卡的T指示物数量的「作为对象的灵摆怪兽的位置向那个相邻的怪兽区域移动」处理重复。那之后，持有作为对象的怪兽的灵摆刻度数值以下的等级·阶级的融合·超量怪兽在和作为对象的怪兽相同纵列的对方场上存在的场合，那些全部破坏，给与对方那个攻击力合计数值的伤害。
local s,id,o=GetID()
-- 初始化效果，设置该卡可以放置T指示物，并注册准备阶段触发的指示物添加效果和灵摆怪兽移动效果
function s.initial_effect(c)
	c:EnableCounterPermit(0x73)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的准备阶段发动。给这张卡放置1个T指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己的主要怪兽区域1只灵摆怪兽为对象才能发动。让这张卡的T指示物数量的「作为对象的灵摆怪兽的位置向那个相邻的怪兽区域移动」处理重复。那之后，持有作为对象的怪兽的灵摆刻度数值以下的等级·阶级的融合·超量怪兽在和作为对象的怪兽相同纵列的对方场上存在的场合，那些全部破坏，给与对方那个攻击力合计数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.seqtg)
	e3:SetOperation(s.seqop)
	c:RegisterEffect(e3)
end
-- 指示物添加效果的目标设定函数，用于设置连锁操作信息
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息为放置1个T指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x73)
end
-- 指示物添加效果的执行函数，将1个T指示物放置到该卡上
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x73,1)
end
-- 判断灵摆怪兽是否可以移动到相邻区域的过滤器函数
function s.cfilter(c)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	if seq>4 or not c:IsType(TYPE_PENDULUM) or c:IsFacedown() then return false end
	-- 判断灵摆怪兽左侧相邻区域是否可用
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 判断灵摆怪兽右侧相邻区域是否可用
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 灵摆怪兽移动效果的目标选择函数，用于选择要移动的灵摆怪兽
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc) end
	-- 判断是否满足发动条件：该卡有T指示物且场上存在可移动的灵摆怪兽
	if chk==0 then return c:GetCounter(0x73)>0 and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要移动的灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"请选择移动位置的怪兽"
	-- 选择目标灵摆怪兽
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 获取融合或超量怪兽等级或阶级的辅助函数
function s.lv_or_rk(c)
	if c:IsType(TYPE_FUSION) then
		return c:GetLevel()
	elseif c:IsType(TYPE_XYZ) then
		return c:GetRank()
	end
	return 0
end
-- 破坏过滤器函数，用于筛选满足条件的融合或超量怪兽
function s.desfilter(c,tp,p)
	return c:IsFaceup() and c:IsControler(1-tp)
		and s.lv_or_rk(c)>0
		and s.lv_or_rk(c)<=p
end
-- 灵摆怪兽移动效果的执行函数，将目标灵摆怪兽按指示物数量移动到相邻区域，并对符合条件的对方怪兽进行破坏和伤害处理
function s.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	if c:GetCounter(0x73)==0 then return end
	local ct=c:GetCounter(0x73)
	while ct>0 do
		local seq=tc:GetSequence()
		if seq>4 then return end
		local flag=0
		-- 如果灵摆怪兽左侧区域可用，则将其加入可选区域标志位
		if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
		-- 如果灵摆怪兽右侧区域可用，则将其加入可选区域标志位
		if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
		if flag==0 then return end
		-- 提示玩家选择要移动到的位置
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
		-- 根据标志位选择一个可移动的区域
		local ss=Duel.SelectField(tp,1,LOCATION_MZONE,0,~flag)
		local nseq=math.log(ss,2)
		-- 将目标怪兽移动到指定位置
		Duel.MoveSequence(tc,nseq)
		ct=ct-1
	end
	if ct==0 then
		local g=tc:GetColumnGroup():Filter(s.desfilter,tc,tp,tc:GetLeftScale())
		if g:GetCount()>0 then
			-- 中断当前效果，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 破坏符合条件的融合或超量怪兽
			Duel.Destroy(g,REASON_EFFECT)
			-- 获取实际被破坏的卡片组
			local og=Duel.GetOperatedGroup()
			local dam=og:GetSum(Card.GetPreviousAttackOnField)
			if dam>0 then
				-- 对对方造成伤害，伤害值为被破坏怪兽攻击力总和
				Duel.Damage(1-tp,dam,REASON_EFFECT)
			end
		end
	end
end
