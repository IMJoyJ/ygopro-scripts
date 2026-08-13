--道化の一座『下稽古』
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己的手卡·场上1只怪兽解放才能发动。从卡组把1张「道化一座『排练』」以外的「道化一座」魔法·陷阱卡和1只「道化一座 白脸小丑」加入手卡。
-- ②：把墓地的这张卡除外才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「道化一座」仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 初始化该卡的效果：①以解放手卡·场上1只怪兽为代价，从卡组检索1张「道化一座」魔法·陷阱卡和1只「道化一座 白脸小丑」加入手卡；②在墓地除外自身，解放手卡·场上怪兽进行「道化一座」仪式怪兽的仪式召唤，两个效果1回合各能使用1次。
function s.initial_effect(c)
	-- 将该卡记载的卡名「道化一座 白脸小丑」加入代码列表，使此卡被视为记载有该卡名。
	aux.AddCodeList(c,82159583)
	-- ①：把自己的手卡·场上1只怪兽解放才能发动。从卡组把1张「道化一座『排练』」以外的「道化一座」魔法·陷阱卡和1只「道化一座 白脸小丑」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 调用辅助函数预创建②的仪式召唤效果：以自己手卡为仪式召唤的怪兽来源，允许解放等级合计达到仪式怪兽等级以上的素材；暂不注册，待后续设定细节。
	local e2=aux.AddRitualProcGreater2(c,s.filter,LOCATION_HAND,nil,nil,true)
	e2:SetDescription(aux.Stringid(id,1))  --"仪式召唤"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设定②效果的发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价处理：检查并让玩家从手卡·场上选择1只怪兽解放作为代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认存在至少1只可从手卡·场上解放的怪兽，否则不能发动。
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,aux.TRUE,1,REASON_COST,true,nil,tp) end
	-- 弹出“请选择要解放的卡”的选择提示，引导玩家选择祭品。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从手卡·场上选择1只可解放的怪兽作为①效果的发动代价。
	local g=Duel.SelectReleaseGroupEx(tp,aux.TRUE,1,1,REASON_COST,true,nil,tp)
	-- 将选中的怪兽解放，完成代价支付。
	Duel.Release(g,REASON_COST)
end
-- 检索候选过滤函数：同时纳入“道化一座”魔法·陷阱卡和“道化一座 白脸小丑”两种对象。
function s.thfilter(c)
	return s.thfilter1(c) or s.thfilter2(c)
end
-- 筛选条件：卡名不是这张卡本身、属于“道化一座”系列、是魔法·陷阱卡、且能加入手卡。
function s.thfilter1(c)
	return not c:IsCode(id) and c:IsSetCard(0x1dc) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 筛选条件：卡名是「道化一座 白脸小丑」且能加入手卡。
function s.thfilter2(c)
	return c:IsCode(82159583) and c:IsAbleToHand()
end
-- ①效果的发动条件与操作信息设定：检查卡组中是否同时存在满足条件的1张系列魔法·陷阱卡和1张白脸小丑；若可发动，登记把2张卡加入手卡的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取我方卡组中所有满足检索条件的卡，作为后续选择用的候选集合。
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		-- 检查候选集合中是否存在由1张系列魔法·陷阱卡与1张白脸小丑组成的合法组合（顺序不固定），以此作为能否发动的判定。
		return g:CheckSubGroup(aux.gffcheck,2,2,s.thfilter1,nil,s.thfilter2,nil)
	end
	-- 设置操作信息：本次效果将从卡组把2张卡加入手卡（不取对象，数量为2，来源为玩家卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- ①效果处理阶段：重新获取卡组中的候选组，若已无合法组合则终止；否则让玩家选择一组“系列魔法·陷阱卡＋白脸小丑”，将它们加入手卡并向对方确认。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取卡组中当前满足条件的候选卡，防止处理前卡组发生变化导致误判。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 效果处理时若卡组中已经不存在合法的“系列魔法·陷阱卡＋白脸小丑”组合，则本次效果不适用，直接结束处理。
	if not g:CheckSubGroup(aux.gffcheck,2,2,s.thfilter1,nil,s.thfilter2,nil) then return end
	-- 弹出“请选择要加入手牌的卡”的选择提示，供玩家选择检索目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从候选卡中选择2张，且必须满足一张为系列魔法·陷阱卡、另一张为白脸小丑的组合条件。
	local tg1=g:SelectSubGroup(tp,aux.gffcheck,false,2,2,s.thfilter1,nil,s.thfilter2,nil)
	if tg1:GetCount()==2 then
		-- 将选中的2张卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(tg1,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的2张卡，以确认检索内容。
		Duel.ConfirmCards(1-tp,tg1)
	end
end
-- 仪式召唤用的怪兽过滤函数：要求仪式怪兽属于“道化一座”系列且为仪式怪兽；同时确保不是效果持有者自身（用于排除这张魔法卡本身）。
function s.filter(c,e,tp,chk)
	return c:IsSetCard(0x1dc) and c:IsType(TYPE_RITUAL) and (not chk or c~=e:GetHandler())
end
