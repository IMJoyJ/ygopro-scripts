--疾風の豹戦士パンサーウォリアー
local s,id,o=GetID()
-- 初始化卡片效果：记录关联卡名、注册主要阶段解放置换效果、攻击限制效果及全局解放监听效果
function s.initial_effect(c)
	-- 记录卡名：此卡记载了「漆黑之豹战士」的卡名
	aux.AddCodeList(c,40235813)
	-- ①：自己·对方的主要阶段，把自己场上1只怪兽解放才能从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.recon)
	e1:SetCost(s.recost)
	e1:SetTarget(s.retg)
	e1:SetOperation(s.reop)
	c:RegisterEffect(e1)
	-- ②：这张卡在自己场上有怪兽被解放的回合才能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(s.atkcon)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 注册全局效果：监听本回合内是否有怪兽被解放
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_RELEASE)
		ge1:SetOperation(s.checkop)
		-- 向系统注册全局连续效果
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局监听过滤条件：检查被解放的卡是否为怪兽
function s.checkfilter(c)
	return c:GetPreviousTypeOnField()&TYPE_MONSTER~=0 or (not c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetOriginalType()&TYPE_MONSTER~=0)
end
-- 全局监听处理：存在怪兽被解放时为玩家注册解放标记Flag
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.checkfilter,1,nil) then
		-- 为玩家注册持续至回合结束的解放标记
		Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 发动条件检查：判断是否处于主要阶段
function s.recon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- Cost解放过滤条件：可以解放且能满足后续特召或精堆效果发动的怪兽
function s.cfilter(c,tp,e)
	return c:IsType(TYPE_MONSTER)
		-- 检查卡组是否存在可送去墓地的关联魔法·陷阱卡
		and (Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) or
			-- 检查解放该怪兽后怪兽区有空位且存在可特召的关联怪兽
			Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp))
end
-- ①效果Cost：选择自己场上1只符合条件的怪兽解放
function s.recost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：是否存在可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_COST,true,e:GetHandler(),tp,e) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从自己场上选择1只满足条件的怪兽
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter,1,1,REASON_COST,true,e:GetHandler(),tp,e)
	-- 以Cost原因解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 精堆过滤条件：记载有「漆黑之豹战士」卡名的魔法·陷阱卡
function s.tgfilter(c)
	-- 检查卡片是否记载「漆黑之豹战士」卡名且为魔法·陷阱卡
	return aux.IsCodeListed(c,40235813) and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsAbleToGrave()
end
-- 特召过滤条件：自身以外记载有「漆黑之豹战士」卡名的怪兽
function s.spfilter(c,e,tp)
	-- 检查卡片是否为同名卡以外且记载「漆黑之豹战士」卡名并可特殊召唤
	return not c:IsCode(id) and aux.IsCodeListed(c,40235813) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动准备：判断分支合法性并由玩家选择发动的效果分支
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 分支1判定：检查手牌/卡组是否存在可特召的关联怪兽且场上有空位
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 分支2判定：检查卡组是否存在可送去墓地的关联魔法·陷阱卡
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	-- 提示玩家选择要发动的效果分支
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},
			{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 分支1：设置连锁操作信息：从手牌/卡组特殊召唤1张卡
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOGRAVE)
		end
		-- 分支2：设置连锁操作信息：从卡组把1张卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果处理：根据选择的分支执行手牌/卡组特召或卡组精堆
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 分支1处理：怪兽区域无空位时终止效果处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 分支1处理：提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 分支1处理：从手牌或卡组选择1只满足条件的关联怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 分支1处理：将选中的怪兽表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif e:GetLabel()==2 then
		-- 分支2处理：提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 分支2处理：从卡组选择1张满足条件的关联魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 分支2处理：将选中的卡送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 攻击限制条件：检查本回合玩家是否尚未触发过怪兽解放标记
function s.atkcon(e)
	-- 判断本回合玩家的怪兽解放标记数量是否为0
	return Duel.GetFlagEffect(0,id)==0
end
