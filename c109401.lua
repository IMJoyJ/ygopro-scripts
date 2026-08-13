--闇次元の戦士
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把1张手卡除外，以除外的1只自己的暗属性怪兽为对象才能发动。那只怪兽表侧守备表示或者里侧守备表示特殊召唤。
-- ②：自己·对方的结束阶段发动。给与对方为场上盖放的卡数量×100伤害。
function c109401.initial_effect(c)
	-- 设定此卡的同调召唤手续：需要1只调整+1只以上调整以外的怪兽作为素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：把1张手卡除外，以除外的1只自己的暗属性怪兽为对象才能发动。那只怪兽表侧守备表示或者里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,109401)
	e1:SetCost(c109401.spcost)
	e1:SetTarget(c109401.sptg)
	e1:SetOperation(c109401.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段发动。给与对方为场上盖放的卡数量×100伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,109402)
	e2:SetTarget(c109401.damtg)
	e2:SetOperation(c109401.damop)
	c:RegisterEffect(e2)
end
-- 效果①发动时的代价处理：从手卡挑选1张卡除外作为发动代价。
function c109401.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价的合法性检查：确认手卡中存在至少1张可以除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡选择1张卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡片表侧表示除外，完成代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义特殊召唤对象过滤条件：对象需为表侧表示的暗属性除外区怪兽，且能够以守备表示特殊召唤。
function c109401.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- 效果①的发动目标选择：检查怪兽区空位和除外区可特殊召唤的暗属性怪兽，并从其中选择1只为对象。
function c109401.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c109401.spfilter(chkc,e,tp) end
	-- 发动条件检查：自己场上主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：除外区是否存在至少1只符合条件的暗属性怪兽可以作为对象。
		and Duel.IsExistingTarget(c109401.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 弹出选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从除外区选择1只符合条件的暗属性怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c109401.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①处理：为自己的怪兽区仍有空位时，将对象怪兽以守备表示特殊召唤；若召唤后仍为里侧表示则给对方确认。
function c109401.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否有怪兽区空位，若没有则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得效果处理时锁定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以守备表示特殊召唤；若实际召唤后为里侧表示，则继续执行确认。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)~=0 and tc:IsFacedown() then
			-- 向对方玩家确认这只里侧表示特殊召唤的怪兽。
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
-- 效果②的目标设定：计算结束阶段时场上盖放卡数量并设定伤害对象与伤害值。
function c109401.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 统计双方场上里侧表示的卡的数量，乘以100作为伤害值。
	local dam=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*100
	-- 设定伤害对象为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将计算出的伤害值作为连锁参数保存。
	Duel.SetTargetParam(dam)
	-- 设置操作信息：本次连锁将给予对方玩家效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果②处理：根据处理时场上盖放卡的数量重新计算伤害，并给予对方伤害。
function c109401.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时设定的伤害对象玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 在处理时重新统计双方场上里侧表示卡的数量并计算伤害值。
	local dam=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*100
	-- 向对方玩家造成计算出的效果伤害。
	Duel.Damage(p,dam,REASON_EFFECT)
end
