--クリストロン・インクルージョン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把「水晶机巧包体」以外的1张「水晶机巧」卡加入手卡。
-- ②：自己的「水晶机巧」怪兽在1回合各有1次不会被战斗破坏。
-- ③：把墓地的这张卡除外，以自己墓地1只「水晶机巧」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册三个效果：①发动效果、②永续效果（怪兽不会被战斗破坏）、③起动效果（特殊召唤墓地怪兽）
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把「水晶机巧包体」以外的1张「水晶机巧」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己的「水晶机巧」怪兽在1回合各有1次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(s.indct)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外，以自己墓地1只「水晶机巧」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	-- 效果发动时需要将此卡除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「水晶机巧」卡（非同名卡）
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0xea) and c:IsAbleToHand()
end
-- 发动效果：从卡组检索一张「水晶机巧」卡加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足检索条件的卡组卡片
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否有满足条件的卡且玩家选择发动效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 判断目标是否为「水晶机巧」卡
function s.indtg(e,c)
	return c:IsSetCard(0xea)
end
-- 当怪兽因战斗被破坏时，该怪兽不会被破坏
function s.indct(e,re,r,rp)
	if r&REASON_BATTLE~=0 then
		return 1
	else return 0 end
end
-- 过滤满足条件的「水晶机巧」怪兽（可特殊召唤）
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xea) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 判断是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否有满足条件的墓地怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息（特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽有效且未被王家长眠之谷影响，则特殊召唤
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
