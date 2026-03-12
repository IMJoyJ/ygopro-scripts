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
	-- ②：把墓地的这张卡除外，以自己场上1只「水晶机巧」怪兽为对象才能发动。把持有和那只怪兽的等级不同等级的1只「水晶机巧」怪兽从卡组送去墓地。作为对象的怪兽的等级变成和送去墓地的怪兽的等级相同。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52176579,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,52176579)
	-- 设置效果条件为：这张卡送去墓地的回合不能发动此效果
	e2:SetCondition(aux.exccon)
	-- 设置效果费用为：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c52176579.lvtg)
	e2:SetOperation(c52176579.lvop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检测满足条件的「水晶机巧」调整怪兽
function c52176579.filter(c,e,tp)
	return c:IsSetCard(0xea) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否可以发动效果①：检查是否满足特殊召唤条件
function c52176579.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有足够的怪兽区域进行特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家手牌中是否存在符合条件的「水晶机巧」调整
		and Duel.IsExistingMatchingCard(c52176579.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 检查玩家墓地中是否存在符合条件的「水晶机巧」调整
		and Duel.IsExistingMatchingCard(c52176579.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的发动处理函数，执行特殊召唤操作
function c52176579.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查玩家场上是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取玩家手牌中符合条件的「水晶机巧」调整组
	local g1=Duel.GetMatchingGroup(c52176579.filter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 获取玩家墓地中符合条件的「水晶机巧」调整组（排除王家长眠之谷影响）
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c52176579.filter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg1=g1:Select(tp,1,1,nil)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg2=g2:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	-- 将选中的2只怪兽特殊召唤到场上
	Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于检测满足条件的「水晶机巧」怪兽（等级大于0且表侧表示）
function c52176579.lvfilter(c,tp)
	local lv=c:GetLevel()
	-- 检查目标怪兽是否为表侧表示、是否为「水晶机巧」族且卡组中存在不同等级的「水晶机巧」怪兽
	return lv>0 and c:IsFaceup() and c:IsSetCard(0xea) and Duel.IsExistingMatchingCard(c52176579.tgfilter,tp,LOCATION_DECK,0,1,nil,lv)
end
-- 过滤函数，用于检测满足条件的「水晶机巧」怪兽（等级与目标不同且等级大于等于1）
function c52176579.tgfilter(c,lv)
	return c:IsSetCard(0xea) and not c:IsLevel(lv) and c:IsLevelAbove(1) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果②的发动处理函数，设置取对象和选择卡组中符合条件的怪兽
function c52176579.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c52176579.lvfilter(chkc,tp) end
	-- 判断是否可以发动效果②：检查是否存在符合条件的场上「水晶机巧」怪兽
	if chk==0 then return Duel.IsExistingTarget(c52176579.lvfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要作为对象的表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上符合条件的「水晶机巧」怪兽作为对象
	Duel.SelectTarget(tp,c52176579.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置连锁操作信息：准备将卡组中的怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的发动处理函数，执行将卡组中怪兽送去墓地并改变对象怪兽等级的操作
function c52176579.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张等级与目标怪兽不同的「水晶机巧」怪兽
	local g=Duel.SelectMatchingCard(tp,c52176579.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel())
	if g:GetCount()>0 then
		local gc=g:GetFirst()
		-- 判断是否成功将卡送去墓地且对象怪兽仍然有效
		if Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 为对象怪兽设置等级变更效果，使其等级变为被送去墓地的怪兽的等级
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(gc:GetLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
