--天使の聲
-- 效果：
-- ←3 【灵摆】 3→
-- ①：只要另一边的自己的灵摆区域有恶魔族怪兽卡存在，每次自己基本分回复，给这张卡放置1个响鸣指示物。
-- ②：1回合1次，对方怪兽的攻击宣言时才能发动。进行1只「异响鸣」连接怪兽的连接召唤。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从手卡丢弃1张其他卡才能发动。从卡组选1只「恶魔之声」，这张卡和那张卡在自己的灵摆区域放置。
-- ②：这张卡召唤·特殊召唤的回合的自己主要阶段，从自己墓地把1张「异响鸣」通常魔法·通常陷阱卡除外才能发动。那张魔法·陷阱卡发动时的回复基本分的选项的效果适用。
local s,id,o=GetID()
-- 初始化卡片效果，注册灵摆属性、计数器、各效果
function s.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x6a,LOCATION_PZONE)
	-- ①：只要另一边的自己的灵摆区域有恶魔族怪兽卡存在，每次自己基本分回复，给这张卡放置1个响鸣指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_RECOVER)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方怪兽的攻击宣言时才能发动。进行1只「异响鸣」连接怪兽的连接召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.lscon)
	e2:SetTarget(s.lstg)
	e2:SetOperation(s.lsop)
	c:RegisterEffect(e2)
	-- ①：这张卡在手卡存在的场合，从手卡丢弃1张其他卡才能发动。从卡组选1只「恶魔之声」，这张卡和那张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"这张卡和卡组的「恶魔之声」一起放置"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.pzcost)
	e3:SetTarget(s.pztg)
	e3:SetOperation(s.pzop)
	c:RegisterEffect(e3)
	-- ②：这张卡召唤·特殊召唤的回合的自己主要阶段，从自己墓地把1张「异响鸣」通常魔法·通常陷阱卡除外才能发动。那张魔法·陷阱卡发动时的回复基本分的选项的效果适用。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.cpcon)
	e4:SetTarget(s.cptg)
	e4:SetOperation(s.cpop)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		-- 全局注册召唤和特殊召唤成功时的处理效果，用于记录卡片是否在召唤或特殊召唤回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(id)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置全局效果的处理函数为aux.sumreg，用于记录召唤或特殊召唤的卡片
		ge1:SetOperation(aux.sumreg)
		-- 将全局效果注册到玩家0（即所有玩家）
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 将全局效果注册到玩家0（即所有玩家）
		Duel.RegisterEffect(ge2,0)
	end
end
-- 过滤函数，用于判断灵摆区域是否存在恶魔族怪兽
function s.cfilter(c)
	return c:GetOriginalRace()&RACE_FIEND>0 and c:GetOriginalType()&TYPE_MONSTER>0
end
-- 判断是否满足①效果的条件：灵摆区域存在恶魔族怪兽且是自己回复基本分
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查灵摆区域是否存在恶魔族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
		and ep==tp
end
-- 当满足条件时，给卡片添加一个响鸣指示物，若达到3个则触发事件
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x6a,1)
	if c:GetCounter(0x6a)==3 then
		-- 触发自定义事件，用于触发卡片效果
		Duel.RaiseEvent(c,EVENT_CUSTOM+39210885,e,0,tp,tp,0)
	end
end
-- 判断是否满足②效果的条件：当前为对方回合
function s.lscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤函数，用于筛选可连接召唤的「异响鸣」连接怪兽
function s.lfilter(c)
	return c:IsLinkSummonable(nil) and c:IsSetCard(0x1a3)
end
-- 设置②效果的目标，检查是否存在可连接召唤的「异响鸣」连接怪兽
function s.lstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可连接召唤的「异响鸣」连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.lfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息，表示将要特殊召唤一只连接怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理函数，选择并连接召唤一只「异响鸣」连接怪兽
function s.lsop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的连接怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一只满足条件的连接怪兽
	local tc=Duel.SelectMatchingCard(tp,s.lfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	-- 执行连接召唤
	if tc then Duel.LinkSummon(tp,tc,nil) end
end
-- ①效果的处理函数，丢弃一张手牌作为代价
function s.pzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足丢弃手牌的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	-- 执行丢弃手牌的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,c)
end
-- 过滤函数，用于筛选卡组中的「恶魔之声」
function s.filter(c)
	return c:IsCode(30432463) and not c:IsForbidden()
end
-- ①效果的目标函数，检查是否满足放置条件
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查灵摆区域是否空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1)
		-- 检查卡组中是否存在「恶魔之声」
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果的处理函数，将卡片和「恶魔之声」放置到灵摆区域
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡片是否有效且灵摆区域是否空位
	if not (c:IsRelateToEffect(e) and Duel.CheckLocation(tp,LOCATION_PZONE,0)
		-- 检查灵摆区域是否空位
		and Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	-- 提示玩家选择要放置的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择一张「恶魔之声」
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		-- 将卡片放置到灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		-- 将「恶魔之声」放置到灵摆区域
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- ②效果的条件函数，判断是否在召唤或特殊召唤回合
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 过滤函数，用于筛选墓地中的「异响鸣」魔法或陷阱卡
function s.pfilter(c)
	local typ=c:GetType()
	return c:IsSetCard(0x1a3) and (typ==TYPE_SPELL or typ==TYPE_TRAP) and c:IsAbleToRemoveAsCost()
		and c:CheckActivateEffect(false,true,false)
end
-- ②效果的目标函数，检查是否满足除外并发动效果的条件
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查墓地中是否存在满足条件的「异响鸣」魔法或陷阱卡
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张满足条件的魔法或陷阱卡
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	e:SetLabelObject(te)
	-- 将选中的卡除外作为代价
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息
	Duel.ClearOperationInfo(0)
end
-- ②效果的处理函数，发动选中的魔法或陷阱卡的效果
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp,1) end
end
