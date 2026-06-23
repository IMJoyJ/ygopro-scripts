--ヴァルモニカの神異－ゼブフェーラ
-- 效果：
-- 效果怪兽1只
-- 这张卡的连接召唤若非自己的灵摆区域的恶魔族怪兽卡的响鸣指示物是3个以上的场合则不能进行，自己对「异响鸣之神异-风暴恶魔」1回合只能有1次特殊召唤。
-- ①：自己场上的卡被战斗·效果破坏的场合，可以作为代替把自己的灵摆区域3个响鸣指示物取除。
-- ②：对方回合1次，以自己的墓地·除外状态的1张「异响鸣」通常魔法·通常陷阱卡为对象才能发动。那张魔法·陷阱卡发动时的效果适用。
local s,id,o=GetID()
-- 初始化效果函数，设置连接召唤条件、特殊召唤代价、代替破坏效果和诱发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用1张效果怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),1,1)
	-- 设置特殊召唤代价效果，消耗灵摆区域的响鸣指示物
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_COST)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCost(s.spcost)
	c:RegisterEffect(e1)
	c:SetSPSummonOnce(id)
	-- 设置代替破坏效果，当自己场上的卡被战斗或效果破坏时，可以消耗灵摆区域的响鸣指示物代替破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.desreptg)
	e2:SetValue(s.desrepval)
	e2:SetOperation(s.desrepop)
	c:RegisterEffect(e2)
	-- 设置诱发即时效果，对方回合时可以发动，将墓地或除外状态的「异响鸣」魔法或陷阱卡的效果发动
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.cpcon)
	e3:SetTarget(s.cptg)
	e3:SetOperation(s.cpop)
	c:RegisterEffect(e3)
end
-- 过滤函数，判断灵摆区域的卡是否为恶魔族怪兽且响鸣指示物数量大于2
function s.cfilter(c)
	return c:GetOriginalRace()&RACE_FIEND>0 and c:GetOriginalType()&TYPE_MONSTER>0 and c:GetCounter(0x6a)>2
end
-- 特殊召唤代价函数，若为连接召唤则检查灵摆区域是否有满足条件的卡
function s.spcost(e,c,tp,st)
	if st&SUMMON_TYPE_LINK~=SUMMON_TYPE_LINK then return true end
	-- 检查灵摆区域是否存在满足条件的卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- 检查子函数，判断灵摆区域卡组是否能提供足够的响鸣指示物
function s.desrepchk(g,tp)
	local tl=0
	-- 遍历灵摆区域的卡组
	for tc in aux.Next(g) do
		local ct=0
		for i=1,3 do
			if tc:IsCanRemoveCounter(tp,0x6a,i,REASON_COST) then ct=i end
		end
		tl=tl+ct
	end
	return tl>2
end
-- 过滤函数，判断卡是否因战斗或效果被破坏且未被代替破坏
function s.desrepfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:IsControler(tp) and c:IsOnField()
end
-- 代替破坏的触发函数，检查是否有满足条件的卡被破坏且灵摆区域有足够指示物
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己灵摆区域的卡组
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if chk==0 then return eg:IsExists(s.desrepfilter,1,nil,tp)
		and g:CheckSubGroup(s.desrepchk,1,2) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的值函数，返回是否满足代替破坏条件
function s.desrepval(e,c)
	return s.desrepfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理函数，移除灵摆区域的响鸣指示物
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动卡片效果
	Duel.Hint(HINT_CARD,0,id)
	-- 获取自己灵摆区域的卡组
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	local ct=0
	while ct<3 do
		-- 提示选择表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		local tc=g:FilterSelect(tp,Card.IsCanRemoveCounter,1,1,nil,tp,0x6a,1,REASON_COST):GetFirst()
		tc:RemoveCounter(tp,0x6a,1,REASON_COST)
		ct=ct+1
	end
end
-- 诱发效果的发动条件函数，判断是否为对方回合
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤函数，判断墓地或除外状态的卡是否为「异响鸣」魔法或陷阱卡且可发动
function s.filter(c)
	local typ=c:GetType()
	return c:IsFaceupEx() and c:IsSetCard(0x1a3) and (typ==TYPE_SPELL or typ==TYPE_TRAP)
		and c:CheckActivateEffect(false,true,false)
end
-- 诱发效果的目标选择函数，选择目标卡并设置其效果
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 检查是否有满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标卡
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil):GetFirst()
	local te,ceg,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	-- 清除当前连锁的目标卡
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息
	Duel.ClearOperationInfo(0)
end
-- 诱发效果的处理函数，执行目标卡的效果
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not (te and te:GetHandler():IsRelateToEffect(e)) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
