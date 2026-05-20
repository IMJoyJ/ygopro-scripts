--ヴィンゴルヴの祝福
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只天使族·光属性怪兽送去墓地。
-- ②：自己场上的天使族怪兽的攻击力上升自己的场上·墓地的天使族怪兽数量×100。
-- ③：这张卡被送去墓地的场合，以自己墓地1只4星以下的天使族怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①卡片发动时的效果处理；②场上天使族怪兽攻击力上升的永续效果；③此卡送墓时特召墓地天使族怪兽的诱发效果
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
	-- 设置攻击力上升效果的适用对象为自己场上的天使族怪兽
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
-- 过滤卡组中满足天使族、光属性且能送去墓地的怪兽
function s.filter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGrave()
end
-- ①效果的发动处理：玩家可以选择是否从卡组将1只满足条件的天使族·光属性怪兽送去墓地
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的天使族·光属性怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的怪兽，则询问玩家是否选择将其送去墓地
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡送去墓地？"
		-- 给玩家发送选择要送去墓地的卡的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽因效果送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 计算攻击力上升数值的函数：统计自己场上和墓地的天使族怪兽数量并乘以100
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	-- 返回自己场上（表侧表示）及墓地的天使族怪兽数量乘以100的数值
	return Duel.GetMatchingGroupCount(aux.AND(Card.IsFaceupEx,Card.IsRace),tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,RACE_FAIRY)*100
end
-- 过滤墓地中满足4星以下、天使族且能特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动准备：进行合法性检测，选择墓地1只4星以下的天使族怪兽作为对象，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 效果发动时的合法性检测：检查自己墓地是否存在可特召的目标，且自己场上有空余的怪兽区域
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 玩家选择墓地1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：在墓地特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
-- ③效果的效果处理：将选中的对象怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否存在、是否仍对应当前连锁，并进行王家长眠之谷的过滤判定
	if tc and aux.NecroValleyFilter(tc) and tc:IsRelateToChain() then
		-- 将对象怪兽以表侧表示特殊召唤到发动效果玩家的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
