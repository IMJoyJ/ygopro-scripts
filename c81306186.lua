--リターン・オブ・ザ・ワールド
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：作为这张卡的发动时的效果处理，从卡组把1只仪式怪兽除外。
-- ②：可以把这张卡送去墓地，从以下效果选择1个发动。
-- ●直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上1只怪兽解放或者作为解放的代替而让自己墓地1只仪式怪兽回到卡组，把这张卡的①的效果除外的怪兽仪式召唤。
-- ●这张卡的效果除外的怪兽加入手卡。
function c81306186.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，从卡组把1只仪式怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,81306186)
	e1:SetTarget(c81306186.rmtg)
	e1:SetOperation(c81306186.rmop)
	c:RegisterEffect(e1)
	-- ②：可以把这张卡送去墓地，从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,81306186)
	e2:SetLabelObject(e1)
	e2:SetCost(c81306186.cost)
	e2:SetTarget(c81306186.target)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可以被除外的仪式怪兽
function c81306186.filter(c)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToRemove()
end
-- ①效果的发动准备，确认卡组中存在可除外的仪式怪兽并设置操作信息
function c81306186.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可以除外的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c81306186.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果会将卡组的1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理，从卡组选择1只仪式怪兽除外，并给该卡注册标记和关联到效果上
function c81306186.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从卡组选择1只满足过滤条件的仪式怪兽
	local tc=Duel.SelectMatchingCard(tp,c81306186.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 如果成功将选中的怪兽表侧表示除外
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		tc:RegisterFlagEffect(81306186,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(tc)
	end
end
-- ②效果的发动代价，将这张卡送去墓地
function c81306186.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将作为发动代价的这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ②效果的发动准备，获取被除外的怪兽，判断并让玩家选择发动“仪式召唤”或“加入手卡”效果，并设置相应的操作信息
function c81306186.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject():GetLabelObject()
	-- 获取玩家场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if not tc or tc:IsFacedown() or tc:GetFlagEffect(81306186)==0 then return false end
		local b1=tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
			-- 检查自己的手卡、场上或墓地是否存在至少1只满足解放（或代替解放）条件的怪兽
			and Duel.IsExistingMatchingCard(c81306186.relfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,tc,e,tp,tc,ft)
		local b2=tc:IsAbleToHand()
		return b1 or b2
	end
	local b1=tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
		-- 检查自己的手卡、场上或墓地是否存在至少1只满足解放（或代替解放）条件的怪兽
		and Duel.IsExistingMatchingCard(c81306186.relfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,tc,e,tp,tc,ft)
	local b2=tc:IsAbleToHand()
	local sel=0
	if b1 and b2 then
		-- 当两个效果都能发动时，让玩家选择其中一个效果发动
		sel=Duel.SelectOption(tp,aux.Stringid(81306186,0),aux.Stringid(81306186,1))  --"除外的怪兽仪式召唤/除外的怪兽加入手卡"
	elseif b1 then
		-- 只能发动仪式召唤效果时，让玩家确认并选择该选项
		sel=Duel.SelectOption(tp,aux.Stringid(81306186,0))  --"除外的怪兽仪式召唤"
	else
		-- 只能发动加入手卡效果时，让玩家确认并选择该选项并调整选项索引
		sel=Duel.SelectOption(tp,aux.Stringid(81306186,1))+1  --"除外的怪兽加入手卡"
	end
	if sel==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(c81306186.spop)
		-- 设置特殊召唤的操作信息，表示将特殊召唤被除外的仪式怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
		-- 设置回到卡组的操作信息，表示可能会有墓地的卡回到卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_TOHAND)
		e:SetOperation(c81306186.thop)
		-- 设置加入手卡的操作信息，表示将该除外的怪兽加入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
	end
end
-- 过滤可用于仪式召唤的解放怪兽（手卡/场上）或代替解放回到卡组的墓地仪式怪兽
function c81306186.relfilter(c,e,tp,tc,ft)
	if not c:IsLevelAbove(tc:GetLevel()) then return false end
	if tc.mat_filter and not tc.mat_filter(c,tp) then return false end
	if c:IsLocation(LOCATION_GRAVE) then
		return c:IsType(TYPE_RITUAL) and ft>0 and c:IsAbleToDeck()
	else
		return (ft>0 or c:IsControler(tp)) and c:IsReleasableByEffect(e)
	end
end
-- 仪式召唤效果的处理：选择1只怪兽解放（或让墓地仪式怪兽回到卡组），然后将除外的怪兽仪式召唤
function c81306186.spop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetLabelObject():GetLabelObject()
	if not rc or rc:IsFacedown() or rc:GetFlagEffect(81306186)==0 then return end
	if not rc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return end
	-- 获取玩家场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 提示玩家选择要解放（或代替解放）的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从手卡、场上或墓地选择1只满足条件的怪兽用于仪式召唤
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c81306186.relfilter),tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,1,rc,e,tp,rc,ft):GetFirst()
	if tc then
		rc:SetMaterial(Group.FromCards(tc))
		if tc:IsLocation(LOCATION_GRAVE) then
			-- 选中墓地中作为代替解放而回到卡组的仪式怪兽时，在场上/墓地显示选中动画
			Duel.HintSelection(Group.FromCards(tc))
			-- 将作为代替解放的墓地仪式怪兽回到卡组并洗牌，若失败则中断处理
			if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)==0 then return end
		else
			-- 解放选中的手卡或场上的怪兽，若失败则中断处理
			if Duel.Release(tc,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)==0 then return end
		end
		-- 将除外的仪式怪兽以仪式召唤的方式特殊召唤
		Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		rc:CompleteProcedure()
	end
end
-- 加入手卡效果的处理：将被除外的怪兽加入手卡
function c81306186.thop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetLabelObject():GetLabelObject()
	if not rc or rc:IsFacedown() or rc:GetFlagEffect(81306186)==0 then return end
	-- 将被除外的仪式怪兽加入手卡
	Duel.SendtoHand(rc,nil,REASON_EFFECT)
end
