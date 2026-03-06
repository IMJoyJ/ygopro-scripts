--トリックスター・マンドレイク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从手卡送去墓地的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡作为「淘气仙星」连接怪兽的连接素材送去墓地的场合，以对方的连接怪兽的所连接区1只怪兽为对象才能发动。那只怪兽破坏。
function c22219822.initial_effect(c)
	-- ①：这张卡从手卡送去墓地的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22219822,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,22219822)
	e1:SetCondition(c22219822.spcon)
	e1:SetTarget(c22219822.sptg)
	e1:SetOperation(c22219822.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为「淘气仙星」连接怪兽的连接素材送去墓地的场合，以对方的连接怪兽的所连接区1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22219822,1))  --"怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,22219823)
	e2:SetCondition(c22219822.descon)
	e2:SetTarget(c22219822.destg)
	e2:SetOperation(c22219822.desop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否从手牌送去墓地
function c22219822.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 准备处理特殊召唤效果，检查是否有足够的怪兽区域
function c22219822.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤操作，将此卡以守备表示特殊召唤到场上，并设置其离场时除外的效果
function c22219822.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否能被特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 创建一个效果，使此卡从场上离开时被除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 判断此卡是否作为连接素材被送去墓地且其原因怪兽为淘气仙星卡组
function c22219822.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0xfb)
end
-- 过滤出对方场上的连接怪兽
function c22219822.lkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 准备处理破坏效果，获取对方连接怪兽所连接的怪兽作为目标
function c22219822.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Group.CreateGroup()
	-- 获取对方场上的所有连接怪兽
	local lg=Duel.GetMatchingGroup(c22219822.lkfilter,tp,0,LOCATION_MZONE,nil)
	-- 遍历所有连接怪兽，获取它们所连接的怪兽
	for tc in aux.Next(lg) do
		tg:Merge(tc:GetLinkedGroup())
	end
	if chkc then return tg:IsContains(chkc) and chkc:IsCanBeEffectTarget(e) end
	if chk==0 then return tg:IsExists(Card.IsCanBeEffectTarget,1,nil,e) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local g=tg:FilterSelect(tp,Card.IsCanBeEffectTarget,1,1,nil,e)
	-- 设置本次效果的目标怪兽
	Duel.SetTargetCard(g)
	-- 设置破坏效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏操作，将目标怪兽破坏
function c22219822.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
