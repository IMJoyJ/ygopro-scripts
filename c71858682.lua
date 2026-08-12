--騎士皇アークシーラ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「百夫长骑士」卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己的魔法与陷阱区域的表侧表示卡不会被效果破坏。
-- ③：自己·对方的结束阶段才能发动。同调怪兽以外的自己的墓地·除外状态的1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 注册卡片效果：同调召唤手续、特殊召唤成功时检索「百夫长骑士」卡、魔陷区表侧表示卡的效果破坏抗性、结束阶段将墓地/除外的「百夫长骑士」怪兽当作永续陷阱放置。
function s.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「百夫长骑士」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索「百夫长骑士」卡"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己的魔法与陷阱区域的表侧表示卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	-- 过滤受保护的卡：自己魔法与陷阱区域（不含场地魔法卡）表侧表示存在的卡
	e2:SetTarget(aux.TargetBoolFunction(aux.AND(aux.NOT(Card.IsType),Card.IsFaceup),TYPE_FIELD))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己·对方的结束阶段才能发动。同调怪兽以外的自己的墓地·除外状态的1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"放置「百夫长骑士」怪兽"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中可以加入手牌的「百夫长骑士」卡
function s.thfilter(c)
	return c:IsSetCard(0x1a2) and c:IsAbleToHand()
end
-- 特殊召唤成功时检索效果的发动条件检查与操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「百夫长骑士」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤成功时检索效果的处理：从卡组将1张「百夫长骑士」卡加入手牌并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「百夫长骑士」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤墓地或除外状态下，表侧表示、非同调怪兽的「百夫长骑士」怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden() and not c:IsType(TYPE_SYNCHRO)
end
-- 结束阶段放置效果的发动条件检查
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地或除外状态下是否存在满足条件的「百夫长骑士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		-- 并且检查自己的魔法与陷阱区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 结束阶段放置效果的处理：将墓地或除外的1只「百夫长骑士」怪兽在魔陷区表侧表示放置，并使其当作永续陷阱卡使用
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若魔法与陷阱区域没有空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从墓地或除外状态选择1张不受「王家长眠之谷」影响的满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡表侧表示移动到自己的魔法与陷阱区域
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 当作永续陷阱卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
