--BF－無頼のヴァータ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「黑羽-无赖之伐他」以外的「黑羽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己主要阶段才能发动。等级合计直到8的这张卡和除调整以外的卡组的「黑羽」怪兽1只以上送去墓地，把1只「黑翼龙」从额外卡组特殊召唤。这个回合，自己不是暗属性怪兽不能从额外卡组特殊召唤。
function c71187462.initial_effect(c)
	-- 记录这张卡的效果中记载了「黑翼龙」的卡名
	aux.AddCodeList(c,9012916)
	-- ①：自己场上有「黑羽-无赖之伐他」以外的「黑羽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71187462,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,71187462+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c71187462.spcon)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。等级合计直到8的这张卡和除调整以外的卡组的「黑羽」怪兽1只以上送去墓地，把1只「黑翼龙」从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71187462,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,71187463)
	e2:SetTarget(c71187462.tgtg)
	e2:SetOperation(c71187462.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「黑羽-无赖之伐他」以外的「黑羽」怪兽
function c71187462.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33) and not c:IsCode(71187462)
end
-- 特殊召唤规则的条件：怪兽区域有空位，且自己场上存在满足过滤条件的怪兽
function c71187462.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c71187462.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡组中可以送去墓地的非调整「黑羽」怪兽
function c71187462.tgfilter(c)
	return c:IsSetCard(0x33) and c:IsAbleToGrave() and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TUNER)
end
-- 过滤条件：额外卡组中可以特殊召唤的「黑翼龙」
function c71187462.sfilter(c,e,tp,mc)
	return c:IsCode(9012916)
		-- 检查该卡是否可以特殊召唤，以及在将这张卡送去墓地后是否有可用的额外怪兽区域空格
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果②的发动准备与可行性检查：检查自身等级是否大于0，卡组中是否存在等级合计等于所需等级的非调整「黑羽」怪兽，以及额外卡组是否存在可特殊召唤的「黑翼龙」
function c71187462.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local clv=c:GetLevel()
	local lv=8-clv
	-- 获取卡组中所有满足过滤条件的非调整「黑羽」怪兽
	local g=Duel.GetMatchingGroup(c71187462.tgfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return clv>0 and lv>0 and g:CheckWithSumEqual(Card.GetLevel,lv,1,99)
		-- 检查额外卡组中是否存在至少1只满足过滤条件的「黑翼龙」
		and Duel.IsExistingMatchingCard(c71187462.sfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置操作信息：从卡组将卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：从额外卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理：将自身和卡组中等级合计为所需等级的非调整「黑羽」怪兽送去墓地，从额外卡组特殊召唤「黑翼龙」，并适用只能特殊召唤暗属性怪兽的限制
function c71187462.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local clv=c:GetLevel()
	local lv=8-clv
	if c:IsRelateToEffect(e) and lv>0 then
		-- 获取卡组中所有满足过滤条件的非调整「黑羽」怪兽
		local g=Duel.GetMatchingGroup(c71187462.tgfilter,tp,LOCATION_DECK,0,nil)
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local tg=g:SelectWithSumEqual(tp,Card.GetLevel,lv,1,99)
		if #tg>0 then
			tg:AddCard(c)
			-- 将选中的卡（包含自身）因效果送去墓地，并检查是否成功将2张以上的卡送去墓地且其中有卡确实到达了墓地
			if Duel.SendtoGrave(tg,REASON_EFFECT)>1 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
				-- 提示玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 让玩家从额外卡组选择1只满足过滤条件的「黑翼龙」
				local sg=Duel.SelectMatchingCard(tp,c71187462.sfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
				if sg:GetCount()>0 then
					-- 将选中的「黑翼龙」以表侧表示特殊召唤
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
	-- 这个回合，自己不是暗属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c71187462.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内限制特殊召唤的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能从额外卡组特殊召唤非暗属性的怪兽
function c71187462.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK) and c:IsLocation(LOCATION_EXTRA)
end
