--バブル・ブリンガー
-- 效果：
-- 只要这张卡在场上存在，4星以上的怪兽不能直接攻击。自己回合可以通过把场上表侧表示存在的这张卡送去墓地，选择自己墓地2只水属性·3星以下的同名怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c58531587.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，4星以上的怪兽不能直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c58531587.atktarget)
	c:RegisterEffect(e2)
	-- 自己回合可以通过把场上表侧表示存在的这张卡送去墓地，选择自己墓地2只水属性·3星以下的同名怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58531587,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c58531587.spcon)
	e3:SetCost(c58531587.spcost)
	e3:SetTarget(c58531587.sptg)
	e3:SetOperation(c58531587.spop)
	c:RegisterEffect(e3)
end
-- 限制直接攻击的怪兽过滤（4星以上）
function c58531587.atktarget(e,c)
	return c:IsLevelAbove(4)
end
-- 特殊召唤效果的发动条件（自己回合且此卡在场上表侧表示存在）
function c58531587.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己回合，且此卡是否已在场上准备就绪
	return Duel.GetTurnPlayer()==tp and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 特殊召唤效果的发动代价（把场上表侧表示的此卡送去墓地）
function c58531587.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤墓地中满足条件的怪兽（3星以下、水属性、可作为效果对象且可特殊召唤）
function c58531587.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤同名怪兽（在给定的卡片组中存在另一张同名卡）
function c58531587.filter2(c,g)
	return g:IsExists(Card.IsCode,1,c,c:GetCode())
end
-- 特殊召唤效果的发动准备（检测怪兽区域空格、过滤并选择墓地2只同名怪兽作为对象）
function c58531587.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return end
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 判断自己场上的怪兽区域空余格子是否不少于2个
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		-- 获取自己墓地中所有满足条件的水属性·3星以下怪兽
		local g=Duel.GetMatchingGroup(c58531587.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
		return g:IsExists(c58531587.filter2,1,nil,g)
	end
	-- 获取自己墓地中所有满足条件的水属性·3星以下怪兽
	local g=Duel.GetMatchingGroup(c58531587.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local dg=g:Filter(c58531587.filter2,nil,g)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg1=dg:Select(tp,1,1,nil)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg2=dg:FilterSelect(tp,Card.IsCode,1,1,sg1:GetFirst(),sg1:GetFirst():GetCode())
	sg1:Merge(sg2)
	-- 将选择的2只同名怪兽设置为效果处理的对象
	Duel.SetTargetCard(sg1)
	-- 设置连锁的操作信息为特殊召唤这2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg1,2,0,0)
end
-- 特殊召唤效果的实际处理（特殊召唤对象怪兽并无效其效果）
function c58531587.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与此效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	local tc=g:GetFirst()
	while tc do
		-- 将目标怪兽以表侧表示特殊召唤（分步处理）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc=g:GetNext()
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
