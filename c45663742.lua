--スネークアイ・オーク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以自己的墓地·除外状态的1只炎属性·1星怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
-- ②：把包含这张卡的自己场上2张表侧表示卡送去墓地才能发动。从手卡·卡组把「蛇眼橡树灵」以外的1只「蛇眼」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册该卡的①②效果：①为召唤·特殊召唤成功时选发的取对象效果，可将墓地/除外的炎属性1星怪兽加入手卡或特殊召唤；②为起动效果，支付将自身和场上1张表侧卡送墓的代价，从手卡/卡组特殊召唤1只其他「蛇眼」怪兽。
function s.initial_effect(c)
	-- ①：这张卡召唤的场合，以自己的墓地·除外状态的1只炎属性·1星怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.rvtg)
	e1:SetOperation(s.rvop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把包含这张卡的自己场上2张表侧表示卡送去墓地才能发动。从手卡·卡组把「蛇眼橡树灵」以外的1只「蛇眼」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.cost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- ①效果的对象筛选函数：对象需为墓地/除外的公开状态卡，等级1、炎属性，并且能够加入手卡或能够被特殊召唤。
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_FIRE) and (c:IsAbleToHand()
		-- 后半条件：若自己怪兽区有空位且该怪兽满足特殊召唤条件，则也可选为对象（以便后续选择特殊召唤）。
		or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ①效果的发动目标处理：检查是否存在合法对象，选择1张自己墓地/除外的炎属性1星怪兽作为对象，并根据对象在墓地还是除外动态调整效果分类，以正确触发相关连锁。
function s.rvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 发动合法性检查：自己墓地或除外区是否存在至少1张满足s.filter的卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家显示「请选择效果的对象」的提示信息，用于选择卡时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己墓地/除外区选择1张符合条件的炎属性1星怪兽，并将其登记为当前连锁的效果对象。
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if tc:IsLocation(LOCATION_GRAVE) then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
		-- 因对象位于墓地时效果处理会令其离开墓地，设置操作信息CATEGORY_LEAVE_GRAVE，以便应对「从墓地离开」的卡（如王家长眠之谷）进行判定。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	end
end
-- ①效果处理：获取对象并确认其仍与效果关联；然后让玩家选择将对象「加入手卡」或「特殊召唤」，并执行相应的动作。
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 调用通用选择界面，让玩家在「加入手卡」与「特殊召唤」两个选项中选择一个。
	local op=aux.SelectFromOptions(tp,
		{tc:IsAbleToHand(),1190},
		-- 第二个选项（特殊召唤）的可用条件：自己怪兽区有空位且对象卡能够被特殊召唤；满足时显示对应的选项文本。
		{Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false),1152})
	-- 若玩家选择加入手卡，则将该对象卡以效果原因加入持有者手卡。
	if op==1 then Duel.SendtoHand(tc,nil,REASON_EFFECT)
	-- 若玩家选择特殊召唤，则将对象卡表侧攻击表示特殊召唤到己方场上。
	elseif op==2 then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
-- ②效果代价的辅助过滤函数：用于选择除本卡以外的另一张表侧表示卡作为代价，且需保证该卡和本卡同时送墓后自己仍有怪兽区空格用于后续特殊召唤。
function s.cfilter(c,tc,tp)
	-- 过滤条件：该卡为表侧表示、可作为代价送去墓地，并且把该卡与本卡一起送去墓地后己方怪兽区仍有空位。
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,Group.FromCards(c,tc))>0
end
-- ②效果的代价支付：检查能否将本卡和另一张表侧表示卡送墓，并从场上选择一张表侧表示卡与本卡一起送去墓地。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检查：本卡自身能否作为代价送墓，且场上存在另一张满足s.cfilter的表侧表示卡。
	if chk==0 then return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,c,c,tp) end
	-- 显示「请选择要送去墓地的卡」的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张满足条件的表侧表示卡，与效果持有者（本卡）一起组成要送去墓地的代价组。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,c,c,tp)+c
	-- 将选择的卡和本卡送去墓地，作为效果的发动代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果特殊召唤对象的筛选函数：卡名属于「蛇眼」字段、不是「蛇眼橡树灵」自身、且能被特殊召唤。
function s.sfilter(c,e,tp)
	return c:IsSetCard(0x19c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- ②效果的发动目标检查：确认满足发动条件（已支付代价或当前有怪兽区空位）且手卡/卡组存在符合条件的「蛇眼」怪兽，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：代价已检查过（因为代价会送墓腾出怪兽区）或当前自己怪兽区已有空位。
	if chk==0 then return (e:IsCostChecked() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		-- 同时还需要手卡或卡组中存在至少1张满足s.sfilter的「蛇眼」怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果从手卡/卡组特殊召唤1只怪兽，用于连锁判定和效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ②效果处理：若处理时自己怪兽区仍有空位，则从手卡/卡组选择1只符合条件的「蛇眼」怪兽，表侧攻击表示特殊召唤到己方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若没有空余怪兽区，则终止处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示「请选择要特殊召唤的卡」的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡/卡组选择1张满足s.sfilter的「蛇眼」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的怪兽表侧攻击表示特殊召唤到己方场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
