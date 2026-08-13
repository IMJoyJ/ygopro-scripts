--クリストロン・エントリー
-- 效果：
-- 「水晶机巧入舱」的②的效果1回合只能使用1次。
-- ①：从自己的手卡·墓地各选1只「水晶机巧」调整特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只「水晶机巧」怪兽为对象才能发动。把持有和那只怪兽的等级不同等级的1只「水晶机巧」怪兽从卡组送去墓地。作为对象的怪兽的等级变成和送去墓地的怪兽的等级相同。这个效果在这张卡送去墓地的回合不能发动。
function c52176579.initial_effect(c)
	-- ①：从自己的手卡·墓地各选1只「水晶机巧」调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52176579.target)
	e1:SetOperation(c52176579.activate)
	c:RegisterEffect(e1)
	-- 「水晶机巧入舱」的②的效果1回合只能使用1次。②：把墓地的这张卡除外，以自己场上1只「水晶机巧」怪兽为对象才能发动。把持有和那只怪兽的等级不同等级的1只「水晶机巧」怪兽从卡组送去墓地。作为对象的怪兽的等级变成和送去墓地的怪兽的等级相同。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52176579,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,52176579)
	-- 将②效果的发动条件设为“此卡送去墓地的回合不能发动”（通过aux.exccon实现）。
	e2:SetCondition(aux.exccon)
	-- 将②效果的发动COST设为“把墓地的这张卡除外”（通过aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c52176579.lvtg)
	e2:SetOperation(c52176579.lvop)
	c:RegisterEffect(e2)
end
-- 定义①效果特殊召唤的候选卡筛选条件：持有「水晶机巧」字段、是调整怪兽、且可以被当前效果特殊召唤。
function c52176579.filter(c,e,tp)
	return c:IsSetCard(0xea) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查①效果的发动条件：我方未被青眼精灵龙的“不能同时特殊召唤2只以上怪兽”效果限制、主怪兽区至少有2个空格、手卡和墓地各存在至少1只符合条件的「水晶机巧」调整怪兽。
function c52176579.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认我方主要怪兽区域至少有2个可用空格，以用于同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 确认手卡中存在至少1只符合条件的「水晶机巧」调整怪兽。
		and Duel.IsExistingMatchingCard(c52176579.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 确认墓地中存在至少1只符合条件的「水晶机巧」调整怪兽。
		and Duel.IsExistingMatchingCard(c52176579.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理信息，声明此次效果将进行2只怪兽的特殊召唤，来源为手卡和墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 处理①效果：再次确认未被青眼精灵龙限制且主怪兽区有至少2个空格，从手卡和墓地各选择1只符合条件的「水晶机巧」调整怪兽，合并后以表侧表示同时特殊召唤到我方场上。
function c52176579.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 处理时若主怪兽区可用空格不足2个，则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 取得手卡中所有符合条件的「水晶机巧」调整怪兽作为候选组。
	local g1=Duel.GetMatchingGroup(c52176579.filter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 取得墓地中所有符合条件的「水晶机巧」调整怪兽作为候选组，并排除受到“王家长眠之谷”效果影响的卡（使用aux.NecroValleyFilter过滤）。
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c52176579.filter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示，用于从手卡中选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg1=g1:Select(tp,1,1,nil)
	-- 显示“请选择要特殊召唤的卡”的选择提示，用于从墓地中选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg2=g2:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	-- 将选出的2只「水晶机巧」调整怪兽以表侧表示同时特殊召唤到我方场上（不检查召唤条件与苏生限制）。
	Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义②效果可选择为对象的怪兽条件：自己场上的表侧表示「水晶机巧」怪兽，且其等级大于0，并且卡组中存在1只等级与该怪兽不同的「水晶机巧」怪兽可送去墓地。
function c52176579.lvfilter(c,tp)
	local lv=c:GetLevel()
	-- 判定对象怪兽需满足等级>0、表侧表示、属于「水晶机巧」字段，且卡组中存在可送去墓地的等级不同的「水晶机巧」怪兽。
	return lv>0 and c:IsFaceup() and c:IsSetCard(0xea) and Duel.IsExistingMatchingCard(c52176579.tgfilter,tp,LOCATION_DECK,0,1,nil,lv)
end
-- 定义②效果从卡组送去墓地的「水晶机巧」怪兽的筛选条件：与对象怪兽等级不同、等级为1以上、是怪兽卡且能够送去墓地。
function c52176579.tgfilter(c,lv)
	return c:IsSetCard(0xea) and not c:IsLevel(lv) and c:IsLevelAbove(1) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ②效果的发动时处理：检查是否存在满足条件的我方场上表侧表示「水晶机巧」怪兽作为对象；选择对象后，将操作信息设置为从卡组把1只怪兽送去墓地。
function c52176579.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c52176579.lvfilter(chkc,tp) end
	-- 发动时确认场上存在至少1只满足lvfilter条件的我方「水晶机巧」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c52176579.lvfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 显示“请选择表侧表示的卡”的选择提示，用于选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从我方场上选择1只满足条件的表侧表示「水晶机巧」怪兽作为效果对象，并建立对象关联。
	Duel.SelectTarget(tp,c52176579.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置连锁处理信息，声明将把1只卡组中的「水晶机巧」怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理②效果：从卡组选择1只与对象怪兽等级不同的「水晶机巧」怪兽送去墓地；若成功送去墓地且对象仍在我方场上且表侧表示，则将对象等级变为与送去墓地的怪兽相同。
function c52176579.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 显示“请选择要送去墓地的卡”的选择提示，用于从卡组选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只与对象怪兽等级不同且满足tgfilter条件的「水晶机巧」怪兽。
	local g=Duel.SelectMatchingCard(tp,c52176579.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel())
	if g:GetCount()>0 then
		local gc=g:GetFirst()
		-- 若该卡确实因效果被送入墓地，且对象怪兽仍与效果关联并表侧表示在场上，则执行等级变更。
		if Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 作为对象的怪兽的等级变成和送去墓地的怪兽的等级相同。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(gc:GetLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
