--疾風の豹戦士パンサーウォリアー
local s,id,o=GetID()
-- 初始化函数，注册卡片的各个效果
function s.initial_effect(c)
	-- 记录卡片上记载着卡名「40235813」
	aux.AddCodeList(c,40235813)
	-- ①：双方的主要阶段才能发动。把自己场上1只怪兽解放，从以下效果选择1个发动。●从手卡·卡组把1只「40235813」有记述的怪兽特殊召唤。●从卡组把1张「40235813」有记述的魔法·陷阱卡送去墓地。
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
	-- ②：只要这个效果适用中，这张卡不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(s.atkcon)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 注册一个全局检查效果，用于监控怪兽被解放的事件以解除攻击限制
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_RELEASE)
		ge1:SetOperation(s.checkop)
		-- 将全局检查效果注册给全局环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查卡片是否是原本类型为怪兽的卡被解放
function s.checkfilter(c)
	return c:GetPreviousTypeOnField()&TYPE_MONSTER~=0 or (not c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetOriginalType()&TYPE_MONSTER~=0)
end
-- 监控是否有怪兽被解放，如果有则给玩家注册一个标识效果
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.checkfilter,1,nil) then
		-- 给玩家注册一个标识效果，持续到回合结束，表示已有怪兽被解放
		Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判断当前是否是主要阶段
function s.recon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否是主要阶段
	return Duel.IsMainPhase()
end
-- 过滤函数，检查是否是能够作为解放cost的怪兽
function s.cfilter(c,tp,e)
	return c:IsType(TYPE_MONSTER)
		-- 判断卡组是否存在能够送去墓地的魔法·陷阱卡
		and (Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) or
			-- 判断解放该怪兽后是否有可用的怪兽区，且手卡·卡组存在可以特殊召唤的怪兽
			Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp))
end
-- 效果1的cost函数，让玩家选择并解放1只符合条件的怪兽
function s.recost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在至少1只符合条件的可以解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_COST,true,e:GetHandler(),tp,e) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从场上·手卡选择1只满足条件的怪兽
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter,1,1,REASON_COST,true,e:GetHandler(),tp,e)
	-- 将选中的怪兽作为cost解放
	Duel.Release(g,REASON_COST)
end
-- 过滤函数，检查卡片是否是记述了40235813的魔法·陷阱卡，且能送去墓地
function s.tgfilter(c)
	-- 检查卡片是否是记述了40235813的魔法·陷阱卡
	return aux.IsCodeListed(c,40235813) and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsAbleToGrave()
end
-- 过滤函数，检查卡片是否是同名卡以外的记述了40235813的怪兽，且能被特殊召唤
function s.spfilter(c,e,tp)
	-- 检查卡片是否是同名卡以外的记述了40235813的怪兽，且能被特殊召唤
	return not c:IsCode(id) and aux.IsCodeListed(c,40235813) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果1的发动目标设定，根据玩家选择决定是特殊召唤怪兽还是将卡送去墓地
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手卡·卡组是否有满足条件的怪兽，且有可用的主要怪兽区
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 判断卡组是否有满足条件的魔法·陷阱卡
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	-- 让玩家从可选的效果中选择1个发动
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},
			{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置操作信息：预期从手卡·卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOGRAVE)
		end
		-- 设置操作信息：预期从卡组把1张卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果1的处理逻辑，执行特殊召唤怪兽或将卡送去墓地的操作
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 如果可用的怪兽区数量小于等于0，则不处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡·卡组中选择1只满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从卡组选择1张满足条件的卡
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 判断玩家是否没有注册过怪兽被解放的标识效果
function s.atkcon(e)
	-- 返回玩家是否没有该标识效果，以此决定是否限制攻击
	return Duel.GetFlagEffect(0,id)==0
end
