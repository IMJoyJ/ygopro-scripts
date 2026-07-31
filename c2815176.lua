--ヴァルモニカの神異－ゼブフェーラ
-- 效果：
-- 效果怪兽1只
-- 这张卡的连接召唤若非自己的灵摆区域的恶魔族怪兽卡的响鸣指示物是3个以上的场合则不能进行，自己对「异响鸣之神异-风暴恶魔」1回合只能有1次特殊召唤。
-- ①：自己场上的卡被战斗·效果破坏的场合，可以作为代替把自己的灵摆区域3个响鸣指示物取除。
-- ②：对方回合1次，以自己的墓地·除外状态的1张「异响鸣」通常魔法·通常陷阱卡为对象才能发动。那张魔法·陷阱卡发动时的效果适用。
local s,id,o=GetID()
-- 定义卡片初始效果函数，启用复活限制，添加连接召唤流程，注册各种效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为当前卡片添加连接召唤手续，要求至少一个恶魔族效果怪兽作为素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),1,1)
	-- 创建单次效果，设置特殊召唤代价，使其不可被无效或复制。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_COST)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCost(s.spcost)
	c:RegisterEffect(e1)
	c:SetSPSummonOnce(id)
	-- 创建场上永续效果，用于代替破坏，设定目标和值，并注册效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.desreptg)
	e2:SetValue(s.desrepval)
	e2:SetOperation(s.desrepop)
	c:RegisterEffect(e2)
	-- 创建快速发动效果，设置描述、类型、代码、范围、次数限制、属性，并注册效果。
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
s.mentioned_counter={
	[0x6a]=true,
}
-- 定义一个过滤函数，用于筛选满足连接召唤条件的恶魔族怪兽。
function s.cfilter(c)
	return c:GetOriginalRace()&RACE_FIEND>0 and c:GetOriginalType()&TYPE_MONSTER>0 and c:GetCounter(0x6a)>2
end
-- 定义特殊召唤代价的判定函数，检查是否为连接召唤且灵摆区存在符合条件的卡片。
function s.spcost(e,c,tp,st)
	if st&SUMMON_TYPE_LINK~=SUMMON_TYPE_LINK then return true end
	-- 判断是否存在满足连接召唤条件的卡片。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- 定义一个辅助函数，用于检查指定卡组中响鸣指示物的数量是否大于2。
function s.desrepchk(g,tp)
	local tl=0
	-- 遍历卡组中的每张卡片。
	for tc in aux.Next(g) do
		local ct=0
		for i=1,3 do
			if tc:IsCanRemoveCounter(tp,0x6a,i,REASON_COST) then ct=i end
		end
		tl=tl+ct
	end
	return tl>2
end
-- 定义一个过滤函数，用于筛选被战斗或效果破坏且未被代替的、由当前玩家控制的场上卡片。
function s.desrepfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:IsControler(tp) and c:IsOnField()
end
-- 定义代替破坏效果的目标选择函数，检查是否存在满足条件的卡片并提示玩家选择。
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取当前玩家的灵摆区域卡组。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if chk==0 then return eg:IsExists(s.desrepfilter,1,nil,tp)
		and g:CheckSubGroup(s.desrepchk,1,2) end
	-- 让玩家确认是否发动代替效果。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 定义一个值设置函数，返回满足条件的卡片。
function s.desrepval(e,c)
	return s.desrepfilter(c,e:GetHandlerPlayer())
end
-- 定义代替破坏效果的操作函数，提示卡片、移除响鸣指示物。
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示当前卡片的动画提示。
	Duel.Hint(HINT_CARD,0,id)
	-- 获取当前玩家的灵摆区域卡组。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	local ct=0
	while ct<3 do
		-- 提示玩家选择表侧表示的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		local tc=g:FilterSelect(tp,Card.IsCanRemoveCounter,1,1,nil,tp,0x6a,1,REASON_COST):GetFirst()
		tc:RemoveCounter(tp,0x6a,1,REASON_COST)
		ct=ct+1
	end
end
-- 定义一个条件函数，用于判断是否为对方回合。
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为对方的回合。
	return Duel.GetTurnPlayer()==1-tp
end
-- 定义一个过滤函数，筛选墓地或除外区的、表侧表示的、属于特定卡组的通常魔法/陷阱卡。
function s.filter(c)
	local typ=c:GetType()
	return c:IsFaceupEx() and c:IsSetCard(0x1a3) and (typ==TYPE_SPELL or typ==TYPE_TRAP)
		and c:CheckActivateEffect(false,true,false)
end
-- 定义快速发动效果的目标选择函数，检查目标是否存在并进行选择。
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 判断是否存在符合条件的卡片作为目标。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从墓地或除外区选择一张魔法/陷阱卡。
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil):GetFirst()
	local te,ceg,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	-- 清除当前连锁的目标卡片。
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除操作信息，防止不应被响应的效果被响应。
	Duel.ClearOperationInfo(0)
end
-- 定义快速发动效果的操作函数，获取标签对象并执行其效果。
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not (te and te:GetHandler():IsRelateToEffect(e)) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
