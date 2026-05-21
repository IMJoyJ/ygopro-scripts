--ナイトメア・スローン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，以下效果可以适用。
-- ●从卡组选1只攻击力和守备力是0的恶魔族怪兽加入手卡或破坏。
-- ②：1回合1次，自己场上的表侧表示的「于贝尔」怪兽因效果从场上离开的场合才能发动。原本等级比那之内的1只要高1星或低1星的1只「于贝尔」怪兽从自己的卡组·墓地·除外状态加入手卡。那之后，可以把那只怪兽无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动（效果①）和场地区诱发效果（效果②）。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，以下效果可以适用。●从卡组选1只攻击力和守备力是0的恶魔族怪兽加入手卡或破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己场上的表侧表示的「于贝尔」怪兽因效果从场上离开的场合才能发动。原本等级比那之内的1只要高1星或低1星的1只「于贝尔」怪兽从自己的卡组·墓地·除外状态加入手卡。那之后，可以把那只怪兽无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中攻击力和守备力均为0的恶魔族怪兽。
function s.thfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAttack(0) and c:IsDefense(0)
end
-- 卡片发动时的效果处理函数，可选择将卡组中攻守为0的恶魔族怪兽加入手卡或破坏。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的攻守为0的恶魔族怪兽。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的怪兽，询问玩家是否适用该效果。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否选卡组的恶魔族怪兽？"
		-- 提示玩家选择要操作的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		-- 若该卡可以加入手卡，询问玩家是否选择将其破坏（若不破坏则加入手卡）。
		if tc:IsAbleToHand() and not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把那只怪兽破坏？"
			-- 将选中的怪兽加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的卡片。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的怪兽破坏。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- 过滤因效果从自己场上离开的表侧表示的「于贝尔」怪兽。
function s.cfilter(c,tp)
	return c:IsSetCard(0x1a5) and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果②的发动条件：检查是否有符合条件的「于贝尔」怪兽因效果从场上离开。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤出等级与目标怪兽相差1星（高1星或低1星）的已离场「于贝尔」怪兽。
function s.filter(c,lv,tp)
	return s.cfilter(c,tp) and (c:IsLevel(lv-1) or c:IsLevel(lv+1))
end
-- 过滤卡组、墓地、除外状态中，原本等级比离场的「于贝尔」怪兽高1星或低1星且能加入手卡的「于贝尔」怪兽。
function s.spfilter(c,e,tp,eg)
	local lv=c:GetLevel()
	return c:IsSetCard(0x1a5) and c:IsFaceupEx() and c:IsAbleToHand()
		and eg:IsExists(s.filter,1,nil,lv,tp)
end
-- 过滤卡组、墓地、除外状态中，原本等级比离场的「于贝尔」怪兽高1星或低1星且能加入手卡的「于贝尔」怪兽（用于效果处理时）。
function s.spfilter2(c,e,tp,g)
	local lv=c:GetLevel()
	return c:IsSetCard(0x1a5) and c:IsFaceupEx() and c:IsAbleToHand()
		and g:IsExists(s.filter2,1,nil,lv,tp)
end
-- 过滤等级相差1星的辅助函数。
function s.filter2(c,lv,tp)
	return (c:IsLevel(lv-1) or c:IsLevel(lv+1))
end
-- 效果②的发动准备与目标确认，保存离场的怪兽信息并设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查卡组、墓地、除外状态是否存在符合条件的「于贝尔」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,eg) end
	local g1=eg:Filter(s.cfilter,nil,tp)
	g1:KeepAlive()
	e:SetLabelObject(g1)
	-- 设置连锁的操作信息为：从卡组、墓地或除外状态将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果②的效果处理：将符合条件的「于贝尔」怪兽加入手卡，之后可选择无视召唤条件特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g1=e:GetLabelObject()
	-- 提示玩家选择要操作的卡片（此处提示信息为特殊召唤，实际用于选择加入手卡的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组、墓地（受王家之谷影响）、除外状态中选择1只符合等级条件的「于贝尔」怪兽。
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,g1)
	local tc=sg:GetFirst()
	-- 若成功将选中的怪兽加入手卡。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 向对方玩家确认加入手卡的怪兽。
		Duel.ConfirmCards(1-tp,tc)
		-- 若怪兽区有空位、该怪兽可以特殊召唤，则询问玩家是否特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤处理与加入手卡不视为同时进行。
			Duel.BreakEffect()
			-- 将该怪兽无视召唤条件以表侧表示特殊召唤。
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
