--蕾禍繚乱狂咲
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：场上的昆虫族·植物族·爬虫类族怪兽的攻击力·守备力上升300，那以外的场上的怪兽的攻击力·守备力下降300。
-- ②：可以从以下效果选择1个发动。
-- ●从卡组把1只「蕾祸」怪兽加入手卡。那之后，选自己1张手卡丢弃。
-- ●自己的手卡·墓地·除外状态的1只「蕾祸」怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果，使该卡可以被正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上的昆虫族·植物族·爬虫类族怪兽的攻击力上升300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：可以从以下效果选择1个发动。●从卡组把1只「蕾祸」怪兽加入手卡。那之后，选自己1张手卡丢弃。●自己的手卡·墓地·除外状态的1只「蕾祸」怪兽守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"发动效果"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 根据怪兽种族判断攻击力增减数值：若为昆虫族、植物族或爬虫类族则增加300，否则减少300
function s.val(e,c)
	local r=c:GetRace()
	if bit.band(r,RACE_INSECT+RACE_PLANT+RACE_REPTILE)~=0 then return 300
	else return -300 end
end
-- 过滤函数：筛选可以加入手牌的「蕾祸」怪兽
function s.filter1(c)
	return c:IsSetCard(0x1ab) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤函数：筛选可以特殊召唤的「蕾祸」怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1ab) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 处理②效果的选择与目标设定，根据是否满足两个条件决定选项数量和操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查卡组中是否存在符合条件的「蕾祸」怪兽
	local b1=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil)
	-- 检查玩家场上是否有可用区域进行特殊召唤
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌、墓地或除外状态是否存在符合条件的「蕾祸」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 当两个选项都可选时，让玩家选择其中一个效果
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))  --"检索「蕾祸」怪兽/特殊召唤「蕾祸」怪兽"
	elseif b1 then
		-- 当只有检索效果可选时，直接选择该效果
		op=Duel.SelectOption(tp,aux.Stringid(id,2))  --"检索「蕾祸」怪兽"
	else
		-- 当只有特殊召唤效果可选时，选择该效果并加一以匹配编号
		op=Duel.SelectOption(tp,aux.Stringid(id,3))+1  --"特殊召唤「蕾祸」怪兽"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置操作信息：将一张卡从卡组加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		-- 设置操作信息：丢弃一张手卡
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息：特殊召唤一只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	end
end
-- 处理②效果的执行逻辑，根据选择的选项执行不同操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 提示玩家从卡组中选择一张「蕾祸」怪兽加入手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的一张「蕾祸」怪兽
		local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选中的怪兽送入手牌并确认其进入手牌
		if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
			-- 向对方确认所选的怪兽
			Duel.ConfirmCards(1-tp,g)
			-- 洗切自己的手牌
			Duel.ShuffleHand(tp)
			-- 中断当前效果处理，防止连锁错时
			Duel.BreakEffect()
			-- 丢弃一张手卡
			Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD,nil)
		end
	else
		-- 检查是否有足够的召唤区域进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的「蕾祸」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的一只「蕾祸」怪兽用于特殊召唤
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以守备表示形式特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
		end
	end
end
