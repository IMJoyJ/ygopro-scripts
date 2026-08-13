--森羅の舞踏娘 ピオネ
-- 效果：
-- 植物族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从自己卡组上面把最多3张卡翻开。那之中有植物族怪兽的场合，可以选那之内的最多2只特殊召唤。剩下的卡送去墓地。这个效果特殊召唤的怪兽不能作为连接素材。
-- ②：以自己墓地1只植物族怪兽为对象才能发动。这张卡所连接区的怪兽的等级直到回合结束时变成和作为对象的怪兽相同。
local s,id,o=GetID()
-- 初始化卡片效果：设置连接召唤手续（对应‘植物族怪兽2只’），注册①和②效果，并分别设置1回合1次使用限制（这个卡名的①②的效果1回合各能使用1次）。
function c21903613.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，要求以2只植物族怪兽作为连接素材（对应效果原文‘植物族怪兽2只’）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PLANT),2,2)
	-- ①：这张卡连接召唤成功的场合才能发动。从自己卡组上面把最多3张卡翻开。那之中有植物族怪兽的场合，可以选那之内的最多2只特殊召唤。剩下的卡送去墓地。这个效果特殊召唤的怪兽不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21903613,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,21903613)
	e1:SetCondition(c21903613.condition)
	e1:SetTarget(c21903613.target)
	e1:SetOperation(c21903613.operation)
	c:RegisterEffect(e1)
	-- ②：以自己墓地1只植物族怪兽为对象才能发动。这张卡所连接区的怪兽的等级直到回合结束时变成和作为对象的怪兽相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21903613,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21903613+o)
	e2:SetTarget(c21903613.lvtg)
	e2:SetOperation(c21903613.lvop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：确认这张卡是以连接召唤方式成功特殊召唤。
function c21903613.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果的发动合法性检查：确认玩家卡组顶端至少有1张卡可以送去墓地，确保效果处理时有卡可翻开并处理。
function c21903613.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查玩家是否可以把卡组顶端1张卡送去墓地，作为发动①效果的前提条件。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 翻开卡中可特殊召唤的过滤条件：植物族怪兽，且能够被当前效果以无祭品、无位置限制等方式特殊召唤到玩家场上。
function c21903613.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果处理：确认卡组可丢弃后，计算卡组数量并让玩家选择要翻开的卡数（最多3张），准备翻开卡组。
function c21903613.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认玩家卡组顶端至少有1张卡可送去墓地，否则终止处理。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 获取玩家卡组当前的卡片总数，用于限制最多翻开3张。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	local ac=1
	if ct>1 then
		if ct>3 then ct=3 end
		local t={}
		for i=1,ct do t[i]=i end
		-- 向玩家显示“请选择要翻开的卡的数量”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(21903613,2))  --"请选择要翻开的卡的数量"
		-- 让玩家宣言一个数字（1到可翻开的最大数量），作为实际要翻开的卡片数量。
		ac=Duel.AnnounceNumber(tp,table.unpack(t))
	end
	-- 将玩家卡组最上方ac张卡公开确认（即翻开这些卡）。
	Duel.ConfirmDecktop(tp,ac)
	-- 获取被翻开的卡组最上方ac张卡，作为后续处理的对象组。
	local g=Duel.GetDecktopGroup(tp,ac)
	local og=g:Filter(c21903613.spfilter,nil,e,tp)
	-- 计算玩家场上可用的主要怪兽区域空格数，并将本次可特殊召唤的数量上限限制为2（取区域空格数与2的较小值）。
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	-- 如果翻开卡中存在可特殊召唤的植物族怪兽且场上可用区域大于0，则询问玩家是否进行特殊召唤；选择是则继续。
	if og:GetCount()>0 and ft>0 and Duel.SelectYesNo(tp,aux.Stringid(21903613,3)) then  --"是否选植物族怪兽特殊召唤？"
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 显示“请选择要特殊召唤的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=og:Select(tp,1,ft,nil)
		-- 遍历玩家选择要特殊召唤的怪兽组中的每张卡。
		for tc in aux.Next(sg) do
			-- 禁用本次操作后的卡组自动洗切检查，因为特殊召唤后剩余卡将直接送去墓地，无需洗切。
			Duel.DisableShuffleCheck()
			-- 将当前卡片以表侧表示特殊召唤到玩家场上（分步特殊召唤）；若成功则执行后续处理。
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				-- 这个效果特殊召唤的怪兽不能作为连接素材。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				g:RemoveCard(tc)
			end
		end
		-- 完成所有分步特殊召唤，正式宣告特殊召唤成功。
		Duel.SpecialSummonComplete()
	end
	-- 禁用随后的卡组洗切检查，以便直接将剩余翻开卡送去墓地而不触发洗牌。
	Duel.DisableShuffleCheck()
	-- 将翻开后未被特殊召唤的剩余卡片送去墓地，送墓原因包括效果处理和翻开确认。
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
end
-- ②效果的墓地对象过滤：选择的墓地怪兽必须是植物族且等级1以上，并同时场上存在该卡所连接区的可改变等级的表侧表示怪兽，保证效果能实际改变等级。
function c21903613.lvfilter1(c,tp,lg)
	return c:IsRace(RACE_PLANT) and c:IsLevelAbove(1)
		-- 判断该卡所连接区是否存在表侧表示且等级与目标不同的怪兽，以确认有可被改变等级的怪兽存在。
		and Duel.IsExistingMatchingCard(c21903613.lvfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg,c:GetLevel())
end
-- 过滤出需要改变等级的所连接区怪兽：表侧表示、等级1以上、位于这张卡所连接区、且当前等级不等于目标怪兽等级。
function c21903613.lvfilter2(c,g,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and g:IsContains(c) and not c:IsLevel(lv)
end
-- ②效果的取对象目标处理：从自己墓地选择1只满足条件的植物族怪兽，并确认场上存在可变更等级的所连接区怪兽。
function c21903613.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21903613.lvfilter1(chkc,tp,lg) end
	-- 发动时（chk==0）检查自己墓地是否存在满足lvfilter1的植物族怪兽可作为对象，存在则允许发动。
	if chk==0 then return Duel.IsExistingTarget(c21903613.lvfilter1,tp,LOCATION_GRAVE,0,1,nil,tp,lg) end
	-- 显示“请选择效果的对象”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己墓地选择1只符合条件的植物族怪兽，并将其登记为当前连锁的取对象目标。
	Duel.SelectTarget(tp,c21903613.lvfilter1,tp,LOCATION_GRAVE,0,1,1,nil,tp,lg)
end
-- ②效果处理：若这张卡和对象怪兽仍与效果关联，则取对象怪兽的等级，将这张卡所连接区中满足条件的怪兽的等级变为该等级，持续到回合结束。
function c21903613.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中登记的对象卡片（墓地植物族怪兽）。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local lg=c:GetLinkedGroup()
	local lv=tc:GetLevel()
	-- 获取这张卡所连接区中所有需要变更等级的表侧表示怪兽组（满足lvfilter2条件）。
	local g=Duel.GetMatchingGroup(c21903613.lvfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil,lg,lv)
	-- 遍历所有需要变更等级的连接区怪兽。
	for lc in aux.Next(g) do
		-- 这张卡所连接区的怪兽的等级直到回合结束时变成和作为对象的怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		lc:RegisterEffect(e1)
	end
end
