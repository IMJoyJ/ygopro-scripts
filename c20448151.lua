--道化の一座『下稽古』
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己的手卡·场上1只怪兽解放才能发动。从卡组把1张「道化一座『排练』」以外的「道化一座」魔法·陷阱卡和1只「道化一座 白脸小丑」加入手卡。
-- ②：把墓地的这张卡除外才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「道化一座」仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 记录关联卡名并注册卡片效果
function s.initial_effect(c)
	-- 记录卡名：将「道化一座 白脸小丑」加入记载卡号列表中
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
	-- 添加仪式召唤效果：从手卡将「道化一座」仪式怪兽仪式召唤
	local e2=aux.AddRitualProcGreater2(c,s.filter,LOCATION_HAND,nil,nil,true)
	e2:SetDescription(aux.Stringid(id,1))  --"仪式召唤"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 发动代价：将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	c:RegisterEffect(e2)
end
-- 发动代价：把自己的手卡·场上1只怪兽解放
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·场上是否存在可作为代价解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,aux.TRUE,1,REASON_COST,true,nil,tp) end
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从手卡·场上选择1只怪兽
	local g=Duel.SelectReleaseGroupEx(tp,aux.TRUE,1,1,REASON_COST,true,nil,tp)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 卡片过滤：可加入手卡的「道化一座」魔法·陷阱卡或「道化一座 白脸小丑」
function s.thfilter(c)
	return s.thfilter1(c) or s.thfilter2(c)
end
-- 卡片过滤：卡组中「道化一座『排练』」以外可加入手卡的「道化一座」魔法·陷阱卡
function s.thfilter1(c)
	return not c:IsCode(id) and c:IsSetCard(0x1dc) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 卡片过滤：卡组中可加入手卡的「道化一座 白脸小丑」
function s.thfilter2(c)
	return c:IsCode(82159583) and c:IsAbleToHand()
end
-- 目标检查：检查卡组中是否存在满足条件的1张「道化一座」魔陷和1只「道化一座 白脸小丑」，并设置检索操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有符合条件的候选卡片
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		-- 检查候选卡中是否存在分别满足两类条件的2张卡组合
		return g:CheckSubGroup(aux.gffcheck,2,2,s.thfilter1,nil,s.thfilter2,nil)
	end
	-- 设置效果处理的操作信息：从卡组将2张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从卡组把1张「道化一座『排练』」以外的「道化一座」魔陷和1只「道化一座 白脸小丑」加入手卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合条件的候选卡片
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 检查卡组中是否存在满足条件的2张卡组合，若不满足则结束处理
	if not g:CheckSubGroup(aux.gffcheck,2,2,s.thfilter1,nil,s.thfilter2,nil) then return end
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选出1张「道化一座」魔陷和1只「道化一座 白脸小丑」
	local tg1=g:SelectSubGroup(tp,aux.gffcheck,false,2,2,s.thfilter1,nil,s.thfilter2,nil)
	if tg1 then
		-- 将选中的2张卡加入手卡
		Duel.SendtoHand(tg1,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tg1)
	end
end
-- 仪式怪兽过滤：手卡中的「道化一座」仪式怪兽
function s.filter(c,e,tp,chk)
	return c:IsSetCard(0x1dc) and c:IsType(TYPE_RITUAL) and (not chk or c~=e:GetHandler())
end
