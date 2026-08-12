--動点するP
-- 效果：
-- ①：自己·对方的准备阶段发动。给这张卡放置1个T指示物。
-- ②：1回合1次，以自己的主要怪兽区域1只灵摆怪兽为对象才能发动。让这张卡的T指示物数量的「作为对象的灵摆怪兽的位置向那个相邻的怪兽区域移动」处理重复。那之后，持有作为对象的怪兽的灵摆刻度数值以下的等级·阶级的融合·超量怪兽在和作为对象的怪兽相同纵列的对方场上存在的场合，那些全部破坏，给与对方那个攻击力合计数值的伤害。
local s,id,o=GetID()
-- 初始化这张卡的效果：允许放置0x73（T）指示物，注册魔陷发动所需的空效果，并注册①放置指示物的效果和②移动位置·破坏·烧血的诱发即时效果
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
	-- ②：1回合1次，以自己的主要怪兽区域1只灵摆怪兽为对象才能发动。
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
s.mentioned_counter={
	[0x73]=true,
}
-- 放置指示物效果的对象确认：必定可以发动，并设置本连锁将放置1个T指示物的操作信息
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本连锁的操作信息为放置1个0x73（T）指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x73)
end
-- 放置指示物效果的处理：给这张卡放置1个T指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x73,1)
end
-- 筛选可作为对象的主要怪兽区域灵摆怪兽：需为表侧表示的主要怪兽区域灵摆怪兽，且其相邻的怪兽区域至少有1处空格可用
function s.cfilter(c)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	if seq>4 or not c:IsType(TYPE_PENDULUM) or c:IsFacedown() then return false end
	-- 若左侧相邻的怪兽区域有空位则该卡可作为对象
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 若右侧相邻的怪兽区域有空位则该卡也可作为对象
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- ②效果的对象确认：连锁处理中选择对象时校验目标是否为自己主要怪兽区域符合条件的灵摆怪兽；可发动性检查时要求这张卡持有T指示物且场上存在可作为对象的灵摆怪兽；发动时提示并选择1只作为对象的灵摆怪兽
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc) end
	-- 可发动性检查：这张卡需持有1个以上T指示物，且自己主要怪兽区域存在1只以上满足条件的可作为对象的灵摆怪兽
	if chk==0 then return c:GetCounter(0x73)>0 and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向发动方显示「请选择移动位置的怪兽」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"请选择移动位置的怪兽"
	-- 选择自己主要怪兽区域1只满足条件的灵摆怪兽作为效果对象
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 获取怪兽的等级或阶级：融合怪兽返回等级，超量怪兽返回阶级，其余返回0
function s.lv_or_rk(c)
	if c:IsType(TYPE_FUSION) then
		return c:GetLevel()
	elseif c:IsType(TYPE_XYZ) then
		return c:GetRank()
	end
	return 0
end
-- 破坏对象的筛选条件：对方场上表侧表示、等级·阶级在作为对象的怪兽的灵摆刻度数值以下的融合·超量怪兽
function s.desfilter(c,tp,p)
	return c:IsFaceup() and c:IsControler(1-tp)
		and s.lv_or_rk(c)>0
		and s.lv_or_rk(c)<=p
end
-- ②效果的处理：取得作为对象的怪兽并确认其仍与连锁关联、这张卡持有T指示物后，以T指示物的数量重复「让对象怪兽向相邻的可用怪兽区域移动」的处理；全部移动完成后，若与对象怪兽相同纵列的对方场上存在等级·阶级在其灵摆刻度以下的融合·超量怪兽，则将其全部破坏，并给与对方被破坏怪兽攻击力合计数值的伤害
function s.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象怪兽（作为对象的灵摆怪兽）
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	if c:GetCounter(0x73)==0 then return end
	local ct=c:GetCounter(0x73)
	while ct>0 do
		local seq=tc:GetSequence()
		if seq>4 then return end
		local flag=0
		-- 若左侧相邻的主要怪兽区域有空位，则将该区域标记为可移动目标位置
		if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
		-- 若右侧相邻的主要怪兽区域有空位，则将该区域标记为可移动目标位置
		if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
		if flag==0 then return end
		-- 向发动方显示「请选择要移动到的位置」的选择提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
		-- 让发动方从自己主要怪兽区域的可移动位置中选择1处作为移动目标
		local ss=Duel.SelectField(tp,1,LOCATION_MZONE,0,~flag)
		local nseq=math.log(ss,2)
		-- 将作为对象的怪兽移动到所选的主要怪兽区域位置
		Duel.MoveSequence(tc,nseq)
		ct=ct-1
	end
	if ct==0 then
		local g=tc:GetColumnGroup():Filter(s.desfilter,tc,tp,tc:GetLeftScale())
		if g:GetCount()>0 then
			-- 中断当前效果处理，使之后的破坏处理与前面的移动不视为同时处理
			Duel.BreakEffect()
			-- 以效果破坏同纵列对方场上满足条件的全部融合·超量怪兽
			Duel.Destroy(g,REASON_EFFECT)
			-- 取得刚才破坏操作实际破坏的怪兽组
			local og=Duel.GetOperatedGroup()
			local dam=og:GetSum(Card.GetPreviousAttackOnField)
			if dam>0 then
				-- 给与对方被破坏怪兽在场上时的攻击力合计数值的效果伤害
				Duel.Damage(1-tp,dam,REASON_EFFECT)
			end
		end
	end
end
