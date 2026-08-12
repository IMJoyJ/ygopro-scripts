--プリマの光
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：可以从以下效果选择1个发动。
-- ●自己场上1只战士族·地属性怪兽解放，从手卡·卡组把1只战士族·光属性怪兽特殊召唤。
-- ●自己·对方的主要阶段才能发动。进行手卡1只战士族怪兽的召唤。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只战士族·天使族的「电子」怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡牌的两个效果：①效果（发动）和②效果（检索）
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只战士族·天使族的「电子」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 效果②的发动需要将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 获取玩家可解放的怪兽组，包括必须使用的代替解放
function s.getrg(tp,chk)
	-- 获取玩家可解放的怪兽组（不包括必须使用的代替解放）
	local rg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT)
	local mrg=rg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RELEASE)
	if mrg:GetCount()>0 then
		return mrg:Filter(s.cfilter,nil,tp,chk)
	else
		return rg:Filter(s.cfilter,nil,tp,chk)
	end
end
-- 筛选满足条件的怪兽：战士族·地属性且可被解放
function s.cfilter(c,tp,chk)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsReleasableByEffect()
		-- 若chk为true，则检查目标怪兽是否能召唤到场上
		and (not chk or Duel.GetMZoneCount(tp,c)>0)
end
-- 筛选满足条件的怪兽：战士族·光属性且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选满足条件的怪兽：战士族且可通常召唤
function s.sumfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsSummonable(true,nil)
end
-- 效果①的发动选择处理，根据条件选择发动选项
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=s.getrg(tp,true)
	local b1=rg:GetCount()>0
		-- 检查手卡和卡组是否存在满足条件的战士族·光属性怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	-- 检查是否在主要阶段且手卡存在满足条件的战士族怪兽
	local b2=Duel.IsMainPhase() and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择效果①的发动选项
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"解放并特殊召唤"
			{b2,aux.Stringid(id,3),2})  --"进行召唤"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置操作信息：解放怪兽
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,0)
		-- 设置操作信息：特殊召唤怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SUMMON)
		end
		-- 设置操作信息：召唤怪兽
		Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
	end
end
-- 效果①的发动处理，根据选择的选项执行不同操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要解放的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		local srg=s.getrg(tp,true)
		if srg:GetCount()==0 then
			srg=s.getrg(tp,false)
		end
		local rg=srg:Select(tp,1,1,nil)
		-- 判断是否成功解放怪兽
		if rg:GetCount()>0 and Duel.Release(rg,REASON_EFFECT)>0
			-- 判断场上是否有空位
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足条件的战士族·光属性怪兽
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
			if sg:GetCount()>0 then
				-- 将选中的怪兽特殊召唤
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
		-- 选择满足条件的战士族怪兽
		local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
		if tc then
			-- 将选中的怪兽通常召唤
			Duel.Summon(tp,tc,true,nil)
		end
	end
end
-- 筛选满足条件的「电子」怪兽：战士族或 Fairy 族且可加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x93) and c:IsRace(RACE_FAIRY+RACE_WARRIOR) and c:IsAbleToHand()
end
-- 效果②的发动处理，设置检索目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的发动处理，执行检索操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到选中的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
