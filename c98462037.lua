--閃刀姫－アザレア
-- 效果：
-- 光·暗属性怪兽2只
-- 这张卡不用连接召唤不能特殊召唤，自己对「闪刀姬-阿泽莉娅」1回合只能有1次特殊召唤。
-- ①：这张卡特殊召唤的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，自己墓地的魔法卡是3张以下的场合，这张卡送去墓地。
-- ②：1回合1次，这张卡和对方怪兽进行战斗的伤害步骤开始时，从自己墓地把1张魔法卡除外才能发动。那只对方怪兽破坏。
function c98462037.initial_effect(c)
	c:SetSPSummonOnce(98462037)
	-- 设置连接召唤的手续，需要2只光或暗属性的怪兽作为素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_LIGHT+ATTRIBUTE_DARK),2,2)
	c:EnableReviveLimit()
	-- 这张卡不用连接召唤不能特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该怪兽只能通过连接召唤的方式特殊召唤。
	e0:SetValue(aux.linklimit)
	c:RegisterEffect(e0)
	-- ①：这张卡特殊召唤的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，自己墓地的魔法卡是3张以下的场合，这张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98462037,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c98462037.destg1)
	e1:SetOperation(c98462037.desop1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡和对方怪兽进行战斗的伤害步骤开始时，从自己墓地把1张魔法卡除外才能发动。那只对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98462037,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCountLimit(1)
	e2:SetCost(c98462037.descost2)
	e2:SetTarget(c98462037.destg2)
	e2:SetOperation(c98462037.desop2)
	c:RegisterEffect(e2)
end
-- 效果①的靶向（Target）函数：检测场上是否存在可选择的卡，并让玩家选择1张卡作为对象，设置破坏操作信息。
function c98462037.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在至少1张可以作为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示其选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动效果的玩家选择场上1张卡作为效果的对象并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息，表示该效果将破坏所选的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的执行（Operation）函数：破坏选择的对象，并判定若自己墓地魔法卡在3张以下，则将此卡送去墓地。
function c98462037.desop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动阶段选择的效果对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判定对象卡是否仍对该效果有效，若有效则将其破坏，并确认是否成功破坏。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0
		and c:IsRelateToEffect(e)
		-- 判定自己墓地的魔法卡数量是否在3张或以下。
		and Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)<=3 then
		-- 中断当前效果处理，使后续的送去墓地处理与之前的破坏处理不视为同时进行。
		Duel.BreakEffect()
		-- 将这张卡自身送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
-- 过滤函数：筛选自己墓地中可以被除外的魔法卡。
function c98462037.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
-- 效果②的消耗（Cost）函数：检查并从自己墓地将1张魔法卡除外。
function c98462037.descost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1张可以除外的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c98462037.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示其选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让发动效果的玩家从自己墓地选择1张满足条件的魔法卡。
	local g=Duel.SelectMatchingCard(tp,c98462037.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的魔法卡表侧表示除外，作为发动效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的靶向（Target）函数：获取进行战斗的对方怪兽，并设置破坏操作信息。
function c98462037.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) end
	-- 设置当前连锁的操作信息，表示该效果将破坏进行战斗的对方怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果②的执行（Operation）函数：若进行战斗的对方怪兽仍处于战斗状态且由对方控制，则将其破坏。
function c98462037.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc:IsRelateToBattle() and tc:IsControler(1-tp) then
		-- 破坏进行战斗的对方怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
