--彼岸の悪鬼 ファーファレル
-- 效果：
-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
-- ③：这张卡被送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽直到结束阶段除外。
function c36553319.initial_effect(c)
	-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c36553319.sdcon)
	c:RegisterEffect(e1)
	-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36553319,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,36553319)
	e2:SetCondition(c36553319.sscon)
	e2:SetTarget(c36553319.sstg)
	e2:SetOperation(c36553319.ssop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽直到结束阶段除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36553319,1))  --"除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,36553319)
	e3:SetTarget(c36553319.rmtg)
	e3:SetOperation(c36553319.rmop)
	c:RegisterEffect(e3)
end
-- 用于判断场上是否存在非「彼岸」怪兽或里侧表示的怪兽
function c36553319.sdfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xb1)
end
-- 当场上存在非「彼岸」怪兽或里侧表示的怪兽时，该卡自我破坏
function c36553319.sdcon(e)
	-- 检查场上是否存在非「彼岸」怪兽或里侧表示的怪兽
	return Duel.IsExistingMatchingCard(c36553319.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 用于判断场上是否存在魔法·陷阱卡
function c36553319.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 当自己场上没有魔法·陷阱卡存在时，该效果可以发动
function c36553319.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在魔法·陷阱卡
	return not Duel.IsExistingMatchingCard(c36553319.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置特殊召唤的处理条件
function c36553319.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c36553319.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 设置除外效果的处理条件
function c36553319.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 检查场上是否存在可除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上一只可除外的怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置除外的处理信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行除外操作并设置返回效果
function c36553319.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽有效且成功除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(36553319,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 设置结束阶段返回场上的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c36553319.retcon)
		e1:SetOperation(c36553319.retop)
		-- 将返回场上的效果注册到游戏环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断目标怪兽是否具有返回场上的标记
function c36553319.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(36553319)~=0
end
-- 将目标怪兽返回到场上
function c36553319.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
