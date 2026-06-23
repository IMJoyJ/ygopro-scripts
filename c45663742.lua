--スネークアイ・オーク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以自己的墓地·除外状态的1只炎属性·1星怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
-- ②：把包含这张卡的自己场上2张表侧表示卡送去墓地才能发动。从手卡·卡组把「蛇眼橡树灵」以外的1只「蛇眼」怪兽特殊召唤。
local s,id,o=GetID()
-- 创建并注册蛇眼橡树灵的三个效果，包括召唤时的效果、特殊召唤时的效果和场上的起动效果
function s.initial_effect(c)
	-- 效果①：这张卡召唤·特殊召唤的场合，以自己的墓地·除外状态的1只炎属性·1星怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
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
	-- 效果②：把包含这张卡的自己场上2张表侧表示卡送去墓地才能发动。从手卡·卡组把「蛇眼橡树灵」以外的1只「蛇眼」怪兽特殊召唤。
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
-- 定义过滤函数，用于判断目标怪兽是否满足效果①的条件（1星炎属性，可回手或可特殊召唤）
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_FIRE) and (c:IsAbleToHand()
		-- 判断目标怪兽是否可特殊召唤（满足召唤条件且场上存在召唤区域）
		or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 设置效果①的目标选择函数，检查场上是否存在符合条件的目标怪兽
function s.rvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查是否满足效果①的发动条件（存在符合条件的目标怪兽）
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的目标怪兽
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if tc:IsLocation(LOCATION_GRAVE) then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
		-- 设置操作信息，标记目标怪兽将离开墓地
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	end
end
-- 定义效果①的处理函数，根据玩家选择将目标怪兽回手或特殊召唤
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 调用选项选择函数，让玩家选择将目标怪兽回手或特殊召唤
	local op=aux.SelectFromOptions(tp,
		{tc:IsAbleToHand(),1190},
		-- 判断目标怪兽是否可特殊召唤的条件
		{Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false),1152})
	-- 若选择回手，则将目标怪兽送入手牌
	if op==1 then Duel.SendtoHand(tc,nil,REASON_EFFECT)
	-- 若选择特殊召唤，则将目标怪兽特殊召唤
	elseif op==2 then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
-- 定义过滤函数，用于判断场上卡是否可作为效果②的代价（表侧表示、可送墓、召唤区域足够）
function s.cfilter(c,tc,tp)
	-- 判断场上卡是否满足效果②的代价条件
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,Group.FromCards(c,tc))>0
end
-- 定义效果②的处理函数，检查是否满足发动条件并选择送墓的卡
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足效果②的发动条件（自身可送墓且场上存在符合条件的卡）
	if chk==0 then return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,c,c,tp) end
	-- 提示玩家选择要送墓的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择符合条件的卡并加上自身作为送墓对象
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,c,c,tp)+c
	-- 将选中的卡送入墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义过滤函数，用于判断手牌或卡组中的「蛇眼」怪兽是否可特殊召唤（非本卡）
function s.sfilter(c,e,tp)
	return c:IsSetCard(0x19c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- 定义效果②的目标选择函数，检查是否满足发动条件（存在符合条件的怪兽）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果②的发动条件（已支付代价或场上存在召唤区域）
	if chk==0 then return (e:IsCostChecked() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		-- 检查是否满足效果②的发动条件（存在符合条件的怪兽）
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，标记将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 定义效果②的处理函数，选择并特殊召唤符合条件的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的怪兽特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
