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
-- 初始化卡片效果，注册所有灵摆和怪兽效果的函数
function s.initial_effect(c)
	-- 为灵摆怪兽c添加灵摆怪兽属性，使其可以进行灵摆召唤
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x6a,LOCATION_PZONE)
	-- ①：只要另一边的自己的灵摆区域有恶魔族怪兽卡存在，每次自己基本分回复，给这张卡放置1个响鸣指示物
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_RECOVER)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方怪兽的攻击宣言时才能发动。进行1只「异响鸣」连接怪兽的连接召唤
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
	-- ①：这张卡在手卡存在的场合，从手卡丢弃1张其他卡才能发动。从卡组选1只「恶魔之声」，这张卡和那张卡在自己的灵摆区域放置
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"这张卡和卡组的「恶魔之声」一起放置"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.pzcost)
	e3:SetTarget(s.pztg)
	e3:SetOperation(s.pzop)
	c:RegisterEffect(e3)
	-- ②：这张卡召唤·特殊召唤的回合的自己主要阶段，从自己墓地把1张「异响鸣」通常魔法·通常陷阱卡除外才能发动。那张魔法·陷阱卡发动时的回复基本分的选项的效果适用
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
		-- 处理「召唤·特殊召唤的回合」效果的全局注册，监听通常召唤和特殊召唤成功事件
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(id)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 使用aux.sumreg处理召唤成功事件，记录这张卡被召唤的回合信息
		ge1:SetOperation(aux.sumreg)
		-- 为0号玩家（双方）注册监听通常召唤成功的全局效果
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 为0号玩家（双方）注册监听特殊召唤成功的全局效果
		Duel.RegisterEffect(ge2,0)
	end
end
s.mentioned_counter={
	[0x6a]=true,
}
-- 定义过滤器函数，检查卡片是否为恶魔族怪兽
function s.cfilter(c)
	return c:GetOriginalRace()&RACE_FIEND>0 and c:GetOriginalType()&TYPE_MONSTER>0
end
-- 灵摆效果1的触发条件：自己的灵摆区域存在恶魔族怪兽且回复生命的是自己
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域是否存在恶魔族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
		and ep==tp
end
-- 灵摆效果1的处理：放置响鸣指示物，达到3个时触发特殊事件
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x6a,1)
	if c:GetCounter(0x6a)==3 then
		-- 当响鸣指示物达到3个时，触发自定义事件39210885
		Duel.RaiseEvent(c,EVENT_CUSTOM+39210885,e,0,tp,tp,0)
	end
end
-- 灵摆效果2的触发条件：对方回合
function s.lscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 定义过滤器函数，检查卡片是否为「异响鸣」连接怪兽且可连接召唤
function s.lfilter(c)
	return c:IsLinkSummonable(nil) and c:IsSetCard(0x1a3)
end
-- 灵摆效果2的伤害步骤前处理，设置特殊召唤操作信息
function s.lstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可连接召唤的「异响鸣」连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.lfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置特殊召唤的分类信息为目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 灵摆效果2的具体操作：选择并连接召唤「异响鸣」连接怪兽
function s.lsop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1只「异响鸣」连接怪兽
	local tc=Duel.SelectMatchingCard(tp,s.lfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	-- 执行连接召唤
	if tc then Duel.LinkSummon(tp,tc,nil) end
end
-- 怪兽效果1的cost：丢弃1张手牌
function s.pzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手牌是否有可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	-- 丢弃1张手牌作为cost
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,c)
end
-- 定义过滤器函数，检查卡片是否为「恶魔之声」且可放置
function s.filter(c)
	return c:IsCode(30432463) and not c:IsForbidden()
end
-- 怪兽效果1的伤害步骤前处理，检查灵摆区域和卡组
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查两个灵摆区域是否可用
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1)
		-- 检查卡组是否存在「恶魔之声」
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 怪兽效果1的具体操作：将这张卡和「恶魔之声」放置到灵摆区域
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否关联效果且灵摆区域可用
	if not (c:IsRelateToEffect(e) and Duel.CheckLocation(tp,LOCATION_PZONE,0)
		-- 检查两个灵摆区域是否可用
		and Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家选择1张「恶魔之声」
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		-- 将这张卡移动到灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		-- 将「恶魔之声」移动到灵摆区域
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 怪兽效果2的触发条件：这张卡在当前回合被召唤或特殊召唤
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 定义过滤器函数，检查卡片是否为「异响鸣」通常魔法·通常陷阱卡
function s.pfilter(c)
	local typ=c:GetType()
	return c:IsSetCard(0x1a3) and (typ==TYPE_SPELL or typ==TYPE_TRAP) and c:IsAbleToRemoveAsCost()
		and c:CheckActivateEffect(false,true,false)
end
-- 怪兽效果2的伤害步骤前处理，检查是否可使用cost
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查墓地是否存在「异响鸣」通常魔法·通常陷阱卡
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1张「异响鸣」通常魔法·通常陷阱卡
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	e:SetLabelObject(te)
	-- 除外选中的魔法·陷阱卡作为cost
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除操作信息
	Duel.ClearOperationInfo(0)
end
-- 怪兽效果2的具体操作：执行被除外魔法·陷阱卡的效果
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp,1) end
end
