--TG ロケット・サラマンダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只「科技属」怪兽解放才能发动。原本卡名和解放的怪兽不同的1只「科技属」怪兽从卡组特殊召唤。
-- ②：自己场上有机械族「科技属」怪兽存在的场合，以自己墓地1只4星以下的「科技属」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
local s,id,o=GetID()
-- 注册卡片效果：①起动效果从卡组特召，②起动效果从墓地特召。
function s.initial_effect(c)
	-- ①：把自己场上1只「科技属」怪兽解放才能发动。原本卡名和解放的怪兽不同的1只「科技属」怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.dstg)
	e1:SetOperation(s.dsop)
	c:RegisterEffect(e1)
	-- ②：自己场上有机械族「科技属」怪兽存在的场合，以自己墓地1只4星以下的「科技属」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.gstg)
	e2:SetOperation(s.gsop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上可解放的「科技属」怪兽，且解放后有足够的怪兽区域，并且卡组中存在与其原本卡名不同的可特殊召唤的「科技属」怪兽。
function s.tfilter(c,e,tp)
	-- 检查该怪兽是否为「科技属」怪兽，且将其解放后自身场上是否有可用的怪兽区域。
	return c:IsSetCard(0x27) and Duel.GetMZoneCount(tp,c)>0
		-- 检查卡组中是否存在原本卡名与该怪兽不同、且满足特殊召唤条件的「科技属」怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetOriginalCodeRule())
end
-- 过滤条件：卡组中可以特殊召唤的「科技属」怪兽，且卡名不等于传入的原本卡名。
function s.filter(c,e,tp,...)
	return c:IsSetCard(0x27) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and (#{...}==0 or not c:IsCode(...))
end
-- 效果①的发动代价：检查并选择场上1只「科技属」怪兽解放，并记录其原本卡名。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查场上是否存在满足解放条件的「科技属」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.tfilter,1,nil,e,tp) end
	-- 玩家选择1只满足条件的「科技属」怪兽解放。
	local g=Duel.SelectReleaseGroup(tp,s.tfilter,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetOriginalCodeRule())
	-- 将选择的怪兽作为发动代价解放。
	Duel.Release(g,REASON_COST)
end
-- 效果①的发动准备：检查是否已支付代价，并设置特殊召唤的操作信息。
function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置连锁信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组将1只原本卡名与解放怪兽不同的「科技属」怪兽特殊召唤。
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只原本卡名与解放怪兽不同的「科技属」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	-- 将选择的怪兽表侧表示特殊召唤。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：场上表侧表示的机械族「科技属」怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsSetCard(0x27)
end
-- 效果②的发动条件：自己场上有机械族「科技属」怪兽存在。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的机械族「科技属」怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：墓地中4星以下、可以守备表示特殊召唤的「科技属」怪兽。
function s.sfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x27)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动准备：检查并选择墓地中1只4星以下的「科技属」怪兽作为对象，并设置特殊召唤的操作信息。
function s.gstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc,e,tp) end
	-- 步骤0：检查自身场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在满足条件的「科技属」怪兽。
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只满足条件的「科技属」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息：特殊召唤选择的对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的怪兽守备表示特殊召唤，并将其效果无效化。
function s.gsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时作为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于墓地，则将其守备表示特殊召唤（分步处理）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的后续处理。
	Duel.SpecialSummonComplete()
end
