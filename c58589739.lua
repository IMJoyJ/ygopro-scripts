--S－Force プロフェッサー・Ϝ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的表示形式变更。
-- ②：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽不能用效果以外把表示形式变更。
function c58589739.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58589739,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,58589739)
	e1:SetTarget(c58589739.postg)
	e1:SetOperation(c58589739.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽不能用效果以外把表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c58589739.chtg)
	c:RegisterEffect(e3)
end
-- 过滤对方场上表侧表示且可以变更表示形式的怪兽
function c58589739.posfilter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- ①号效果的发动准备（检查并选择对方场上1只表侧表示怪兽作为对象）
function c58589739.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c58589739.posfilter(chkc) end
	-- 在发动阶段，检查对方场上是否存在至少1只可以变更表示形式的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c58589739.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家发送提示信息，要求选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c58589739.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该效果包含改变表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ①号效果的效果处理（将作为对象的怪兽的表示形式变更）
function c58589739.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽的表示形式变更（表侧攻击表示与表侧守备表示互相转换）
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 过滤自己场上表侧表示的「治安战警队」怪兽
function c58589739.chfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x156) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 判断该怪兽同纵列（正对面）是否存在自己的「治安战警队」怪兽
function c58589739.chtg(e,c)
	local cg=c:GetColumnGroup()
	return cg:IsExists(c58589739.chfilter,1,nil,e:GetHandlerPlayer())
end
