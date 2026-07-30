--疫神の依鬼 ヨア
local s,id,o=GetID()
-- 注册三个效果：特殊召唤规则、盖放魔法陷阱、等级变更效果
function s.initial_effect(c)
	-- 此卡只能从手牌特殊召唤，条件为场上存在里侧表示的卡且能送入手牌或额外卡组，且有可用怪兽区
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 此卡在场上时，可以发动一次盖放一张魔法或陷阱卡的效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- 此卡在场上时，对方回合可发动一次，选择一个表侧表示的怪兽，将其等级上升1或下降1
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.lvcon)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上的卡是否为里侧表示且能作为特殊召唤的cost
function s.spcfilter(c,tp)
	return c:IsFacedown() and (c:IsAbleToHandAsCost() or c:IsAbleToExtraAsCost())
		-- 确保目标卡所在位置有可用怪兽区
		and Duel.GetMZoneCount(tp,c)>0
end
-- 判断特殊召唤条件是否满足：场上存在符合条件的卡
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在满足特殊召唤条件的卡
	return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
end
-- 设置特殊召唤的目标，选择一张符合条件的卡返回手牌
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有满足特殊召唤条件的卡
	local g=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤操作，确认对方查看卡并送入手牌
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 确认对方查看所选卡
	Duel.ConfirmCards(1-tp,g)
	-- 将所选卡送入手牌
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 过滤函数，用于判断是否为疫神族魔法或陷阱卡且可盖放
function s.setfilter(c)
	return c:IsSetCard(0x1e4) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 设置盖放效果的发动条件：场上存在可盖放的卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足盖放条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 执行盖放操作，选择一张卡进行盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择一张满足盖放条件的卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将所选卡盖放到场上
		Duel.SSet(tp,tc)
	end
end
-- 判断发动等级变更效果的时机：对方回合
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确保当前为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤函数，用于判断是否为表侧表示且等级大于等于1的怪兽
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 设置等级变更效果的目标选择条件：选择一个表侧表示的怪兽
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	-- 检查是否存在满足目标选择条件的卡
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要变更等级的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个满足目标条件的卡
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 执行等级变更操作，根据所选卡等级决定提升或降低
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:IsRelateToChain() then
		local op=0
		if tc:IsLevel(1) then op=1
		-- 当目标卡等级不为1时，让玩家选择提升或降低
		else op=aux.SelectFromOptions(tp,
			{true,aux.Stringid(id,3),1},
			{true,aux.Stringid(id,4),-1})
		end
		-- 将等级变更效果注册到目标卡上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(op)
		tc:RegisterEffect(e1)
	end
end
