--守護神－ネフティス
-- 效果：
-- 「奈芙提斯」怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡是已连接召唤的场合，可以从以下效果选择1个发动。
-- ●从卡组把1只鸟兽族·8星怪兽加入手卡。那之后，可以从自己墓地选1张仪式魔法卡加入手卡。
-- ●选这张卡所连接区1只「奈芙提斯」怪兽破坏，从自己墓地选原本卡名和那只怪兽不同的1只「奈芙提斯」怪兽效果无效特殊召唤。
function c50669347.initial_effect(c)
	c:EnableReviveLimit()
	-- 为此卡添加连接召唤手续：以2只「奈芙提斯」怪兽（卡名含0x11f字段）作为连接素材，连接召唤上场。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x11f),2,2)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡是已连接召唤的场合，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50669347,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,50669347)
	e1:SetCondition(c50669347.condition)
	e1:SetTarget(c50669347.target)
	c:RegisterEffect(e1)
end
-- 发动条件：此卡在主要怪兽区且以连接召唤方式成功召唤的场合才能发动。
function c50669347.condition(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤：卡组中1只8星鸟兽族怪兽，且能够加入手卡。
function c50669347.thfilter1(c)
	return c:IsLevel(8) and c:IsRace(RACE_WINDBEAST) and c:IsAbleToHand()
end
-- 检索/回收过滤：自己墓地中1张仪式魔法卡，且能够加入手卡。
function c50669347.thfilter2(c)
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
-- 破坏侧选择对象的过滤：选择自己场上表侧表示且位于此卡连接区的「奈芙提斯」怪兽，破坏后自己场上仍有空位，且墓地存在可特殊召唤的符合条件的「奈芙提斯」怪兽。
function c50669347.desfilter(c,e,tp,g)
	-- 选择对象必须是表侧表示的「奈芙提斯」怪兽、处于此卡连接区，并且破坏后自己场上要有可用怪兽区。
	return c:IsFaceup() and c:IsSetCard(0x11f) and g:IsContains(c) and Duel.GetMZoneCount(tp,c)>0
		-- 此外，墓地中必须存在1只满足spfilter条件的「奈芙提斯」怪兽，供破坏后特殊召唤。
		and Duel.IsExistingMatchingCard(c50669347.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
-- 墓地特召过滤：属于「奈芙提斯」怪兽、原本卡名与被破坏怪兽不同、且满足特殊召唤条件（可被效果特殊召唤并符合苏生限制）的怪兽。
function c50669347.spfilter(c,e,tp,dc)
	return c:IsSetCard(0x11f) and c:IsType(TYPE_MONSTER) and not c:IsOriginalCodeRule(dc:GetOriginalCodeRule())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标判定与分支选择：检查检索分支和破坏/特召分支是否满足；若两个分支都满足则弹出选项让玩家选择，否则自动选择可用分支，再根据所选分支设置对应的效果分类与处理函数。
function c50669347.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足检索条件（8星鸟兽族且可加入手卡）的怪兽。
	local b1=Duel.IsExistingMatchingCard(c50669347.thfilter1,tp,LOCATION_DECK,0,1,nil)
	-- 检查自己场上是否存在位于此卡连接区的「奈芙提斯」怪兽，且其被破坏后墓地仍有可特殊召唤的「奈芙提斯」怪兽。
	local b2=Duel.IsExistingMatchingCard(c50669347.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp,e:GetHandler():GetLinkedGroup())
	if chk==0 then return b1 or b2 end
	local op=-1
	if b1 and b2 then
		-- 两个分支都可用时，让玩家选择“检索并回收”或“破坏并特殊召唤”，返回选项序号（0或1）。
		op=Duel.SelectOption(tp,aux.Stringid(50669347,1),aux.Stringid(50669347,2))  --"检索并回收/破坏并特殊召唤"
	elseif b1 then
		-- 只有检索分支可用时，让玩家选择“检索并回收”，返回0。
		op=Duel.SelectOption(tp,aux.Stringid(50669347,1))  --"检索并回收"
	else
		-- 只有破坏/特召分支可用时，选择“破坏并特殊召唤”，并将返回的0+1转换为1以对应第二分支。
		op=Duel.SelectOption(tp,aux.Stringid(50669347,2))+1  --"破坏并特殊召唤"
	end
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetOperation(c50669347.thop)
		-- 设置操作信息：本次效果包含从卡组将1张卡加入手卡的处理。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==1 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(c50669347.desop)
		-- 设置操作信息：本次效果包含破坏场上1张卡的处理。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
		-- 设置操作信息：本次效果包含从墓地特殊召唤1只怪兽的处理。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
-- 检索并回收效果的处理：从卡组选1只鸟兽族·8星怪兽加入手卡并给对方确认；之后可选择将墓地1张仪式魔法卡加入手卡。
function c50669347.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足thfilter1条件的鸟兽族·8星怪兽。
	local g=Duel.SelectMatchingCard(tp,c50669347.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	-- 如果成功选择了卡且加入手卡成功，则进入后续处理。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 向对方玩家确认检索到的卡。
		Duel.ConfirmCards(1-tp,g)
		-- 获取自己墓地中满足thfilter2条件的仪式魔法卡（并排除受王家长眠之谷影响的卡）。
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c50669347.thfilter2),tp,LOCATION_GRAVE,0,nil)
		-- 若墓地存在可加入手卡的仪式魔法，且玩家确认选择“是”，则执行回收。
		if g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(50669347,3)) then  --"是否从墓地把仪式魔法卡加入手卡？"
			-- 提示玩家选择要加入手卡的仪式魔法卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg2=g2:Select(tp,1,1,nil)
			-- 将选中的仪式魔法卡加入手卡。
			Duel.SendtoHand(sg2,nil,REASON_EFFECT)
		end
	end
end
-- 破坏并特召效果的处理：选择并破坏此卡连接区的「奈芙提斯」怪兽，然后从墓地特殊召唤1只原本卡名与之不同的「奈芙提斯」怪兽，并使其效果无效化。
function c50669347.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=e:GetHandler():GetLinkedGroup()
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上选择1只满足desfilter条件的「奈芙提斯」怪兽（表侧且在连接区，破坏后有空位且墓地有可特召对象）。
	local dc=Duel.SelectMatchingCard(tp,c50669347.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,lg):GetFirst()
	-- 如果确定选择且破坏成功，则继续执行特殊召唤处理。
	if dc and Duel.Destroy(dc,REASON_EFFECT)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从墓地选择1只满足spfilter条件的「奈芙提斯」怪兽（原本卡名与已破坏怪兽不同、可特召，且不受王家长眠之谷影响）。
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c50669347.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,dc):GetFirst()
		-- 若所选怪兽可以特殊召唤（满足召唤条件与苏生限制），则将其以表侧表示特殊召唤到己方场上。
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 效果无效特殊召唤中的“效果无效”：使特殊召唤的怪兽效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- 效果无效特殊召唤中的“效果无效”：使该特殊召唤的怪兽所发动的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
		-- 完成整个特殊召唤流程，将经过SpecialSummonStep处理的怪兽实际特殊召唤出场。
		Duel.SpecialSummonComplete()
	end
end
