--深淵の獣マグナムート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己或对方的墓地1只光·暗属性怪兽为对象才能发动（对方场上有怪兽存在的场合，这个效果在对方回合也能发动）。那只怪兽除外，这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。这个回合的结束阶段，从自己的卡组·墓地把「深渊之兽 玛格巨龙」以外的1只龙族怪兽加入手卡。
local s,id,o=GetID()
-- 创建并注册三个效果：①起动效果、②诱发即时效果、③特殊召唤成功时的诱发效果
function s.initial_effect(c)
	-- ①：以自己或对方的墓地1只光·暗属性怪兽为对象才能发动（对方场上有怪兽存在的场合，这个效果在对方回合也能发动）。那只怪兽除外，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.spcon2)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤的场合才能发动。这个回合的结束阶段，从自己的卡组·墓地把「深渊之兽 玛格巨龙」以外的1只龙族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：自己场上没有怪兽
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 自己场上没有怪兽
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0
end
-- 效果②的发动条件：对方场上存在怪兽
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 对方场上存在怪兽
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤条件：光·暗属性且可除外的怪兽
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToRemove()
end
-- 效果①的发动时点处理：设置目标选择和操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.cfilter(chkc) end
	local c=e:GetHandler()
	-- 判断是否满足效果①的发动条件：墓地存在光·暗属性怪兽
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
		-- 判断是否满足效果①的发动条件：自己场上存在空位且自身可特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择墓地中的光·暗属性怪兽作为除外对象
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：将目标怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理流程：将目标怪兽除外并特殊召唤自身
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽和自身是否仍存在于场上并满足处理条件
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的处理流程：注册结束阶段触发效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 注册结束阶段触发效果，用于在结束阶段检索龙族怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将结束阶段触发效果注册到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：龙族且可加入手牌且非自身
function s.filter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 结束阶段触发效果的处理流程：检索龙族怪兽并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动效果的卡号
	Duel.Hint(HINT_CARD,0,id)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择一只龙族怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
