--メタルフォーゼ・カウンター
-- 效果：
-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。从卡组把1只「炼装」怪兽特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从自己的额外卡组把1只表侧表示的「炼装」灵摆怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c33327029.initial_effect(c)
	-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。从卡组把1只「炼装」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CUSTOM+33327029)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c33327029.condition)
	e1:SetTarget(c33327029.target)
	e1:SetOperation(c33327029.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己的额外卡组把1只表侧表示的「炼装」灵摆怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	-- 效果作用：设置此效果为不能在该卡送去墓地的回合发动
	e2:SetCondition(aux.exccon)
	-- 效果作用：将此卡从墓地除外作为发动cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c33327029.thtg)
	e2:SetOperation(c33327029.thop)
	c:RegisterEffect(e2)
	if not c33327029.global_check then
		c33327029.global_check=true
		-- 效果作用：注册一个全局场上的破坏事件监听器，用于触发效果
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c33327029.regcon)
		ge1:SetOperation(c33327029.regop)
		-- 效果作用：将全局事件监听器注册到游戏环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 效果作用：定义一个过滤函数，用于判断卡是否因战斗或效果被破坏且在场上
function c33327029.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果作用：判断是否满足触发条件，即是否有卡因战斗或效果被破坏
function c33327029.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c33327029.cfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c33327029.cfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 效果作用：触发自定义事件，通知连锁处理
function c33327029.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：以指定参数触发自定义事件，用于激活效果
	Duel.RaiseEvent(eg,EVENT_CUSTOM+33327029,re,r,rp,ep,e:GetLabel())
end
-- 效果作用：判断是否满足发动条件，即是否为己方或双方破坏
function c33327029.condition(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- 效果作用：定义一个过滤函数，用于筛选「炼装」怪兽
function c33327029.filter(c,e,tp)
	return c:IsSetCard(0xe1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：判断是否满足发动条件，即场上是否有空位且卡组有符合条件的怪兽
function c33327029.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断卡组是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c33327029.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息，表示将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：定义效果发动时的操作，包括选择并特殊召唤怪兽
function c33327029.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c33327029.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果作用：定义一个过滤函数，用于筛选「炼装」灵摆怪兽
function c33327029.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xe1) and c:IsAbleToHand()
end
-- 效果作用：判断是否满足发动条件，即额外卡组有符合条件的灵摆怪兽
function c33327029.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断额外卡组是否存在符合条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c33327029.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 效果作用：设置连锁操作信息，表示将灵摆怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果作用：定义效果发动时的操作，包括选择并加入手牌
function c33327029.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：选择满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c33327029.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 效果作用：将选中的灵摆怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 效果作用：确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
