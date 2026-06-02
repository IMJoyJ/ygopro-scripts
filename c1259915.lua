--三幻魔の霹靂
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从自己的手卡·卡组·墓地把2张「三幻魔的霹雳」在自己场上表侧表示放置。那之后，可以把手卡1只10星「三幻魔」怪兽给对方观看。给人观看的场合，再从卡组把1张「三幻魔的失乐园」在自己的场地区域表侧表示放置。
-- ②：这张卡在墓地存在的场合，对方结束阶段才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的入口函数
function s.initial_effect(c)
	-- 记录该卡记载了「三幻魔的失乐园」（65861210）的事实
	aux.AddCodeList(c,65861210)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。从自己的手卡·卡组·墓地把2张「三幻魔的霹雳」在自己场上表侧表示放置。那之后，可以把手卡1只10星「三幻魔」怪兽给对方观看。给人观看的场合，再从卡组把1张「三幻魔的失乐园」在自己的场地区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"放置效果"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的场合，对方结束阶段才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡片名称为「三幻魔的霹雳」，且在场上不被禁止且在场上唯一存在
function s.tffilter(c,tp)
	return c:IsCode(id)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果靶向：确认自己魔陷区有至少2个空格，且手卡·卡组·墓地存在至少2张符合放置条件的卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的魔法与陷阱区域是否还有2个以上的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 检查手卡、卡组、墓地中是否存在至少2张可以放置的「三幻魔的霹雳」
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,2,nil,tp) end
end
-- 过滤条件：手卡中未公开的10星「三幻魔」怪兽
function s.cfilter(c)
	return not c:IsPublic() and c:IsSetCard(0x1144) and c:IsLevel(10)
end
-- 过滤条件：卡组中的「三幻魔的失乐园」且不被禁止放置
function s.setfilter(c)
	return c:IsCode(65861210) and not c:IsForbidden()
end
-- 效果处理：从手卡·卡组·墓地选择2张「三幻魔的霹雳」表侧表示放置在魔陷区。放置成功后，可选择展示手卡10星「三幻魔」并从卡组表侧放置「三幻魔的失乐园」到场地区
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己魔陷区域的空格数不足2个，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=1 then return end
	-- 获取自己手卡、卡组、墓地中符合条件的「三幻魔的霹雳」（不受王家长眠之谷限制）
	local pg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tffilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
	if pg:GetCount()<2 then return end
	local g=pg
	if g:GetCount()>2 then
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		g=g:Select(tp,2,2,nil)
	end
	local ct=0
	-- 遍历选择的所有待放置的卡片
	for tc in aux.Next(g) do
		-- 尝试将卡片表侧表示移动并放置到魔法与陷阱区域，同时立即适用其效果
		if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			ct=ct+1
		end
	end
	-- 检查是否成功放置了2张，且手卡中是否存在符合条件的10星「三幻魔」怪兽
	if ct==2 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
		-- 且卡组中是否存在可以放置的「三幻魔的失乐园」
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否选择把手卡1只10星「三幻魔」怪兽给对方观看
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否给对方观看？"
		-- 中断当前效果处理，使后续效果不视为同时发生
		Duel.BreakEffect()
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 玩家选择手卡中1只10星「三幻魔」怪兽
		local cg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
		-- 给对方玩家确认展示的怪兽卡
		Duel.ConfirmCards(1-tp,cg)
		-- 洗切玩家的手卡
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理，使后续效果不视为同时发生
		Duel.BreakEffect()
		-- 玩家从卡组选择1张「三幻魔的失乐园」
		local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		-- 获取自己场地区域的卡
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			-- 将自己原本场地区域的卡因规则原因送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使后续效果不视为同时发生
			Duel.BreakEffect()
		end
		-- 将选中的「三幻魔的失乐园」在自己的场地区域表侧表示放置
		Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
-- 发动条件：对方回合的结束阶段
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方玩家
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果靶向：确认自身可以加入手卡，并设置加入手卡操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将这张卡（自身）从墓地加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：将墓地中的这张卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否依然适用于效果（受王家长眠之谷限制）
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡送回玩家手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
