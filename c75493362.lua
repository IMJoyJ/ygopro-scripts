--ヴィンゴルヴの祝福
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只天使族·光属性怪兽送去墓地。
-- ②：自己场上的天使族怪兽的攻击力上升自己的场上·墓地的天使族怪兽数量×100。
-- ③：这张卡被送去墓地的场合，以自己墓地1只4星以下的天使族怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册这张卡的3个效果：e1为卡的发动（送去墓地/卡组送墓类效果，自由时点，带卡名1回合1张的誓约次数限制），e2为在魔陷区存在的永续加攻效果，e3为这张卡被送去墓地时诱发选发的特殊召唤效果（③效果1回合1次）
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只天使族·光属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的天使族怪兽的攻击力上升自己的场上·墓地的天使族怪兽数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设定加攻效果只作用于自己场上的天使族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡被送去墓地的场合，以自己墓地1只4星以下的天使族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数：选出天使族·光属性且可以被送去墓地的卡，用于①效果从卡组选卡送墓
function s.filter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGrave()
end
-- ①效果处理：从自己卡组检索满足条件的天使族·光属性怪兽，询问玩家是否送去墓地，选「是」则把选中的1只怪兽送去墓地
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己卡组检索所有满足条件（天使族·光属性且可送去墓地）的怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 若卡组存在可送去墓地的怪兽，则询问玩家是否把卡送去墓地，选「是」则继续处理
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡送去墓地？"
		-- 向玩家发送选卡提示「请选择要送去墓地的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 把选中的1只怪兽作为效果处理送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- ②效果的加攻数值计算函数：统计自己场上（表侧表示）和墓地的天使族怪兽数量，返回其数量×100作为攻击力上升值
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	-- 返回自己场上·墓地的天使族怪兽数量×100，作为天使族怪兽的攻击力上升数值
	return Duel.GetMatchingGroupCount(aux.AND(Card.IsFaceupEx,Card.IsRace),tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,RACE_FAIRY)*100
end
-- 过滤函数：选出4星以下的天使族怪兽，且可以被这个效果特殊召唤的卡
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的对象选择：先校验对象须在墓地且为自己控制并满足条件，再检查发动条件（墓地存在可作为对象的4星以下天使族怪兽且自己主要怪兽区有空位），然后选择1只对象并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 发动条件检查：自己墓地存在可以成为对象的4星以下天使族怪兽，且自己主要怪兽区有可用的空格
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 以自己墓地1只满足条件的4星以下天使族怪兽为对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：声明本次连锁将要把1只墓地的对象怪兽特殊召唤，供星尘龙、王家长眠之谷等效果的发动检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
-- ③效果处理：取得对象怪兽，确认其仍与当前连锁关联且不受王家长眠之谷的影响，然后将其以表侧表示特殊召唤到自己场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁的对象卡（发动时选择的墓地的那只天使族怪兽）
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡存在、仍与当前连锁保持关联，且不受王家长眠之谷的影响
	if tc and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 把那只怪兽以表侧表示特殊召唤到自己场上（不无视召唤条件和苏生限制）
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
