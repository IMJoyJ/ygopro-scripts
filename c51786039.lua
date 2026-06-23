--星雲龍ネビュラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡和手卡1只龙族·8星怪兽给对方观看才能发动。那2只守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是光·暗属性的龙族怪兽不能召唤·特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1只光·暗属性的龙族·4星怪兽为对象才能发动。那只怪兽加入手卡。
function c51786039.initial_effect(c)
	-- ①：把手卡的这张卡和手卡1只龙族·8星怪兽给对方观看才能发动。那2只守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是光·暗属性的龙族怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51786039,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,51786039)
	e1:SetTarget(c51786039.sptg)
	e1:SetOperation(c51786039.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只光·暗属性的龙族·4星怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51786039,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,51786040)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c51786039.thtg)
	e2:SetOperation(c51786039.thop)
	c:RegisterEffect(e2)
end
-- 特殊召唤条件过滤器，用于筛选手卡中满足条件的8星龙族怪兽
function c51786039.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(8) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的条件判断，检查是否满足特殊召唤的条件
function c51786039.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and not c:IsPublic()
		-- 检查手卡中是否存在符合条件的8星龙族怪兽
		and Duel.IsExistingMatchingCard(c51786039.spfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择符合条件的8星龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c51786039.spfilter,tp,LOCATION_HAND,0,1,1,c,e,tp)
	local tc=g:GetFirst()
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 将此卡公开
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 设置连锁结束后清除公开状态的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_HAND)
	e2:SetOperation(c51786039.clearop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
	-- 记录当前连锁编号用于后续判断
	e2:SetLabel(Duel.GetCurrentChain())
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	tc:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetLabelObject(e3)
	tc:RegisterEffect(e4)
	-- 设置本次效果的目标卡
	Duel.SetTargetCard(g)
	-- 设置操作信息，表示将特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- 连锁解决时清除公开状态的处理函数
function c51786039.clearop(e,tp,eg,ep,ev,re,r,rp)
	if ev~=e:GetLabel() then return end
	e:GetLabelObject():Reset()
	e:Reset()
end
-- 效果发动时的处理流程，包括特殊召唤和效果无效化
function c51786039.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 将此卡特殊召唤到场上（守备表示）
		Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 将选中的8星龙族怪兽特殊召唤到场上（守备表示）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 设置被特殊召唤的怪兽效果无效化的处理
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		c:RegisterEffect(e2,true)
		local e3=e1:Clone()
		tc:RegisterEffect(e3,true)
		local e4=e2:Clone()
		tc:RegisterEffect(e4,true)
		-- 完成所有特殊召唤操作
		Duel.SpecialSummonComplete()
	end
	-- 设置发动后直到回合结束时禁止召唤·特殊召唤非光·暗属性龙族怪兽的效果
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e5:SetTargetRange(1,0)
	e5:SetTarget(c51786039.splimit)
	e5:SetReset(RESET_PHASE+PHASE_END)
	-- 注册禁止特殊召唤的效果
	Duel.RegisterEffect(e5,tp)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_SUMMON)
	-- 注册禁止召唤的效果
	Duel.RegisterEffect(e6,tp)
end
-- 限制召唤·特殊召唤的条件，只能是光或暗属性的龙族怪兽
function c51786039.splimit(e,c)
	return not c:IsRace(RACE_DRAGON) or not c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 检索墓地符合条件的4星光·暗属性龙族怪兽的过滤器
function c51786039.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 设置效果目标，选择墓地中的4星光·暗属性龙族怪兽
function c51786039.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c51786039.thfilter(chkc) end
	-- 检查是否存在符合条件的墓地中的4星光·暗属性龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c51786039.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择符合条件的墓地中的4星光·暗属性龙族怪兽
	local g=Duel.SelectTarget(tp,c51786039.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果发动时的处理流程，将目标怪兽加入手牌
function c51786039.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
