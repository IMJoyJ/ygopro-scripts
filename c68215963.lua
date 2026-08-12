--宝玉獣 エメラルド・タートル
-- 效果：
-- ①：1回合1次，以这个回合进行过攻击的自己场上1只攻击表示怪兽为对象才能发动。那只自己怪兽变成守备表示。
-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c68215963.initial_effect(c)
	-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c68215963.repcon)
	e1:SetOperation(c68215963.repop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以这个回合进行过攻击的自己场上1只攻击表示怪兽为对象才能发动。那只自己怪兽变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68215963,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c68215963.target)
	e2:SetOperation(c68215963.operation)
	c:RegisterEffect(e2)
end
-- 判定此卡是否在怪兽区域表侧表示被破坏
function c68215963.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 将被破坏的此卡作为永续魔法卡在自己的魔法与陷阱区域表侧表示放置
function c68215963.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 当作永续魔法卡使用
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 过滤出自己场上在这个回合进行过攻击的攻击表示且可以改变表示形式的怪兽
function c68215963.filter(c)
	return c:IsAttackPos() and c:GetAttackedCount()>0 and c:IsCanChangePosition()
end
-- 效果①的发动准备，确认是否存在符合条件的怪兽，并选择1只该怪兽作为效果对象
function c68215963.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c68215963.filter(chkc) end
	-- 判定自己场上是否存在至少1只在这个回合进行过攻击的攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c68215963.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只在这个回合进行过攻击的攻击表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68215963.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果①的效果处理，将作为对象的怪兽变成守备表示
function c68215963.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(tp) then
		-- 将目标怪兽变成表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0)
	end
end
