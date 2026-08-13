--召煌女クインクエリ
-- 效果：
-- 5星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除，以自己或对方的墓地1只5星怪兽为对象才能发动。那只怪兽在自己或对方的场上特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，自己场上的表侧表示的5星怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从卡组选1只5星怪兽加入手卡或特殊召唤。
local s,id,o=GetID()
-- 定义卡片的初始效果：添加XYZ召唤手续（5星×2）、苏生限制，并注册①起动效果与②诱发效果。
function s.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用任意2只5星怪兽叠放作为XYZ素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以自己或对方的墓地1只5星怪兽为对象才能发动。那只怪兽在自己或对方的场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，自己场上的表侧表示的5星怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从卡组选1只5星怪兽加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：从这张卡上取除1个超量素材（先检查能否取除，再实际取除）。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 墓地5星怪兽的选卡过滤器：要求等级为5，并且能特殊召唤到己方或对方场上（根据双方怪兽区空格和召唤合法性）。
function s.spfilter(c,e,tp)
	-- 满足过滤条件的前半部分：该卡是5星怪兽，且自己怪兽区有空位并可由本效果特殊召唤到自己场上。
	return c:IsLevel(5) and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 满足过滤条件的后半部分：或对方怪兽区有空位并可由本效果特殊召唤到对方场上（表侧表示）。
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
-- ①效果的发动目标：选择双方墓地中1只满足条件的5星怪兽作为对象，并设定特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 发动的合法性检查：确认双方墓地存在至少1只满足条件的5星怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向当前玩家给出选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从双方墓地选择1只满足条件的5星怪兽作为效果对象，并将该卡关联到当前连锁。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置连锁操作信息：本连锁将进行特殊召唤，对象为选择的那只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：取得对象怪兽，若对象仍与效果关联，则让玩家选择在自己或对方场上特殊召唤，并实际进行特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 判断对象能否特殊召唤到自己场上：自己怪兽区有空位且该卡可以被本效果特殊召唤。
	local s1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 判断对象能否特殊召唤到对方场上：对方怪兽区有空位且该卡可以被本效果以表侧表示特殊召唤到对方场上。
	local s2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	-- 让当前玩家在可用选项中选出要特殊召唤的场地（自己/对方）；不可用选项会被过滤。
	local toplayer=aux.SelectFromOptions(tp,
		{s1,aux.Stringid(id,1),tp},  --"在自己场上特殊召唤"
		{s2,aux.Stringid(id,2),1-tp})  --"在对方场上特殊召唤"
	if toplayer~=nil then
		-- 将对象表侧表示特殊召唤到所选玩家的怪兽区。
		Duel.SpecialSummon(tc,0,tp,toplayer,false,false,POS_FACEUP)
	end
end
-- ②触发条件过滤器：离开场上的怪兽必须此前在自己场上表侧表示、从怪兽区离场、原等级为5，并且离场原因是战斗破坏或对方发动的效果。
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:GetPreviousLevelOnField()==5 and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- ②的发动条件：离场怪兽群中不包含这张卡自身，并且存在1只满足cfilter条件的5星怪兽（即符合离场条件）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,tp)
end
-- ②检索的卡组怪兽过滤器：等级为5，且能够加入手卡，或者在怪兽区有空位时能够特殊召唤。
function s.dfilter(c,e,tp,ft)
	return c:IsLevel(5) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ②效果的发动目标：确认卡组中存在至少1只满足条件的5星怪兽，有则可发动。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己场上主要怪兽区的可用空格数，用于判断能否特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 发动合法性检查：从卡组中查找是否存在满足dfilter条件的5星怪兽（ft作为额外参数传入）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
end
-- ②效果处理：从卡组选1只5星怪兽，优先根据玩家选择决定特殊召唤还是加入手卡；只能加入手卡时则加入手卡，并向对方确认。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上主要怪兽区的可用空格数，用于处理时判断能否特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 向当前玩家给出选择提示：请选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己卡组选择1只满足dfilter条件的5星怪兽。
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	if tc then
		if ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 当该卡可以特殊召唤，且（不能加入手卡或玩家选择了“特殊召唤”）时，执行特殊召唤；否则执行加入手卡。
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选中的5星怪兽表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选中的5星怪兽加入其持有者的手卡（原因记为效果处理）。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 将加入手卡的这张卡向对方玩家确认（展示）。
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
