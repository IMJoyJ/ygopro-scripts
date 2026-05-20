--トリックスター・シャクナージュ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡丢弃1张「淘气仙星」卡，以自己墓地1只「淘气仙星」连接怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，每次从对方墓地有卡被除外，给与对方那些除外的卡数量×200伤害。
function c59604521.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：从手卡丢弃1张「淘气仙星」卡，以自己墓地1只「淘气仙星」连接怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59604521,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,59604521)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c59604521.spcost)
	e1:SetTarget(c59604521.sptg)
	e1:SetOperation(c59604521.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次从对方墓地有卡被除外，给与对方那些除外的卡数量×200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59604521,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c59604521.damcon)
	e2:SetOperation(c59604521.damop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手牌中可丢弃的「淘气仙星」卡片
function c59604521.cfilter(c)
	return c:IsSetCard(0xfb) and c:IsDiscardable()
end
-- 效果①的发动代价：从手卡丢弃1张「淘气仙星」卡
function c59604521.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可丢弃的「淘气仙星」卡片（不包括自身）
	if chk==0 then return Duel.IsExistingMatchingCard(c59604521.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手牌中的「淘气仙星」卡片作为发动代价
	Duel.DiscardHand(tp,c59604521.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：自己墓地可以特殊召唤的「淘气仙星」连接怪兽
function c59604521.filter(c,e,tp)
	return c:IsSetCard(0xfb) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查自己墓地是否存在可特殊召唤的「淘气仙星」连接怪兽且自己场上有空余怪兽区域，并选择该怪兽作为效果对象
function c59604521.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c59604521.filter(chkc,e,tp) end
	-- 检查自己墓地是否存在至少1只满足条件的「淘气仙星」连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c59604521.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 并且检查自己场上是否有空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地1只满足条件的「淘气仙星」连接怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c59604521.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，该效果包含特殊召唤选定对象的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：将作为对象的怪兽在自己场上特殊召唤
function c59604521.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到发动效果玩家的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：原本属于对方且从对方墓地被除外的卡片
function c59604521.damfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(1-tp)
end
-- 效果②的发动条件：检查被除外的卡片中是否存在原本属于对方墓地的卡
function c59604521.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c59604521.damfilter,1,nil,tp)
end
-- 效果②的效果处理：计算对方墓地被除外的卡片数量，并给予对方对应数量×200的伤害
function c59604521.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动该卡的效果（展示卡片动画）
	Duel.Hint(HINT_CARD,0,59604521)
	local ct=eg:FilterCount(c59604521.damfilter,nil,tp)
	-- 给予对方玩家“除外卡片数量×200”的伤害
	Duel.Damage(1-tp,ct*200,REASON_EFFECT)
end
