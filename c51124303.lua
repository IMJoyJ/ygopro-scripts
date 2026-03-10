--影霊衣の万華鏡
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上1只怪兽解放或者作为解放的代替而把额外卡组1只怪兽送去墓地，从手卡把「影灵衣」仪式怪兽任意数量仪式召唤。
-- ②：自己场上没有怪兽存在的场合，从自己墓地把1只「影灵衣」怪兽和这张卡除外才能发动。从卡组把1张「影灵衣」魔法卡加入手卡。
function c51124303.initial_effect(c)
	-- 创建并注册卡片的第一个效果，该效果为魔法卡发动效果，可以进行仪式召唤
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,51124303)
	e1:SetTarget(c51124303.target)
	e1:SetOperation(c51124303.activate)
	c:RegisterEffect(e1)
	-- 创建并注册卡片的第二个效果，该效果为墓地起动效果，可以从卡组检索一张影灵衣魔法卡加入手牌
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c51124303.thcon)
	e2:SetCost(c51124303.thcost)
	e2:SetTarget(c51124303.thtg)
	e2:SetOperation(c51124303.thop)
	c:RegisterEffect(e2)
end
-- 筛选可以在手牌中被仪式召唤的影灵衣仪式怪兽，并检查其能否使用指定素材进行仪式召唤
function c51124303.spfilter(c,e,tp,mc)
	local mg=Group.FromCards(mc)
	return c:IsSetCard(0xb4) and bit.band(c:GetType(),0x81)==0x81 and (not c.mat_filter or c.mat_filter(mc,tp)) and (not c.mat_group_check or c.mat_group_check(mg,tp))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
		and mc:IsCanBeRitualMaterial(c)
end
-- 判断某只怪兽是否能作为特定仪式怪兽的正确等级素材
function c51124303.rfilter(c,mc)
	local mlv=mc:GetRitualLevel(c)
	if mlv==mc:GetLevel() then return false end
	local lv=c:GetLevel()
	return lv==bit.band(mlv,0xffff) or lv==bit.rshift(mlv,16)
end
-- 判断某个素材是否满足可以用于仪式召唤的条件，包括场上空位和青眼精灵龙的限制
function c51124303.filter(c,e,tp)
	-- 获取所有在手牌中可以被仪式召唤的影灵衣仪式怪兽
	local sg=Duel.GetMatchingGroup(c51124303.spfilter,tp,LOCATION_HAND,0,c,e,tp,c)
	-- 获取玩家主要怪兽区域的可用格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if c:IsLocation(LOCATION_MZONE) then ft=ft+1 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	return sg:IsExists(c51124303.rfilter,1,nil,c) or sg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,ft)
end
-- 筛选额外卡组中等级大于0且可以送去墓地的怪兽
function c51124303.mfilter(c)
	return c:GetLevel()>0 and c:IsAbleToGrave()
end
-- 筛选场上由自己控制的前五个主要怪兽区域内的怪兽
function c51124303.mzfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:GetSequence()<5
end
-- 定义第一个效果的目标处理函数，检查是否有合适的素材可用于仪式召唤
function c51124303.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家主要怪兽区域的可用格数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<0 then return false end
		-- 获取当前可用于仪式召唤的所有素材
		local mg=Duel.GetRitualMaterial(tp)
		if ft>0 then
			-- 获取额外卡组中符合条件的怪兽作为替代解放的素材
			local mg2=Duel.GetMatchingGroup(c51124303.mfilter,tp,LOCATION_EXTRA,0,nil)
			mg:Merge(mg2)
		else
			mg=mg:Filter(c51124303.mzfilter,nil,tp)
		end
		return mg:IsExists(c51124303.filter,1,nil,e,tp)
	end
	-- 设置操作信息，表明将要特殊召唤一只怪兽到手牌
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 验证一组怪兽的等级总和是否等于指定值
function c51124303.RitualCheck(g,lv)
	return g:GetSum(Card.GetLevel)==lv
end
-- 返回一个辅助函数，用于验证一组怪兽的等级总和不超过指定值
function c51124303.RitualCheckAdditional(lv)
	return	function(g)
				return g:GetSum(Card.GetLevel)<=lv
			end
end
-- 定义第一个效果的操作处理函数，实现选择素材并进行仪式召唤的过程
function c51124303.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家主要怪兽区域的可用格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<0 then return end
	::cancel::
	-- 获取当前可用于仪式召唤的所有素材
	local mg=Duel.GetRitualMaterial(tp)
	if ft>0 then
		-- 获取额外卡组中符合条件的怪兽作为替代解放的素材
		local mg2=Duel.GetMatchingGroup(c51124303.mfilter,tp,LOCATION_EXTRA,0,nil)
		mg:Merge(mg2)
	else
		mg=mg:Filter(c51124303.mzfilter,nil,tp)
	end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local mat=mg:FilterSelect(tp,c51124303.filter,1,1,nil,e,tp)
	local mc=mat:GetFirst()
	if not mc then return end
	-- 获取所有在手牌中可以被仪式召唤的影灵衣仪式怪兽
	local sg=Duel.GetMatchingGroup(c51124303.spfilter,tp,LOCATION_HAND,0,mc,e,tp,mc)
	if mc:IsLocation(LOCATION_MZONE) then ft=ft+1 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local b1=sg:IsExists(c51124303.rfilter,1,nil,mc)
	local b2=sg:CheckWithSumEqual(Card.GetLevel,mc:GetLevel(),1,ft)
	-- 询问玩家是否将所选素材作为等级数值来使用
	if b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(51124303,0))) then  --"是否作为仪式召唤需要的等级数值的解放使用？"
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=sg:Filter(c51124303.rfilter,nil,mc):SelectUnselect(nil,tp,false,true,1,1)
		if not tc then goto cancel end
		tc:SetMaterial(mat)
		if not mc:IsLocation(LOCATION_EXTRA) then
			-- 解放仪式召唤所需的素材
			Duel.ReleaseRitualMaterial(mat)
		else
			-- 将额外卡组的怪兽送去墓地作为仪式召唤的代价
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		-- 中断当前效果处理流程，防止后续操作被视为同时发生
		Duel.BreakEffect()
		-- 以仪式召唤的方式特殊召唤一只怪兽
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	else
		local lv=mc:GetLevel()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 设置全局检查函数，用于验证等级总和不超过指定值
		aux.GCheckAdditional=c51124303.RitualCheckAdditional(lv)
		local tg=sg:SelectSubGroup(tp,c51124303.RitualCheck,true,1,ft,lv)
		-- 清除全局检查函数
		aux.GCheckAdditional=nil
		if not tg then goto cancel end
		local tc=tg:GetFirst()
		while tc do
			tc:SetMaterial(mat)
			tc=tg:GetNext()
		end
		if not mc:IsLocation(LOCATION_EXTRA) then
			-- 解放仪式召唤所需的素材
			Duel.ReleaseRitualMaterial(mat)
		else
			-- 将额外卡组的怪兽送去墓地作为仪式召唤的代价
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		-- 中断当前效果处理流程，防止后续操作被视为同时发生
		Duel.BreakEffect()
		tc=tg:GetFirst()
		while tc do
			-- 逐步特殊召唤多只怪兽（每次召唤一只）
			Duel.SpecialSummonStep(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
			tc=tg:GetNext()
		end
		-- 完成所有的特殊召唤步骤
		Duel.SpecialSummonComplete()
	end
end
-- 定义第二个效果的条件函数，检查自己场上没有怪兽存在
function c51124303.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有怪兽存在
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 筛选墓地中属于影灵衣系列的怪兽，并且可以被除外作为费用
function c51124303.cfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 定义第二个效果的成本支付函数，检查是否可以移除这张卡和其他所需材料
function c51124303.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查是否存在至少一只可以被除外的影灵衣怪兽
		and Duel.IsExistingMatchingCard(c51124303.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择一只符合条件的怪兽从墓地除外
	local g=Duel.SelectMatchingCard(tp,c51124303.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 将选定的卡片以成本原因从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 筛选卡组中属于影灵衣系列的魔法卡，并且可以加入手牌
function c51124303.thfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 定义第二个效果的目标处理函数，检查是否存在可以检索的影灵衣魔法卡
function c51124303.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在至少一张可以加入手牌的影灵衣魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c51124303.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表明将要把一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义第二个效果的操作处理函数，选择并加入一张影灵衣魔法卡到手牌
function c51124303.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择一张符合条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c51124303.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选定的卡片送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手展示刚刚加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
