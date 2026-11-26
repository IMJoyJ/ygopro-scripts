--森羅の舞踏娘 ピオネ
-- 效果：
-- 植物族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从自己卡组上面把最多3张卡翻开。那之中有植物族怪兽的场合，可以选那之内的最多2只特殊召唤。剩下的卡送去墓地。这个效果特殊召唤的怪兽不能作为连接素材。
-- ②：以自己墓地1只植物族怪兽为对象才能发动。这张卡所连接区的怪兽的等级直到回合结束时变成和作为对象的怪兽相同。
local s,id,o=GetID()
-- 初始化卡片效果：设置复苏限制与连接召唤手续，并注册①效果（连接召唤成功翻开卡组特召植物族并余卡送墓）与②效果（令连接区怪兽等级变为墓地对象怪兽的等级）
function c21903613.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤条件：需要植物族怪兽2只作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PLANT),2,2)
	-- 植物族怪兽2只 这个卡名的①②的效果1回合各能使用1次。 ①：这张卡连接召唤成功的场合才能发动。从自己卡组上面把最多3张卡翻开。那之中有植物族怪兽的场合，可以选那之内的最多2只特殊召唤。剩下的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21903613,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
-- ①效果的发动条件检查：确认这张卡是通过连接召唤登场的
function c21903613.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果的发动检测：确认己方可以把卡组顶至少1张卡送去墓地
function c21903613.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认己方卡组允许将卡组顶至少1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 筛选条件：检查卡片是否为可特殊召唤的植物族怪兽
function c21903613.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理前半部分：检查卡组剩余张数并让己方在1至3张之间宣言要从卡组上面翻开的卡片数量
function c21903613.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认己方可以把卡组顶1张卡送去墓地，否则终止处理
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 获取己方卡组剩余的卡片总数
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	local ac=1
	if ct>1 then
		if ct>3 then ct=3 end
		local t={}
		for i=1,ct do t[i]=i end
		-- 向己方提示选择要翻开的卡片数量
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(21903613,2))  --"请选择要翻开的卡的数量"
		-- 让己方从可选数量（最多3张）中宣言要翻开的卡的数量
		ac=Duel.AnnounceNumber(tp,table.unpack(t))
	end
	-- 从己方卡组最上方翻开宣言数量的卡并公开确认
	Duel.ConfirmDecktop(tp,ac)
	-- 获取己方卡组最上方被翻开的卡片组
	local g=Duel.GetDecktopGroup(tp,ac)
	local og=g:Filter(c21903613.spfilter,nil,e,tp)
	-- 计算本次最多可特殊召唤的怪兽数量（取己方怪兽区空位数与2的较小值）
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	-- 若翻开的卡中有可特召的植物族怪兽且己方怪兽区有空位，询问己方是否从中特殊召唤
	if og:GetCount()>0 and ft>0 and Duel.SelectYesNo(tp,aux.Stringid(21903613,3)) then  --"是否选植物族怪兽特殊召唤？"
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 向己方提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=og:Select(tp,1,ft,nil)
		-- 遍历所选将要特殊召唤的每只植物族怪兽
		for tc in aux.Next(sg) do
			-- 禁用下一次操作后的卡组洗切检测，避免在分步特殊召唤过程中洗切卡组
			Duel.DisableShuffleCheck()
			-- 执行分步特殊召唤，将当前遍历的植物族怪兽以表侧表示特殊召唤到己方场上
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
		-- 完成所有分步特殊召唤并统一触发召唤相关时点
		Duel.SpecialSummonComplete()
	end
	-- 禁用下一次操作后的卡组洗切检测
	Duel.DisableShuffleCheck()
	-- 将翻开后剩余的卡片以翻卡效果送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
end
-- 筛选条件：检查墓地卡片是否为有等级的植物族怪兽，且这张卡所连接区存在等级与之不同的表侧怪兽
function c21903613.lvfilter1(c,tp,lg)
	return c:IsRace(RACE_PLANT) and c:IsLevelAbove(1)
		-- 确认这张卡所连接区存在至少1只表侧表示、有等级且等级与该墓地怪兽不同的怪兽
		and Duel.IsExistingMatchingCard(c21903613.lvfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg,c:GetLevel())
end
-- 筛选条件：检查场上怪兽是否表侧表示、拥有等级、位于连接区且当前等级不等于目标等级
function c21903613.lvfilter2(c,g,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and g:IsContains(c) and not c:IsLevel(lv)
end
-- ②效果的发动检测与取对象：获取这张卡连接区的怪兽组，并从己方墓地选择1只符合条件的植物族怪兽作为对象
function c21903613.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21903613.lvfilter1(chkc,tp,lg) end
	-- 发动条件检查：确认己方墓地存在可成为对象的植物族怪兽且连接区有可改变等级的怪兽
	if chk==0 then return Duel.IsExistingTarget(c21903613.lvfilter1,tp,LOCATION_GRAVE,0,1,nil,tp,lg) end
	-- 向己方提示选择效果的对象怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让己方从己方墓地选择1只符合条件的植物族怪兽作为当前连锁的对象
	Duel.SelectTarget(tp,c21903613.lvfilter1,tp,LOCATION_GRAVE,0,1,1,nil,tp,lg)
end
-- ②效果的处理流程：读取墓地对象怪兽的等级，并将这张卡连接区内所有符合条件的怪兽等级直到回合结束时变为该等级
function c21903613.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁所指定的墓地对象怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local lg=c:GetLinkedGroup()
	local lv=tc:GetLevel()
	-- 获取这张卡连接区内所有需要变更等级的表侧怪兽组
	local g=Duel.GetMatchingGroup(c21903613.lvfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil,lg,lv)
	-- 遍历连接区内所有待改变等级的怪兽
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
