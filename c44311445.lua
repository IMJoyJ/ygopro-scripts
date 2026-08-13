--マドルチェ・プディンセス・ショコ・ア・ラ・モード
-- 效果：
-- 地属性5星怪兽×2
-- 这张卡也能在自己场上的4阶以下的「魔偶甜点」超量怪兽上面重叠来超量召唤。
-- ①：1回合1次，以自己墓地1张「魔偶甜点」卡为对象才能发动。那张卡回到卡组。
-- ②：这张卡有「魔偶甜点·布丁公主」在作为超量素材的状态，自己墓地的「魔偶甜点」卡回到卡组时，把这张卡1个超量素材取除才能发动。从卡组把1只「魔偶甜点」怪兽表侧攻击表示或里侧守备表示特殊召唤。
function c44311445.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),5,2,c44311445.ovfilter,aux.Stringid(44311445,0))  --"是否在「魔偶甜点」超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：1回合1次，以自己墓地1张「魔偶甜点」卡为对象才能发动。那张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44311445,1))  --"回到卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c44311445.tdtg)
	e1:SetOperation(c44311445.tdop)
	c:RegisterEffect(e1)
	-- ②：这张卡有「魔偶甜点·布丁公主」在作为超量素材的状态，自己墓地的「魔偶甜点」卡回到卡组时，把这张卡1个超量素材取除才能发动。从卡组把1只「魔偶甜点」怪兽表侧攻击表示或里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44311445,2))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c44311445.spcon)
	e2:SetCost(c44311445.spcost)
	e2:SetTarget(c44311445.sptg)
	e2:SetOperation(c44311445.spop)
	c:RegisterEffect(e2)
end
-- 定义叠放素材的额外条件：表侧表示、阶级4以下且属于「魔偶甜点」超量怪兽，用于实现这张卡也能在自己场上的4阶以下的「魔偶甜点」超量怪兽上面重叠来超量召唤。
function c44311445.ovfilter(c)
	return c:IsFaceup() and c:IsRankBelow(4) and c:IsSetCard(0x71)
end
-- 定义效果①的对象过滤条件：自己墓地中属于「魔偶甜点」且能够返回卡组的卡。
function c44311445.tdfilter(c)
	return c:IsSetCard(0x71) and c:IsAbleToDeck()
end
-- 效果①发动时的目标处理：确认可以选择自己墓地1张「魔偶甜点」卡为对象，选择对象后将该卡设定为连锁对象，并登记本次操作信息为返回卡组。
function c44311445.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c44311445.tdfilter(chkc) end
	-- 发动合法性检查：自己墓地是否存在至少1张满足「魔偶甜点」且能返回卡组的卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c44311445.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要返回卡组的卡”的提示，用于选择卡片的界面交互。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1张符合条件的「魔偶甜点」卡作为效果①的对象，并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c44311445.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：本次效果将把1张卡返回卡组，指定对象为已选中的那张卡，供连锁中的其他卡进行检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果①的解决处理：取得对象卡，若对象仍与该效果关联，则将其洗回持有者卡组。
function c44311445.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果①发动时所选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡返回其持有者卡组并洗牌，返回原因是效果。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 定义②触发事件的过滤条件：该卡是「魔偶甜点」卡、当前在卡组、先前控制者是效果发动者、先前位置是墓地，用于判断自己墓地的「魔偶甜点」卡回到卡组。
function c44311445.cfilter(c,tp)
	return c:IsSetCard(0x71) and c:IsLocation(LOCATION_DECK)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_GRAVE)
end
-- ②效果的诱发条件：这张卡的超量素材中存在「魔偶甜点·布丁公主」，并且本次事件中有满足条件的自己墓地的「魔偶甜点」卡回到了卡组。
function c44311445.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,74641045) and eg:IsExists(c44311445.cfilter,1,nil,tp)
end
-- ②效果的发动代价：从这张卡上取除1个超量素材；检查时确认是否可以取除，实际处理时执行取除。
function c44311445.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义从卡组特殊召唤的过滤条件：属于「魔偶甜点」且能够以表侧攻击表示或里侧守备表示被特殊召唤。
function c44311445.spfilter(c,e,tp)
	return c:IsSetCard(0x71) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- ②效果的发动条件与目标设定：确认我方主要怪兽区有空位，且卡组中存在至少1只符合条件的「魔偶甜点」怪兽，并将操作信息登记为从卡组特殊召唤1只。
function c44311445.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：我方主要怪兽区是否有空位，用于后续特殊召唤或盖放怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查：卡组中是否存在至少1只能以表侧攻击表示或里侧守备表示特殊召唤的「魔偶甜点」怪兽。
		and Duel.IsExistingMatchingCard(c44311445.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果将从卡组特殊召唤1只「魔偶甜点」怪兽，处理时才确定具体卡片，因此targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的解决处理：若我方主要怪兽区仍有空位，则从卡组选择1只符合条件的「魔偶甜点」怪兽，以表侧攻击表示或里侧守备表示特殊召唤；若为里侧守备表示特殊召唤成功，则让对方确认该卡。
function c44311445.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认我方主要怪兽区是否有空位，若无空位则本效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示，用于选择卡片的界面交互。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的「魔偶甜点」怪兽，用于本次特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c44311445.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧攻击表示或里侧守备表示特殊召唤；若特殊召唤成功且该怪兽处于里侧表示，则执行后续的确认操作。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)~=0 and tc:IsFacedown() then
			-- 让对方玩家确认里侧守备表示特殊召唤出来的「魔偶甜点」怪兽。
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
