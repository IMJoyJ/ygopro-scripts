--妖竜の禁姫
-- 效果：
-- 龙族融合怪兽＋7星以上的龙族怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。把场上的卡除外的场合，再让自己场上1只龙族怪兽回到手卡。
-- ②：这张卡在墓地存在的场合，对方战斗阶段开始时才能发动。自己场上1只龙族怪兽回到手卡·额外卡组，这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 设置融合召唤素材：龙族融合怪兽＋7星以上的龙族怪兽
	aux.AddFusionProcFun2(c,s.mfilter1,s.mfilter2,true)
	c:EnableReviveLimit()
	-- ①：自己·对方的主要阶段，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。把场上的卡除外的场合，再让自己场上1只龙族怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，对方战斗阶段开始时才能发动。自己场上1只龙族怪兽回到手卡·额外卡组，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤条件1：龙族融合怪兽
function s.mfilter1(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_FUSION)
end
-- 融合素材过滤条件2：7星以上的龙族怪兽
function s.mfilter2(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevelAbove(7)
end
-- 效果①的发动条件：自己或对方的主要阶段
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- 过滤条件：自己场上表侧表示、可以回到手牌的龙族怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 效果①的发动准备（检查并选择对象）
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local loc=LOCATION_GRAVE
	-- 检查自己场上是否存在可以回到手牌的龙族怪兽（若不存在，则不能选择对方场上的卡作为对象）
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then
		loc=loc|LOCATION_ONFIELD
	end
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(loc) and chkc:IsAbleToRemove() end
	-- 步骤0：检查对方场上或墓地是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,loc,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从场上（若可行）或墓地选择1张对方的卡作为效果对象
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToRemove,tp,0,loc,1,1,nil)
	-- 设置除外操作的信息，包含目标卡片组
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的处理：除外目标卡，若除外了场上的卡，则再让自己场上1只龙族怪兽回到手牌
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的目标卡
	local tc=Duel.GetFirstTarget()
	-- 若目标卡仍与效果相关，且成功除外，并且该卡原本存在于场上
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsPreviousLocation(LOCATION_ONFIELD)
		and (tc:IsLocation(LOCATION_REMOVED) or tc:IsType(TYPE_TOKEN)) then
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 玩家选择自己场上1只满足条件的龙族怪兽
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果，使后续的返回手牌处理与除外处理不同时进行
			Duel.BreakEffect()
			-- 闪烁显示被选中的怪兽
			Duel.HintSelection(g)
			-- 将选中的龙族怪兽送回持有者手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
-- 效果②的发动条件：对方战斗阶段开始时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方的回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤条件：自己场上表侧表示、可以回到手牌或额外卡组的龙族怪兽，且需满足特殊召唤所需的怪兽区域空位要求
function s.thefilter(c,tp,chk)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and (c:IsAbleToHand() or c:IsAbleToExtra())
		-- 检查该怪兽离开场上后，是否能空出可用于特殊召唤的怪兽区域
		and (Duel.GetMZoneCount(tp,c)>0 or not chk)
end
-- 效果②的发动准备（检查是否能发动）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查自己场上是否存在可返回手牌/额外卡组且能腾出怪兽区域的龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thefilter,tp,LOCATION_MZONE,0,1,nil,tp,true)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置返回手牌操作的信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
	-- 设置特殊召唤操作的信息（特殊召唤墓地的此卡）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的处理：将自己场上1只龙族怪兽回到手牌/额外卡组，并将此卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要返回手牌或额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local rg=nil
	-- 检查是否存在能腾出怪兽区域的龙族怪兽
	if Duel.IsExistingMatchingCard(s.thefilter,tp,LOCATION_MZONE,0,1,nil,tp,true) then
		-- 选择1只返回后能腾出怪兽区域的龙族怪兽
		rg=Duel.SelectMatchingCard(tp,s.thefilter,tp,LOCATION_MZONE,0,1,1,nil,tp,true)
	else
		-- 若无需考虑腾出区域（例如已有其他空位），则任意选择1只满足条件的龙族怪兽
		rg=Duel.SelectMatchingCard(tp,s.thefilter,tp,LOCATION_MZONE,0,1,1,nil,tp,false)
	end
	if rg and rg:GetCount()>0 then
		-- 闪烁显示被选中的怪兽
		Duel.HintSelection(rg)
		-- 若成功将选中的怪兽送回手牌或额外卡组
		if Duel.SendtoHand(rg,nil,REASON_EFFECT)~=0 and rg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND+LOCATION_EXTRA)
			-- 且此卡仍存在于墓地，并且不受王家长眠之谷的影响
			and c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
			-- 将此卡在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
