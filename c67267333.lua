--ヴェンデット・ヘルハウンド
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的场合，从手卡丢弃1张「复仇死者」卡才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。
-- ●1回合1次，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡除外。这个效果在对方回合也能发动。
function c67267333.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，从手卡丢弃1张「复仇死者」卡才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67267333,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,67267333)
	e1:SetCost(c67267333.spcost)
	e1:SetTarget(c67267333.sptg)
	e1:SetOperation(c67267333.spop)
	c:RegisterEffect(e1)
	-- ②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,67267334)
	e2:SetCondition(c67267333.mtcon)
	e2:SetOperation(c67267333.mtop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可丢弃的「复仇死者」卡片
function c67267333.cfilter(c)
	return c:IsSetCard(0x106) and c:IsDiscardable()
end
-- 墓地特殊召唤效果的发动代价：从手卡丢弃1张「复仇死者」卡
function c67267333.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可丢弃的「复仇死者」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c67267333.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张满足过滤条件的手牌作为发动代价
	Duel.DiscardHand(tp,c67267333.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 墓地特殊召唤效果的发动检测与操作信息设置
function c67267333.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 墓地特殊召唤效果的处理：特殊召唤自身，并添加离场时除外的限制
function c67267333.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其以表侧表示特殊召唤到自己场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 检查是否作为仪式素材，且此前存在于怪兽区域，且仪式召唤的是「复仇死者」怪兽
function c67267333.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
		and eg:IsExists(Card.IsSetCard,1,nil,0x106)
end
-- 赋予仪式召唤出的「复仇死者」怪兽除外对方魔陷的效果
function c67267333.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsSetCard,nil,0x106)
	local rc=g:GetFirst()
	if not rc then return end
	-- ●1回合1次，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡除外。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(67267333,1))  --"对方魔法·陷阱卡除外（复仇死者·地狱犬）"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetTarget(c67267333.rmtg)
	e1:SetOperation(c67267333.rmop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ●1回合1次，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡除外。这个效果在对方回合也能发动。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(67267333,2))  --"「复仇死者·地狱犬」效果适用中"
end
-- 过滤对方场上可以被除外的魔法·陷阱卡
function c67267333.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 赋予效果的发动检测与对象选择
function c67267333.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c67267333.rmfilter(chkc) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可除外的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c67267333.rmfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c67267333.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为除外目标卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 赋予效果的处理：除外作为对象的卡片
function c67267333.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
