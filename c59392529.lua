--E・HERO リキッドマン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡召唤时，以除「元素英雄 液态侠」外的自己墓地1只4星以下的「英雄」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡成为「英雄」融合怪兽的融合召唤的素材，被送去墓地的场合或者被除外的场合才能发动。自己抽2张。那之后，选自己1张手卡丢弃。
function c59392529.initial_effect(c)
	-- ①：这张卡召唤时，以除「元素英雄 液态侠」外的自己墓地1只4星以下的「英雄」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59392529,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,59392529)
	e1:SetTarget(c59392529.target)
	e1:SetOperation(c59392529.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡成为「英雄」融合怪兽的融合召唤的素材，被送去墓地的场合或者被除外的场合才能发动。自己抽2张。那之后，选自己1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59392529,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES_SELF)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,59392529)
	e2:SetCondition(c59392529.drcon)
	e2:SetTarget(c59392529.drtg)
	e2:SetOperation(c59392529.drop)
	c:RegisterEffect(e2)
end
-- 过滤条件：等级4以下且卡名非「元素英雄 液态侠」的「英雄」怪兽，并且可以被特殊召唤
function c59392529.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x8) and not c:IsCode(59392529) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与目标选择：如果是取对象的效果处理，则验证对象合法性；如果是发动检查，则检查怪兽区是否有空位以及自己墓地是否存在符合条件的怪兽
function c59392529.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c59392529.spfilter(chkc,e,tp) end
	-- 检查自己场上的怪兽区域是否有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以成为效果对象的、符合特殊召唤条件的怪兽
		and Duel.IsExistingTarget(c59392529.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向发动效果的玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 在自己墓地选择1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c59392529.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前处理的连锁的操作信息：此效果会特殊召唤选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：获取选中的对象，若其依然符合效果条件，则将其在自己场上特殊召唤
function c59392529.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为特殊召唤对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件判定：这张卡作为「英雄」融合怪兽的融合素材被送去墓地或除外的场合
function c59392529.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and r==REASON_FUSION and c:GetReasonCard():IsSetCard(0x8) and not c:IsReason(REASON_RETURN)
end
-- 效果②的发动准备：检查玩家是否可以抽2张卡，并设置连锁的玩家参数与抽卡、丢弃手卡的操作信息
function c59392529.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 把当前连锁的对象玩家设置成发动效果的玩家自己
	Duel.SetTargetPlayer(tp)
	-- 把当前连锁的对象参数设置成2
	Duel.SetTargetParam(2)
	-- 设置操作信息：自己抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- 效果②的效果处理：获取目标玩家与抽卡数量，执行抽卡。若成功抽到2张，则洗牌、中断效果，然后选自己1张手卡丢弃
function c59392529.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为抽卡对象的玩家以及需要抽卡的数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽卡，并检查是否成功抽足2张
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		-- 将抽到的卡加入手卡后洗切手卡
		Duel.ShuffleHand(p)
		-- 中断当前效果处理，使后续的丢弃手卡处理与抽卡不同时发生
		Duel.BreakEffect()
		-- 让目标玩家选择自己1张手卡丢弃
		Duel.DiscardHand(p,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
