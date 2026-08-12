--エクシーズ・エントラスト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的卡组·墓地把1张「铠装超量」卡加入手卡。那之后，可以选自己场上最多2只表侧表示怪兽那些等级直到回合结束时全部变成3星或者全部变成5星。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的魔法与陷阱区域1张当作装备卡使用的超量怪兽卡为对象才能发动。那张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①效果（魔法卡发动）和②效果（墓地起动效果）。
function s.initial_effect(c)
	-- ①：从自己的卡组·墓地把1张「铠装超量」卡加入手卡。那之后，可以选自己场上最多2只表侧表示怪兽那些等级直到回合结束时全部变成3星或者全部变成5星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"「铠装超量」卡加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的魔法与陷阱区域1张当作装备卡使用的超量怪兽卡为对象才能发动。那张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤当作装备卡使用的超量怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置发动条件：这张卡送去墓地的回合不能发动。
	e2:SetCondition(aux.exccon)
	-- 设置发动代价：将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡名含有「铠装超量」且可以加入手卡的卡。
function s.filter(c)
	return c:IsSetCard(0x4073) and c:IsAbleToHand()
end
-- 过滤条件：场上表侧表示、有等级且等级不等于目标等级的怪兽。
function s.lvfilter(c,lv)
	return c:IsFaceup() and c:GetLevel()>0 and c:GetLevel()~=lv
end
-- ①效果的发动准备：检查卡组或墓地是否存在可检索的「铠装超量」卡，并设置收集卡片到手卡的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或墓地是否存在至少1张满足过滤条件的「铠装超量」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从卡组或墓地将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的处理：将「铠装超量」卡加入手卡，之后可选择改变场上最多2只怪兽的等级为3星或5星。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张「铠装超量」卡（受王家之谷影响）。
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if tg:GetCount()>0 then
		-- 将选中的卡加入手卡。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,tg)
		-- 获取自己场上所有表侧表示且有等级的怪兽。
		local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil,0)
		if g:GetCount()>0 then
			-- 让玩家选择将等级变成3星、5星或不改变等级。
			local lv=aux.SelectFromOptions(tp,
				{g:IsExists(s.lvfilter,1,nil,3),aux.Stringid(id,2),3},  --"选怪兽等级变成3星"
				{g:IsExists(s.lvfilter,1,nil,5),aux.Stringid(id,3),5},  --"选怪兽等级变成5星"
				{true,aux.Stringid(id,4),0})  --"不改变等级"
			if lv==0 then return end
			-- 中断当前效果处理，使后续的等级改变处理不与加入手卡视为同时进行。
			Duel.BreakEffect()
			-- 提示玩家选择要改变等级的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,5))  --"请选择要改变等级的怪兽"
			local sg=g:FilterSelect(tp,s.lvfilter,1,2,nil,lv)
			local tc=sg:GetFirst()
			while tc do
				-- 那些等级直到回合结束时全部变成3星或者全部变成5星。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				tc=sg:GetNext()
			end
		end
	end
end
-- 过滤条件：魔法与陷阱区域表侧表示、原本卡片类型为超量怪兽的装备卡，且可以特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:GetOriginalType()&TYPE_XYZ~=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备：检查并选择魔法与陷阱区域当作装备卡使用的超量怪兽作为对象，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己魔法与陷阱区域是否存在至少1张满足条件的当作装备卡使用的超量怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp)
		-- 并且自己场上有可用于特殊召唤的怪兽区域空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择魔法与陷阱区域1张当作装备卡使用的超量怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：将选中的卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理：将作为对象的当作装备卡使用的超量怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
