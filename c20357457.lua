--未来の柱－キアノス
-- 效果：
-- 这个卡名在规则上也当作「闪刀」卡使用。这个卡名的①②③的效果1回合各能使用1次。
-- ①：从手卡丢弃1张魔法卡才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1只「闪刀姬-露世」特殊召唤。这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
-- ③：把墓地的这张卡除外才能发动。选自己的墓地·除外状态的1只「闪刀姬-露世」加入手卡或特殊召唤。
local s,id,o=GetID()
-- 注册该卡全部效果：①手牌丢弃魔法卡特召自身的起动效果；②召唤/特殊召唤时从卡组·墓地特召「闪刀姬-露世」并附加额外卡组机械族自肃的诱发效果；③除外墓地的自身，选墓地·除外的「闪刀姬-露世」加入手卡或特殊召唤的起动效果。
function s.initial_effect(c)
	-- ①：从手卡丢弃1张魔法卡才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1只「闪刀姬-露世」特殊召唤。这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组·墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外才能发动。选自己的墓地·除外状态的1只「闪刀姬-露世」加入手卡或特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"加入手卡或特殊召唤"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	-- 设置③效果发动时需把墓地的这张卡除外作为代价。
	e4:SetCost(aux.bfgcost)
	e4:SetCountLimit(1,id+o*2)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 定义代价过滤条件：手牌中的魔法卡且可以被丢弃。
function s.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- ①效果的代价：确认手牌有可丢弃的魔法卡后，丢弃1张手牌魔法卡。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：手牌中是否存在1张可丢弃的魔法卡（不选择自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：从手牌丢弃1张魔法卡，丢弃原因同时视为代价与丢弃。
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- ①效果的发动条件：主要怪兽区有空位，且这张卡能被自己以表侧表示特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁将进行特殊召唤的操作信息，供后续时点/效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡特殊召唤到自己的主要怪兽区。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义选择「闪刀姬-露世」的过滤条件：卡号为37351133且能够被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsCode(37351133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件：主要怪兽区有空位，且卡组·墓地存在可特殊召唤的「闪刀姬-露世」。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认主要怪兽区有空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组·墓地存在至少1只满足条件的「闪刀姬-露世」。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记本次连锁从卡组·墓地特殊召唤的操作信息，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果处理：从卡组·墓地选择并特殊召唤1只「闪刀姬-露世」，然后给自己附加“不是机械族怪兽不能从额外卡组特殊召唤”的回合自肃。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 在特殊召唤前再次确认主要怪兽区仍有空格。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示选择提示，让玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组·墓地选择1只符合条件的「闪刀姬-露世」，并排除王家长眠之谷的影响。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「闪刀姬-露世」特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。③：把墓地的这张卡除外才能发动。选自己的墓地·除外状态的1只「闪刀姬-露世」加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把“不能特殊召唤非机械族额外怪兽”的限制效果注册给当前玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定：额外卡组的怪兽若种族不是机械族则不能特殊召唤。
function s.splimit(e,c)
	return not c:IsRace(RACE_MACHINE) and c:IsLocation(LOCATION_EXTRA)
end
-- 定义③效果的选择对象条件：卡名是「闪刀姬-露世」、表侧表示且在墓地·除外状态，并且能加入手卡或能被特殊召唤。
function s.thfilter(c,e,tp)
	return c:IsCode(37351133) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false)) and c:IsFaceupEx()
end
-- ③效果的发动条件：自己的墓地·除外状态存在符合条件的「闪刀姬-露世」。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查墓地·除外是否存在至少1只符合③条件的「闪刀姬-露世」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
end
-- ③效果处理：选择1只符合条件的「闪刀姬-露世」，若不能特殊召唤或玩家选择加入手卡则将其加入手卡，否则特殊召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从墓地·除外状态选择1只符合条件的「闪刀姬-露世」（已规避王家长眠之谷）。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 若该卡不能被特殊召唤，或玩家选择了“加入手卡”，则执行加入手卡；否则执行特殊召唤。
		if not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or Duel.SelectOption(tp,1190,1152)==0 then
			-- 将选择的「闪刀姬-露世」加入持有者的手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡片。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选择的「闪刀姬-露世」特殊召唤到自己的主要怪兽区。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
