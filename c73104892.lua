--いろはもみじ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，宣言1个属性才能发动。这张卡得到以下效果。
-- ●场上的全部表侧表示怪兽变成宣言的属性。
-- ②：以对方的主要怪兽区域1只怪兽为对象才能发动。对方必须从那只怪兽的前面·后面·相邻的区域（怪兽区域·魔法与陷阱区域）存在的卡之中把1张送去墓地。
function c73104892.initial_effect(c)
	-- 设置同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合，宣言1个属性才能发动。这张卡得到以下效果。●场上的全部表侧表示怪兽变成宣言的属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73104892,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,73104892)
	e1:SetTarget(c73104892.atttg)
	e1:SetOperation(c73104892.attop)
	c:RegisterEffect(e1)
	-- ②：以对方的主要怪兽区域1只怪兽为对象才能发动。对方必须从那只怪兽的前面·后面·相邻的区域（怪兽区域·魔法与陷阱区域）存在的卡之中把1张送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73104892,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,73104893)
	e2:SetTarget(c73104892.tgtg)
	e2:SetOperation(c73104892.tgop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备：进行属性宣言并记录
function c73104892.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言1个属性
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	e:SetLabel(att)
end
-- ①效果的实际处理：使这张卡获得改变场上表侧表示怪兽属性的永续效果
function c73104892.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local att=e:GetLabel()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- ●场上的全部表侧表示怪兽变成宣言的属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e1:SetValue(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		c:SetHint(CHINT_ATTRIBUTE,att)
	end
end
-- 过滤对方主要怪兽区域的怪兽，要求其前、后、相邻区域存在至少1张卡
function c73104892.cfilter(c,tp)
	local seq=c:GetSequence()
	-- 限制在主要怪兽区域（格子编号小于5），且其周围区域存在可送去墓地的卡
	return seq<5 and Duel.IsExistingMatchingCard(c73104892.tgfilter,tp,LOCATION_MZONE,LOCATION_ONFIELD,1,nil,tp,seq)
end
-- 过滤指定怪兽的前面、后面、相邻区域（怪兽区域·魔法与陷阱区域）的卡
function c73104892.tgfilter(c,tp,seq)
	local sseq=c:GetSequence()
	if c:IsControler(tp) then
		return sseq==5 and seq==3 or sseq==6 and seq==1
	end
	if c:IsLocation(LOCATION_SZONE) then
		return sseq<5 and sseq==seq
	end
	if sseq<5 then
		return math.abs(sseq-seq)==1
	end
	if sseq>=5 then
		return sseq==5 and seq==1 or sseq==6 and seq==3
	end
end
-- ②效果的发动准备：选择对方主要怪兽区域的1只怪兽作为对象
function c73104892.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c73104892.cfilter(chkc,tp) end
	-- 检查对方主要怪兽区域是否存在满足条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c73104892.cfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方主要怪兽区域的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73104892.cfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
end
-- ②效果的实际处理：对方必须选择该怪兽周围区域的1张卡送去墓地
function c73104892.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 提示对方玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 对方从该怪兽的前面、后面、相邻区域选择1张卡
	local g=Duel.SelectMatchingCard(1-tp,c73104892.tgfilter,tp,LOCATION_MZONE,LOCATION_ONFIELD,1,1,nil,tp,tc:GetSequence())
	-- 确认并给对方选择的卡片显示选中动画
	Duel.HintSelection(g)
	-- 将选择的卡送去墓地（由对方玩家执行，属于玩家受效果波动的行为，用REASON_RULE）
	Duel.SendtoGrave(g,REASON_RULE,1-tp)
end
