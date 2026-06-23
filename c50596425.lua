--影霊衣の神魔鏡
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而把额外卡组的「影灵衣」怪兽送去墓地，把自己的手卡·除外状态的1只「影灵衣」仪式怪兽仪式召唤。
-- ②：自己主要阶段，从自己墓地把1只「影灵衣」怪兽和这张卡除外才能发动。从卡组把1张「影灵衣」魔法卡加入手卡。
local s,id,o=GetID()
-- 创建卡的效果，包括仪式召唤和检索两个效果
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而把额外卡组的「影灵衣」怪兽送去墓地，把自己的手卡·除外状态的1只「影灵衣」仪式怪兽仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"仪式召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段，从自己墓地把1只「影灵衣」怪兽和这张卡除外才能发动。从卡组把1张「影灵衣」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH|CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 判断当前是否为自己的主要阶段1或主要阶段2
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤场上正面表示的影灵衣怪兽
function s.rfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xb4)
end
-- 过滤额外卡组中可送去墓地的影灵衣怪兽
function s.mfilter(c)
	return c:GetLevel()>0 and c:IsSetCard(0xb4) and c:IsAbleToGrave()
end
-- 检查是否有满足条件的仪式召唤目标怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家可用的用于仪式召唤的素材组1（手牌和场上的怪兽）
		local mg1=Duel.GetRitualMaterial(tp)
		-- 获取玩家额外卡组中符合要求的影灵衣怪兽组2（用于代替解放）
		local mg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_EXTRA,0,nil)
		-- 检查是否存在满足仪式召唤条件的怪兽
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,s.rfilter,e,tp,mg1,mg2,Card.GetLevel,"Greater")
	end
	-- 设置操作信息：将要特殊召唤的卡片数量设为1，来源位置为手牌和除外状态
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
	-- 设置操作信息：将要送去墓地的卡片数量设为0，来源位置为额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_EXTRA)
end
-- 执行仪式召唤效果，选择并处理仪式怪兽及素材
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取玩家可用的用于仪式召唤的素材组1（手牌和场上的怪兽）
	local mg1=Duel.GetRitualMaterial(tp)
	-- 获取玩家额外卡组中符合要求的影灵衣怪兽组2（用于代替解放）
	local mg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_EXTRA,0,nil)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足仪式召唤条件的卡片
	local g=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,s.rfilter,e,tp,mg1,mg2,Card.GetLevel,"Greater")
	local tc=g:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg:Merge(mg2)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置附加检查函数，用于验证仪式召唤的等级条件
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 从候选素材中选择符合仪式召唤要求的子集
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 清除附加检查函数
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_EXTRA):Filter(s.mfilter,nil)
		mat:Sub(mat2)
		-- 解放选中的仪式素材
		Duel.ReleaseRitualMaterial(mat)
		-- 将代替解放的额外卡组怪兽送去墓地
		Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- 中断当前效果处理，使后续效果视为错时点处理
		Duel.BreakEffect()
		-- 将选定的仪式怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 过滤墓地中可作为除外代价的影灵衣怪兽
function s.cfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 设置检索效果的发动条件，检查是否满足除外条件
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查墓地是否存在符合条件的影灵衣怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足除外条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(c)
	-- 将选中的卡片除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤卡组中可加入手牌的影灵衣魔法卡
function s.thfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置检索效果的目标和操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在符合条件的影灵衣魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将要加入手牌的卡片数量设为1，来源位置为卡组
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，选择并处理魔法卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择符合条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选的魔法卡
		Duel.ConfirmCards(1-tp,g)
	end
end
