--ヴァルモニカの神異－ゼブフェーラ
-- 效果：
-- 效果怪兽1只
-- 这张卡的连接召唤若非自己的灵摆区域的恶魔族怪兽卡的响鸣指示物是3个以上的场合则不能进行，自己对「异响鸣之神异-风暴恶魔」1回合只能有1次特殊召唤。
-- ①：自己场上的卡被战斗·效果破坏的场合，可以作为代替把自己的灵摆区域3个响鸣指示物取除。
-- ②：对方回合1次，以自己的墓地·除外状态的1张「异响鸣」通常魔法·通常陷阱卡为对象才能发动。那张魔法·陷阱卡发动时的效果适用。
local s,id,o=GetID()
-- 初始化卡片效果：设置连接召唤手续、连接召唤的特殊召唤代价（e1）、破坏代替的永续效果（e2）以及复制墓地·除外「异响鸣」通常魔法·陷阱效果的诱发即时效果（e3）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：以1只效果怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),1,1)
	-- 这张卡的连接召唤若非自己的灵摆区域的恶魔族怪兽卡的响鸣指示物是3个以上的场合则不能进行
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_COST)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCost(s.spcost)
	c:RegisterEffect(e1)
	c:SetSPSummonOnce(id)
	-- ①：自己场上的卡被战斗·效果破坏的场合，可以作为代替把自己的灵摆区域3个响鸣指示物取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.desreptg)
	e2:SetValue(s.desrepval)
	e2:SetOperation(s.desrepop)
	c:RegisterEffect(e2)
	-- ②：对方回合1次，以自己的墓地·除外状态的1张「异响鸣」通常魔法·通常陷阱卡为对象才能发动。那张魔法·陷阱卡发动时的效果适用。
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
-- 过滤函数：判断卡片是否为原本种族是恶魔族、原本种类是怪兽且放置有3个以上响鸣指示物的卡
function s.cfilter(c)
	return c:GetOriginalRace()&RACE_FIEND>0 and c:GetOriginalType()&TYPE_MONSTER>0 and c:GetCounter(0x6a)>2
end
-- 特殊召唤代价检查：若非连接召唤则直接允许，否则需满足灵摆区域存在符合条件的卡
function s.spcost(e,c,tp,st)
	if st&SUMMON_TYPE_LINK~=SUMMON_TYPE_LINK then return true end
	-- 检查自己的灵摆区域是否存在至少1张放置有3个以上响鸣指示物的恶魔族怪兽卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- 检查卡片组g中的卡合计能否取除3个以上响鸣指示物（统计每张卡最多可取除的指示物数量）
function s.desrepchk(g,tp)
	local tl=0
	-- 遍历卡片组g中的每一张卡
	for tc in aux.Next(g) do
		local ct=0
		for i=1,3 do
			if tc:IsCanRemoveCounter(tp,0x6a,i,REASON_COST) then ct=i end
		end
		tl=tl+ct
	end
	return tl>2
end
-- 破坏代替的过滤：判断被破坏的卡是否为因战斗·效果破坏（非代替破坏）的自己场上的卡
function s.desrepfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:IsControler(tp) and c:IsOnField()
end
-- 破坏代替的适用判定：检查是否有自己场上的卡被战斗·效果破坏，且灵摆区域的卡能合计取除3个响鸣指示物
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己灵摆区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if chk==0 then return eg:IsExists(s.desrepfilter,1,nil,tp)
		and g:CheckSubGroup(s.desrepchk,1,2) end
	-- 询问玩家是否发动破坏代替效果（选择是则代替破坏）
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 判断被破坏的卡c是否满足破坏代替的适用条件（自己场上因战斗·效果破坏的卡）
function s.desrepval(e,c)
	return s.desrepfilter(c,e:GetHandlerPlayer())
end
-- 破坏代替的处理：显示卡片动画后，从灵摆区域的卡上逐个取除共3个响鸣指示物
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 向对方显示此卡发动的动画提示
	Duel.Hint(HINT_CARD,0,id)
	-- 获取自己灵摆区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	local ct=0
	while ct<3 do
		-- 提示玩家选择1张表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		local tc=g:FilterSelect(tp,Card.IsCanRemoveCounter,1,1,nil,tp,0x6a,1,REASON_COST):GetFirst()
		tc:RemoveCounter(tp,0x6a,1,REASON_COST)
		ct=ct+1
	end
end
-- ②效果的发动条件：当前回合为对方回合
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤函数：判断卡片是否为表侧表示（含除外）的「异响鸣」通常魔法·通常陷阱卡，且其发动时的效果可以适用
function s.filter(c)
	local typ=c:GetType()
	return c:IsFaceupEx() and c:IsSetCard(0x1a3) and (typ==TYPE_SPELL or typ==TYPE_TRAP)
		and c:CheckActivateEffect(false,true,false)
end
-- ②效果的对象选择与目标处理：选择自己墓地·除外状态的1张「异响鸣」通常魔法·通常陷阱卡，取得其发动时的效果并转交给本连锁处理
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 检查自己的墓地·除外状态是否存在可以成为对象的1张符合条件的「异响鸣」通常魔法·通常陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 以自己墓地·除外状态的1张「异响鸣」通常魔法·通常陷阱卡为对象
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil):GetFirst()
	local te,ceg,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	-- 清除当前连锁的对象（使复制的效果对象不被视为本连锁对象）
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除连锁1的操作信息（复制的魔法·陷阱效果不应当被响应）
	Duel.ClearOperationInfo(0)
end
-- ②效果的处理：确认对象卡仍与此效果关联后，执行那张魔法·陷阱卡发动时的效果处理
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not (te and te:GetHandler():IsRelateToEffect(e)) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
