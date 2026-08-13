--影霊衣の神魔鏡
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而把额外卡组的「影灵衣」怪兽送去墓地，把自己的手卡·除外状态的1只「影灵衣」仪式怪兽仪式召唤。
-- ②：自己主要阶段，从自己墓地把1只「影灵衣」怪兽和这张卡除外才能发动。从卡组把1张「影灵衣」魔法卡加入手卡。
local s,id,o=GetID()
-- 注册这张卡的①②两个效果：①为魔法卡发动型效果，可在自己·对方主要阶段作为自由连锁发动，进行「影灵衣」仪式召唤；②为墓地起动效果，除外自身和1只「影灵衣」怪兽后从卡组检索「影灵衣」魔法卡；两个效果各有1回合1次限制。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己·对方的主要阶段才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而把额外卡组的「影灵衣」怪兽送去墓地，把自己的手卡·除外状态的1只「影灵衣」仪式怪兽仪式召唤。
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
-- 效果1的发动条件：当前阶段为主要阶段1或主要阶段2，对应『自己·对方的主要阶段才能发动』。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否处于主要阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 选择仪式召唤对象的过滤函数：要求是「影灵衣」字段的怪兽，且处于手卡或表侧除外状态等可作为仪式召唤对象的区域。
function s.rfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xb4)
end
-- 额外卡组代替解放素材的过滤函数：要求是等级>0的「影灵衣」怪兽，且能被送去墓地，用于作为解放的代替。
function s.mfilter(c)
	return c:GetLevel()>0 and c:IsSetCard(0xb4) and c:IsAbleToGrave()
end
-- 效果1发动时的合法性检查与操作信息设置：确认手卡·除外状态存在可仪式召唤的「影灵衣」仪式怪兽，且可用通常素材或额外卡组代替素材凑齐等级合计≥其等级；随后设置特殊召唤和送墓的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前玩家可用的通常仪式素材集合（手卡·场上的怪兽等）。
		local mg1=Duel.GetRitualMaterial(tp)
		-- 获取额外卡组中可作为解放代替送去墓地的「影灵衣」怪兽集合。
		local mg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_EXTRA,0,nil)
		-- 检查是否存在至少1只「影灵衣」仪式怪兽（手卡·除外状态）能够用上述素材完成等级合计≥其等级的仪式召唤。
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,s.rfilter,e,tp,mg1,mg2,Card.GetLevel,"Greater")
	end
	-- 设置操作信息：本次效果预定进行1只仪式怪兽的特殊召唤，来源区域为手卡·除外状态。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
	-- 设置操作信息：本次效果可能有额外卡组的「影灵衣」怪兽被送去墓地（代替解放），数量暂不确定，故设为0。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_EXTRA)
end
-- 效果1处理：重新取得素材→选择要仪式召唤的「影灵衣」怪兽→选择一组合法素材（手卡/场上解放或额外卡组送墓）→若素材选择失败则跳回重选；成功后解放/送墓素材，再将选择的怪兽仪式召唤并完成仪式召唤处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 效果处理时重新获取当前可用的通常仪式素材集合。
	local mg1=Duel.GetRitualMaterial(tp)
	-- 效果处理时重新获取额外卡组中可作代替送墓的「影灵衣」怪兽集合。
	local mg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_EXTRA,0,nil)
	-- 提示玩家选择要特殊召唤的仪式怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·除外状态选择1只满足条件的「影灵衣」仪式怪兽作为本次仪式召唤的对象。
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
		-- 提示玩家选择要解放/送去墓地的仪式素材。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置额外素材检查函数：要求所选素材的等级合计可以大于等于仪式怪兽的等级（Greater，允许溢出）。
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 从候选素材中选择一组合法的仪式素材，使等级合计≥仪式怪兽等级，且满足辅助检查；若选择失败返回nil。
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 清除额外素材检查函数，避免影响后续其他效果的素材选择。
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_EXTRA):Filter(s.mfilter,nil)
		mat:Sub(mat2)
		-- 将选择的通常素材（手卡·场上的怪兽）解放，作为仪式召唤的解放。
		Duel.ReleaseRitualMaterial(mat)
		-- 将额外卡组中作为解放代替的「影灵衣」怪兽送去墓地，送墓原因视为效果、仪式素材。
		Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- 中断当前效果处理，使素材处理与特殊召唤不在同一时点，避免错过时点。
		Duel.BreakEffect()
		-- 将仪式怪兽以表侧表示进行仪式召唤（SUMMON_TYPE_RITUAL），不检查苏生限制。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- ②效果cost用的墓地「影灵衣」怪兽过滤函数：属于「影灵衣」字段、是怪兽、且可作为除外的cost。
function s.cfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ②效果cost检查：本卡自身必须能除外，且墓地存在至少1只符合条件的「影灵衣」怪兽可作为cost。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 追加检查：墓地确实存在至少1只可除外的「影灵衣」怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1只符合条件的「影灵衣」怪兽作为发动cost。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(c)
	-- 将这张卡自身和选择的「影灵衣」怪兽表侧除外，作为发动cost。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检索目标的过滤函数：属于「影灵衣」字段、是魔法卡、且可以加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ②效果发动合法性检查：确认卡组存在至少1张符合条件的「影灵衣」魔法卡；并设置从卡组将1张加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否存在至少1张符合条件的「影灵衣」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将从卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张「影灵衣」魔法卡加入手卡，并向对方展示确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「影灵衣」魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「影灵衣」魔法卡加入其持有者的手卡，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
