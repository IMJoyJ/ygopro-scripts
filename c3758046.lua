--DDD怒濤王シーザー
-- 效果：
-- 恶魔族4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡1个超量素材取除才能发动。这个回合的战斗阶段结束时，这个回合被破坏的怪兽从自己墓地尽可能特殊召唤。下个回合的准备阶段，自己受到这个效果特殊召唤的怪兽数量×1000伤害。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把1张「契约书」卡加入手卡。
function c3758046.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用满足种族为恶魔族条件的4星怪兽作为素材进行叠放，最少需要2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),4,2)
	c:EnableReviveLimit()
	-- ①：自己·对方回合，把这张卡1个超量素材取除才能发动。这个回合的战斗阶段结束时，这个回合被破坏的怪兽从自己墓地尽可能特殊召唤。下个回合的准备阶段，自己受到这个效果特殊召唤的怪兽数量×1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3758046,0))  --"这个回合被破坏的怪兽在战斗阶段结束时特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,3758046)
	-- 设置效果发动条件为当前处于可以进行战斗相关操作的时点或阶段
	e1:SetCondition(aux.bpcon)
	e1:SetCost(c3758046.cost)
	e1:SetOperation(c3758046.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把1张「契约书」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3758046,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,3758047)
	e2:SetCondition(c3758046.thcon)
	e2:SetTarget(c3758046.thtg)
	e2:SetOperation(c3758046.thop)
	c:RegisterEffect(e2)
end
-- 支付效果代价：从自己场上移除1个超量素材
function c3758046.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 创建一个在战斗阶段结束时触发的效果，用于处理特殊召唤被破坏的怪兽
function c3758046.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在战斗阶段结束时，将满足条件的墓地怪兽特殊召唤到场上，并在下个准备阶段造成伤害
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetCountLimit(1)
	e1:SetOperation(c3758046.spop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家的全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 定义过滤函数，用于筛选被破坏且在当前回合被破坏的怪兽，并满足特殊召唤条件
function c3758046.filter(c,e,tp,id)
	return c:IsReason(REASON_DESTROY) and c:GetTurnID()==id and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理特殊召唤被破坏怪兽的函数，包括获取可召唤数量、选择召唤卡片并执行特殊召唤
function c3758046.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家当前场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取满足条件的墓地怪兽数组，包括受王家长眠之谷影响的过滤
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c3758046.filter),tp,LOCATION_GRAVE,0,nil,e,tp,Duel.GetTurnCount())
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local g=nil
	if tg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if g:GetCount()>0 then
		-- 将符合条件的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 在下个准备阶段触发效果，造成伤害
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(3758046,2))  --"受到伤害"
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabel(g:GetCount())
		e1:SetReset(RESET_PHASE+PHASE_STANDBY)
		e1:SetOperation(c3758046.damop)
		-- 将造成伤害的效果注册到玩家的全局环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 处理造成伤害的函数，根据特殊召唤的怪兽数量计算并造成伤害
function c3758046.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家造成指定数量的伤害
	Duel.Damage(tp,e:GetLabel()*1000,REASON_EFFECT)
end
-- 判断卡片是否从场上送去墓地的条件函数
function c3758046.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义检索「契约书」卡的过滤函数
function c3758046.thfilter(c)
	return c:IsSetCard(0xae) and c:IsAbleToHand()
end
-- 设置检索效果的目标信息
function c3758046.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在卡组中存在满足条件的「契约书」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c3758046.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要从卡组检索1张「契约书」卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理检索效果的函数，选择并加入手牌
function c3758046.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的「契约书」卡
	local g=Duel.SelectMatchingCard(tp,c3758046.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
