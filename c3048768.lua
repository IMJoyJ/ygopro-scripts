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
-- 初始化效果：注册灵摆怪兽属性，允许在灵摆区域放置响鸣指示物，依次注册回复时放置指示物的永续效果（e1）、攻击宣言时进行连接召唤的诱发效果（e2）、手卡丢弃卡后将这张卡与「恶魔之声」放入灵摆区域的起动效果（e3）、召唤·特殊召唤回合除外墓地「异响鸣」通常魔法·陷阱卡适用回复效果的起动效果（e4），并注册记录这张卡召唤·特殊召唤的全局检查效果
function s.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（支持灵摆召唤及灵摆卡的发动）
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
		-- 注册召唤·特殊召唤成功时的全局记录效果（用于判定这张卡召唤·特殊召唤的回合），声明响鸣指示物0x6a，并定义各效果所用的过滤器、条件、代价、目标与处理函数
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(id)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 指定召唤成功时记录该卡（用sumreg处理「这张卡召唤的回合」的判定）
		ge1:SetOperation(aux.sumreg)
		-- 将该记录效果注册为全局环境效果
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 将特殊召唤成功时的记录效果注册为全局环境效果
		Duel.RegisterEffect(ge2,0)
	end
end
s.mentioned_counter={
	[0x6a]=true,
}
-- 过滤器：卡的原本种族是恶魔族且原本种类是怪兽
function s.cfilter(c)
	return c:GetOriginalRace()&RACE_FIEND>0 and c:GetOriginalType()&TYPE_MONSTER>0
end
-- 条件：另一边的自己灵摆区域存在恶魔族怪兽卡，且回复基本分的玩家是自己
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查另一边（除这张卡自身外）的自己灵摆区域是否存在恶魔族怪兽卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
		and ep==tp
end
-- 处理：给这张卡放置1个响鸣指示物，当指示物达到3个时触发自定义事件（供「异响鸣」相关效果检测）
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x6a,1)
	if c:GetCounter(0x6a)==3 then
		-- 触发响鸣指示物达到3个的自定义事件时点
		Duel.RaiseEvent(c,EVENT_CUSTOM+39210885,e,0,tp,tp,0)
	end
end
-- 条件：当前是对方的回合（即对方怪兽的攻击宣言时）
function s.lscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤器：可以连接召唤且是「异响鸣」系列的连接怪兽
function s.lfilter(c)
	return c:IsLinkSummonable(nil) and c:IsSetCard(0x1a3)
end
-- 目标：确认额外卡组存在可进行连接召唤的「异响鸣」连接怪兽，并设置特殊召唤的操作信息
function s.lstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只可以进行连接召唤的「异响鸣」连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.lfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理：让玩家从额外卡组选择1只可进行连接召唤的「异响鸣」连接怪兽，进行那只怪兽的连接召唤
function s.lsop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只可进行连接召唤的「异响鸣」连接怪兽
	local tc=Duel.SelectMatchingCard(tp,s.lfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	-- 进行那只连接怪兽的连接召唤
	if tc then Duel.LinkSummon(tp,tc,nil) end
end
-- 代价：确认手卡存在这张卡以外可以丢弃的卡，然后从手卡丢弃1张其他卡
function s.pzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡是否存在这张卡以外的1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	-- 作为发动代价，从手卡丢弃1张这张卡以外的其他卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,c)
end
-- 过滤器：卡号是「恶魔之声」（30432463）且没有被禁止放置
function s.filter(c)
	return c:IsCode(30432463) and not c:IsForbidden()
end
-- 目标：确认灵摆区域两个格子均可用，且卡组存在可放置的「恶魔之声」
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域左右两个格子是否可用
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1)
		-- 检查卡组是否存在至少1张「恶魔之声」
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 处理：确认这张卡仍与效果关联且灵摆区域两格可用后才继续，否则中止
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联且灵摆区域左格可用
	if not (c:IsRelateToEffect(e) and Duel.CheckLocation(tp,LOCATION_PZONE,0)
		-- 确认灵摆区域右格可用，否则中止处理
		and Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从卡组选择1只「恶魔之声」
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		-- 把这张卡表侧表示放置到自己的灵摆区域并立即适用效果
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		-- 把选出的「恶魔之声」表侧表示放置到自己的灵摆区域并立即适用效果
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 条件：这张卡是这个回合召唤·特殊召唤的（带有召唤记录标志）
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 过滤器：「异响鸣」系列的通常魔法·通常陷阱卡，可以作为代价除外，且发动时的效果可以被适用
function s.pfilter(c)
	local typ=c:GetType()
	return c:IsSetCard(0x1a3) and (typ==TYPE_SPELL or typ==TYPE_TRAP) and c:IsAbleToRemoveAsCost()
		and c:CheckActivateEffect(false,true,false)
end
-- 目标：在支付代价阶段确认墓地存在可除外并适用效果的「异响鸣」通常魔法·通常陷阱卡
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己墓地是否存在满足条件的「异响鸣」通常魔法·通常陷阱卡
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足条件的「异响鸣」通常魔法·通常陷阱卡
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	e:SetLabelObject(te)
	-- 作为代价将那张魔法·陷阱卡表侧表示除外
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除操作信息，避免复制墓地效果的处理被其他效果响应
	Duel.ClearOperationInfo(0)
end
-- 处理：取得被除外卡的效果，执行其回复基本分的选项的效果处理
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp,1) end
end
