--青き眼の精霊
-- 效果：
-- 4星以下的龙族·魔法师族怪兽1只
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组选1张「光之灵堂」加入手卡或送去墓地。
-- ②：只要这张卡在怪兽区域存在，自己不是龙族怪兽不能特殊召唤。
-- ③：把这张卡解放才能发动。从自己的手卡·墓地把1只「青眼」怪兽特殊召唤。这个效果从墓地特殊召唤的效果怪兽不能攻击，效果无效化。
local s,id,o=GetID()
-- 对这张卡进行初始化：登记「光之灵堂」卡名、设定连接召唤素材条件、限制非连接召唤特殊召唤，并注册①检索/送墓效果、②龙族限定特殊召唤效果、③解放自身特召青眼怪兽的效果。
function s.initial_effect(c)
	-- 将卡号24382602「光之灵堂」登记为这张卡上记载的卡名，用于支持卡组检索等关联判定。
	aux.AddCodeList(c,24382602)
	-- 设定连接召唤手续：以1只满足s.mfilter条件的4星以下龙族或魔法师族怪兽作为连接素材。
	aux.AddLinkProcedure(c,s.mfilter,1,1)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从卡组选1张「光之灵堂」加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己不是龙族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	-- ③：把这张卡解放才能发动。从自己的手卡·墓地把1只「青眼」怪兽特殊召唤。这个效果从墓地特殊召唤的效果怪兽不能攻击，效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 定义连接素材的过滤条件：素材必须是4星以下、种族为龙族或魔法师族的怪兽。
function s.mfilter(c)
	return (c:IsLinkRace(RACE_DRAGON) or c:IsLinkRace(RACE_SPELLCASTER)) and c:IsLevelBelow(4)
end
-- ①效果的发动条件：这张卡以连接召唤方式成功时才能发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 定义检索/送墓对象的过滤条件：卡名必须是「光之灵堂」，且该卡能够加入手卡或送去墓地。
function s.cfilter(c)
	return c:IsCode(24382602) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- ①效果的发动时点处理：确认卡组中存在符合条件的「光之灵堂」，并设置效果涉及加入手卡与送去墓地的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己卡组中是否存在至少1张满足s.cfilter条件的「光之灵堂」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：宣布此效果可能将1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：宣布此效果可能将1张卡从卡组送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的解决处理：玩家从卡组选择1张「光之灵堂」，视情况选择加入手卡或送去墓地；若加入手卡则向对方确认。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要操作的卡”的选择提示，引导玩家进行卡片选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己卡组选择1张满足s.cfilter条件的「光之灵堂」。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 若该卡可以加入手卡且（不能送去墓地或玩家选择了加入手卡选项），则进入加入手卡分支。
		if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 以效果原因将选择的「光之灵堂」加入其持有者的手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示这张被加入手卡的卡片。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 以效果原因将选择的「光之灵堂」送去墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- ②效果的适用判定：非龙族怪兽不能由自己特殊召唤（只要此卡在怪兽区域存在）。
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsRace(RACE_DRAGON)
end
-- ③效果的发动代价：解放这张卡。先检查其是否可解放，确认后作为代价解放。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以代价（cost）原因解放这张卡。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ③效果的特召对象过滤：怪兽属于「青眼」字段，且能够被效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xdd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动时点处理：确认自己场上有可用怪兽区，并且手卡·墓地中存在可特殊召唤的「青眼」怪兽；同时设置特召操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己场上是否有可用的怪兽区（需要考虑解放这张卡后腾出的区域）。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 并且检查自己手卡·墓地是否存在至少1只满足s.spfilter条件的「青眼」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：宣布此效果将从手卡·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- ③效果的解决处理：确认空位并过滤王家长眠之谷影响后，从手卡·墓地选择1只「青眼」怪兽特殊召唤；若它从墓地特殊召唤且为效果怪兽，则使其效果无效化且不能攻击。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时检查：若自己场上没有可用怪兽区，则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时检查：在手卡·墓地中，不受王家长眠之谷影响的「青眼」怪兽是否存在；若无则终止处理。
	if Duel.GetMatchingGroupCount(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,nil,e,tp)==0 then return end
	-- 弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local c=e:GetHandler()
	-- 从自己手卡·墓地选择1只符合条件的「青眼」怪兽（已排除王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选择怪兽表侧表示特殊召唤；若它是从墓地特殊召唤的效果怪兽，则对其附加无效化、不能攻击等限制。
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) and tc:IsSummonLocation(LOCATION_GRAVE) and tc:IsType(TYPE_EFFECT) then
		-- 效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 不能攻击。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤流程，宣告特殊召唤处理结束。
	Duel.SpecialSummonComplete()
end
