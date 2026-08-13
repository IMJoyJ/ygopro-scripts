--プリマの光
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：可以从以下效果选择1个发动。
-- ●自己场上1只战士族·地属性怪兽解放，从手卡·卡组把1只战士族·光属性怪兽特殊召唤。
-- ●自己·对方的主要阶段才能发动。进行手卡1只战士族怪兽的召唤。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只战士族·天使族的「电子」怪兽加入手卡。
local s,id,o=GetID()
-- 初始化效果：为「女主角之光」注册两个效果——①：作为魔法卡发动，可在两个选项（解放并特殊召唤 / 进行通常召唤）中选择1个；②：在墓地作为起动效果，除外自身并检索「电子」怪兽。两者通过SetCountLimit(1,id)共享1回合1次的次数限制。
function s.initial_effect(c)
	-- 对应①效果：『①：可以从以下效果选择1个发动。●自己场上1只战士族·地属性怪兽解放，从手卡·卡组把1只战士族·光属性怪兽特殊召唤。●自己·对方的主要阶段才能发动。进行手卡1只战士族怪兽的召唤。』
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
	-- 对应②效果：『②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只战士族·天使族的「电子」怪兽加入手卡。』
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 设置②效果的发动代价为：把墓地中的这张卡除外（aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 获取可解放的战士族·地属性怪兽集合：先取得tp场上可作为效果解放的怪兽，如果其中有带有「必须使用的代替解放」（EFFECT_EXTRA_RELEASE）效果的怪兽，则只将这些怪兽作为候选，否则使用全部可解放怪兽；再经s.cfilter过滤。
function s.getrg(tp,chk)
	-- 获取tp场上可作为效果解放的怪兽集合（不包含手卡，解放理由为效果）。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT)
	local mrg=rg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RELEASE)
	if mrg:GetCount()>0 then
		return mrg:Filter(s.cfilter,nil,tp,chk)
	else
		return rg:Filter(s.cfilter,nil,tp,chk)
	end
end
-- 过滤条件：怪兽必须为战士族·地属性，且可以被效果解放；若chk为真，还要求解放后tp场上仍有可用怪兽区（为后续特殊召唤预留）。
function s.cfilter(c,tp,chk)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsReleasableByEffect()
		-- 当chk为真时，额外确认该怪兽被解放后tp场上有空余怪兽区，否则该选项不可用。
		and (not chk or Duel.GetMZoneCount(tp,c)>0)
end
-- 特殊召唤的过滤条件：怪兽必须为战士族·光属性，且允许通过本次效果e特殊召唤（不检查召唤条件与苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 通常召唤的过滤条件：手卡中的战士族怪兽，且当前可以被通常召唤（忽略本回合通常召唤次数限制）。
function s.sumfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsSummonable(true,nil)
end
-- ①效果发动时的目标处理：检查选项1（有可解放的战士族·地属性怪兽且手卡·卡组有可特召的战士族·光属性怪兽）和选项2（处于主要阶段且有手卡战士族怪兽可召唤）是否可行；若可行则让玩家选择1个选项，将结果存入效果标签，并设置对应的操作信息（解放/特殊召唤或召唤）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=s.getrg(tp,true)
	local b1=rg:GetCount()>0
		-- 检查手卡·卡组中是否存在至少1张符合条件的战士族·光属性怪兽可供特殊召唤（选项1的可行性条件之一）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	-- 检查当前是否为主要阶段且手卡中是否存在可通常召唤的战士族怪兽（选项2的可行性条件）。
	local b2=Duel.IsMainPhase() and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 调用aux.SelectFromOptions，让玩家从可用的选项中选择一个；后续参数为各选项的有效性、选项文本和返回值（1表示解放并特殊召唤，2表示进行召唤）。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"解放并特殊召唤"
			{b2,aux.Stringid(id,3),2})  --"进行召唤"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置操作信息：本次效果将包含1次解放（对象在效果处理时确定，因此targets为nil）。
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,0)
		-- 设置操作信息：本次效果将把1只怪兽从手卡·卡组特殊召唤到tp场上（对象不确定，因此targets为nil）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SUMMON)
		end
		-- 设置操作信息：本次效果将进行1次手卡怪兽的通常召唤（对象不确定，因此targets为nil）。
		Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
	end
end
-- ①效果处理：根据发动时选择的选项执行——若选择1，则解放1只战士族·地属性怪兽后，从手卡·卡组特殊召唤1只战士族·光属性怪兽；若选择2，则进行手卡1只战士族怪兽的通常召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示tp玩家选择要解放的卡片（HINTMSG_RELEASE）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		local srg=s.getrg(tp,true)
		if srg:GetCount()==0 then
			srg=s.getrg(tp,false)
		end
		local rg=srg:Select(tp,1,1,nil)
		-- 若玩家选择的解放对象存在，则将其以效果原因解放；只有解放成功（数量>0）后继续后续处理。
		if rg:GetCount()>0 and Duel.Release(rg,REASON_EFFECT)>0
			-- 同时确认tp场上有空余怪兽区，能够进行特殊召唤，否则中止处理。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示tp玩家选择要特殊召唤的卡片（HINTMSG_SPSUMMON）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从tp手卡·卡组中选择1张符合条件的战士族·光属性怪兽，并设为对象。
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
			if sg:GetCount()>0 then
				-- 将选择的怪兽以表侧表示特殊召唤到tp场上（不检查召唤条件与苏生限制）。
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif e:GetLabel()==2 then
		-- 提示tp玩家选择要召唤的卡片（HINTMSG_SUMMON）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
		-- 从tp手卡中选择1张符合条件的战士族怪兽（若选择成功则取出该卡）。
		local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
		if tc then
			-- 将选择的怪兽进行通常召唤；ignore_count=true表示不消耗本回合的通常召唤次数，e=nil表示按一般规则处理。
			Duel.Summon(tp,tc,true,nil)
		end
	end
end
-- ②检索的过滤条件：卡名含有「电子」（0x93）字段，种族为天使族或战士族，且能够加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x93) and c:IsRace(RACE_FAIRY+RACE_WARRIOR) and c:IsAbleToHand()
end
-- ②的发动目标判定：卡组中存在符合条件的「电子」怪兽才可发动；通过后设置操作信息，表示将从卡组把1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查阶段：确认卡组中是否存在至少1张符合s.thfilter条件的「电子」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将把1张卡从卡组加入手卡（对象不确定为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张符合条件的「电子」怪兽加入手卡，并向对方展示确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示tp玩家选择要加入手卡的卡片（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从tp卡组中选择1张符合条件的「电子」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片以效果原因加入其持有者的手卡（nil表示返回原持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
