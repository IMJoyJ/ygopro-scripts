--道化の一座『下稽古』
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己的手卡·场上1只怪兽解放才能发动。从卡组把1张「道化一座『排练』」以外的「道化一座」魔法·陷阱卡和1只「道化一座 白脸小丑」加入手卡。
-- ②：把墓地的这张卡除外才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「道化一座」仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 注册卡片效果，包括检索效果和仪式召唤效果
function s.initial_effect(c)
	-- 记录该卡与「道化一座 白脸小丑」的关联
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
	-- 注册仪式召唤效果，条件为等级合计大于等于仪式怪兽等级
	local e2=aux.AddRitualProcGreater2(c,s.filter,LOCATION_HAND,nil,nil,true)
	e2:SetDescription(aux.Stringid(id,1))  --"仪式召唤"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置仪式召唤的发动代价为将此卡除外
	e2:SetCost(aux.bfgcost)
	c:RegisterEffect(e2)
end
-- 解放1只怪兽作为发动代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放1只怪兽的条件
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,aux.TRUE,1,REASON_COST,true,nil,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择1只可解放的怪兽
	local g=Duel.SelectReleaseGroupEx(tp,aux.TRUE,1,1,REASON_COST,true,nil,tp)
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 定义检索卡牌的过滤条件
function s.thfilter(c)
	return s.thfilter1(c) or s.thfilter2(c)
end
-- 筛选卡组中非此卡且为「道化一座」魔法·陷阱卡
function s.thfilter1(c)
	return not c:IsCode(id) and c:IsSetCard(0x1dc) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 筛选卡组中「道化一座 白脸小丑」
function s.thfilter2(c)
	return c:IsCode(82159583) and c:IsAbleToHand()
end
-- 设置检索效果的发动条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中满足检索条件的卡
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		-- 检查卡组中是否存在满足条件的2张卡
		return g:CheckSubGroup(aux.gffcheck,2,2,s.thfilter1,nil,s.thfilter2,nil)
	end
	-- 设置检索效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 执行检索效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中满足检索条件的卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 检查是否满足检索条件
	if not g:CheckSubGroup(aux.gffcheck,2,2,s.thfilter1,nil,s.thfilter2,nil) then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的2张卡
	local tg1=g:SelectSubGroup(tp,aux.gffcheck,false,2,2,s.thfilter1,nil,s.thfilter2,nil)
	if tg1:GetCount()==2 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(tg1,nil,REASON_EFFECT)
		-- 确认玩家看到加入手牌的卡
		Duel.ConfirmCards(1-tp,tg1)
	end
end
-- 筛选可用于仪式召唤的「道化一座」仪式怪兽
function s.filter(c,e,tp,chk)
	return c:IsSetCard(0x1dc) and c:IsType(TYPE_RITUAL) and (not chk or c~=e:GetHandler())
end
