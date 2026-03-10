--レスキューラット
-- 效果：
-- ←5 【灵摆】 5→
-- 「救援鼠」的灵摆效果在决斗中只能使用1次。
-- ①：把自己的灵摆区域的这张卡除外才能发动。从自己的额外卡组把2只表侧表示的同名灵摆怪兽加入手卡。
-- 【怪兽效果】
-- ①：这张卡召唤成功的回合，自己的额外卡组有表侧表示的5星以下的灵摆怪兽存在的场合，把这张卡解放才能发动。从自己的额外卡组选1只表侧表示的5星以下的灵摆怪兽，从卡组把那2只同名怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
function c50485594.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，允许其进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：把自己的灵摆区域的这张卡除外才能发动。从自己的额外卡组把2只表侧表示的同名灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50485594,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,50485594+EFFECT_COUNT_CODE_DUEL)
	e2:SetCost(c50485594.thcost)
	e2:SetTarget(c50485594.thtg)
	e2:SetOperation(c50485594.thop)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤成功的回合，自己的额外卡组有表侧表示的5星以下的灵摆怪兽存在的场合，把这张卡解放才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c50485594.regop)
	c:RegisterEffect(e3)
	-- 从自己的额外卡组选1只表侧表示的5星以下的灵摆怪兽，从卡组把那2只同名怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(50485594,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c50485594.spcost)
	e4:SetCondition(c50485594.spcon)
	e4:SetTarget(c50485594.sptg)
	e4:SetOperation(c50485594.spop)
	c:RegisterEffect(e4)
end
-- 支付将此卡除外作为费用
function c50485594.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将此卡除外作为费用
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤函数：返回场上表侧表示的灵摆怪兽且能加入手牌
function c50485594.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 过滤函数：判断给定组中是否存在与目标卡同名的卡
function c50485594.filter2(c,g)
	return g:IsExists(Card.IsCode,1,c,c:GetCode())
end
-- 设置连锁操作信息，准备从额外卡组检索2只灵摆怪兽加入手牌
function c50485594.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取额外卡组中所有满足条件的灵摆怪兽
		local g=Duel.GetMatchingGroup(c50485594.filter,tp,LOCATION_EXTRA,0,nil)
		return g:IsExists(c50485594.filter2,1,nil,g)
	end
	-- 设置连锁操作信息，准备从额外卡组检索2只灵摆怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_EXTRA)
end
-- 执行灵摆效果：选择并加入手牌2只同名灵摆怪兽
function c50485594.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中所有满足条件的灵摆怪兽
	local g=Duel.GetMatchingGroup(c50485594.filter,tp,LOCATION_EXTRA,0,nil)
	local sg=g:Filter(c50485594.filter2,nil,g)
	if sg:GetCount()==0 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local hg1=sg:Select(tp,1,1,nil)
	local hg2=sg:Filter(Card.IsCode,hg1:GetFirst(),hg1:GetFirst():GetCode())
	hg1:AddCard(hg2:GetFirst())
	-- 将选中的卡送入手牌
	Duel.SendtoHand(hg1,nil,REASON_EFFECT)
	-- 向对方确认送入手牌的卡
	Duel.ConfirmCards(1-tp,hg1)
end
-- 注册召唤成功标志，用于后续判断是否可以发动特殊召唤效果
function c50485594.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(50485594,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否已触发召唤成功标志，决定是否可以发动特殊召唤效果
function c50485594.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(50485594)~=0
end
-- 支付将此卡解放作为费用
function c50485594.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：返回场上表侧表示的5星以下灵摆怪兽且其卡组中有2只同名怪兽可特殊召唤
function c50485594.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsLevelBelow(5)
		-- 检查卡组中是否存在2只同名怪兽可特殊召唤
		and Duel.IsExistingMatchingCard(c50485594.spfilter2,tp,LOCATION_DECK,0,2,nil,c:GetCode(),e,tp)
end
-- 过滤函数：返回卡号为code且可特殊召唤的怪兽
function c50485594.spfilter2(c,code,e,tp)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置连锁操作信息，准备从卡组特殊召唤2只同名怪兽
function c50485594.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有足够的空间进行特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查额外卡组中是否存在满足条件的灵摆怪兽
		and Duel.IsExistingMatchingCard(c50485594.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息，准备从卡组特殊召唤2只同名怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 执行特殊召唤效果：选择并特殊召唤2只同名怪兽，并在结束阶段破坏
function c50485594.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查玩家场上是否有足够的空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 提示玩家选择表侧表示的灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从额外卡组中选择满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c50485594.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()==0 then return end
	local code=g:GetFirst():GetCode()
	-- 获取卡组中所有同名怪兽
	local dg=Duel.GetMatchingGroup(c50485594.spfilter2,tp,LOCATION_DECK,0,nil,code,e,tp)
	if dg:GetCount()>1 then
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg1=dg:Select(tp,1,1,nil)
		local tc1=sg1:GetFirst()
		local sg2=dg:Filter(Card.IsCode,tc1,tc1:GetCode())
		local tc2=sg2:GetFirst()
		-- 将第一只怪兽特殊召唤
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
		-- 将第二只怪兽特殊召唤
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
		tc1:RegisterFlagEffect(50485594,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc2:RegisterFlagEffect(50485594,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
		sg1:Merge(sg2)
		sg1:KeepAlive()
		-- 注册结束阶段破坏效果，用于在结束阶段破坏特殊召唤的怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(sg1)
		e1:SetCondition(c50485594.descon)
		e1:SetOperation(c50485594.desop)
		-- 将破坏效果注册到场上
		Duel.RegisterEffect(e1,tp)
		-- 使特殊召唤的怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e2)
		local e3=e2:Clone()
		tc2:RegisterEffect(e3)
		-- 使特殊召唤的怪兽效果在结束阶段被无效化
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		e4:SetValue(RESET_TURN_SET)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e4)
		local e5=e4:Clone()
		tc2:RegisterEffect(e5)
	end
end
-- 过滤函数：判断目标怪兽是否为本次特殊召唤的怪兽
function c50485594.desfilter(c,fid)
	return c:GetFlagEffectLabel(50485594)==fid
end
-- 判断是否需要触发破坏效果，即是否有特殊召唤的怪兽需要在结束阶段破坏
function c50485594.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c50485594.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 执行破坏操作，将满足条件的怪兽破坏
function c50485594.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c50485594.desfilter,nil,e:GetLabel())
	-- 将满足条件的怪兽破坏
	Duel.Destroy(tg,REASON_EFFECT)
end
