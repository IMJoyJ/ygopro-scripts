--森羅の舞踏娘 ピオネ
-- 效果：
-- 植物族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从自己卡组上面把最多3张卡翻开。那之中有植物族怪兽的场合，可以选那之内的最多2只特殊召唤。剩下的卡送去墓地。这个效果特殊召唤的怪兽不能作为连接素材。
-- ②：以自己墓地1只植物族怪兽为对象才能发动。这张卡所连接区的怪兽的等级直到回合结束时变成和作为对象的怪兽相同。
local s,id,o=GetID()
-- 初始化卡片效果，设置连接召唤手续并注册两个效果
function c21903613.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤需要2只植物族怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PLANT),2,2)
	-- 效果①：连接召唤成功时发动，翻开最多3张卡，若其中有植物族怪兽则可特殊召唤最多2只
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
	-- 效果②：以墓地1只植物族怪兽为对象，使连接区怪兽等级变为与该怪兽相同
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
-- 效果①的发动条件：此卡为连接召唤成功
function c21903613.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的发动准备：检查玩家是否可以丢弃卡组顶部1张卡
function c21903613.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以丢弃卡组顶部1张卡
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 特殊召唤过滤函数：筛选植物族且可特殊召唤的怪兽
function c21903613.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的处理流程：翻开卡组顶部卡，选择植物族怪兽特殊召唤
function c21903613.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查玩家是否可以丢弃卡组顶部1张卡
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 获取玩家卡组顶部卡的数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	local ac=1
	if ct>1 then
		if ct>3 then ct=3 end
		local t={}
		for i=1,ct do t[i]=i end
		-- 提示玩家选择翻开卡的数量
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(21903613,2))  --"请选择要翻开的卡的数量"
		-- 玩家宣言翻开卡的数量
		ac=Duel.AnnounceNumber(tp,table.unpack(t))
	end
	-- 确认玩家卡组顶部的卡
	Duel.ConfirmDecktop(tp,ac)
	-- 获取翻开的卡组成的卡片组
	local g=Duel.GetDecktopGroup(tp,ac)
	local og=g:Filter(c21903613.spfilter,nil,e,tp)
	-- 计算玩家场上可特殊召唤的怪兽数量上限
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	-- 判断是否有植物族怪兽可特殊召唤且玩家有空位并询问是否发动
	if og:GetCount()>0 and ft>0 and Duel.SelectYesNo(tp,aux.Stringid(21903613,3)) then  --"是否选植物族怪兽特殊召唤？"
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=og:Select(tp,1,ft,nil)
		-- 遍历选择的特殊召唤卡片组
		for tc in aux.Next(sg) do
			-- 禁止后续操作进行洗切卡组检测
			Duel.DisableShuffleCheck()
			-- 尝试特殊召唤卡片
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				-- 设置特殊召唤的怪兽不能作为连接素材
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				g:RemoveCard(tc)
			end
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
	-- 禁止后续操作进行洗切卡组检测
	Duel.DisableShuffleCheck()
	-- 将翻开的卡送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
end
-- 等级变更过滤函数1：筛选墓地植物族怪兽并检查其是否能影响连接区怪兽
function c21903613.lvfilter1(c,tp,lg)
	return c:IsRace(RACE_PLANT) and c:IsLevelAbove(1)
		-- 检查是否存在连接区怪兽可被该怪兽等级影响
		and Duel.IsExistingMatchingCard(c21903613.lvfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg,c:GetLevel())
end
-- 等级变更过滤函数2：筛选场上正面表示且等级不同的怪兽
function c21903613.lvfilter2(c,g,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and g:IsContains(c) and not c:IsLevel(lv)
end
-- 效果②的目标选择流程：选择墓地植物族怪兽作为对象
function c21903613.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21903613.lvfilter1(chkc,tp,lg) end
	-- 检查是否存在满足条件的墓地植物族怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c21903613.lvfilter1,tp,LOCATION_GRAVE,0,1,nil,tp,lg) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择墓地植物族怪兽作为对象
	Duel.SelectTarget(tp,c21903613.lvfilter1,tp,LOCATION_GRAVE,0,1,1,nil,tp,lg)
end
-- 效果②的处理流程：将连接区怪兽等级变为与对象怪兽相同
function c21903613.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local lg=c:GetLinkedGroup()
	local lv=tc:GetLevel()
	-- 获取所有可被影响的连接区怪兽
	local g=Duel.GetMatchingGroup(c21903613.lvfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil,lg,lv)
	-- 遍历所有可被影响的连接区怪兽
	for lc in aux.Next(g) do
		-- 设置连接区怪兽等级变为对象怪兽等级
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		lc:RegisterEffect(e1)
	end
end
