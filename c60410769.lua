--ジュッテ・ナイト
-- 效果：
-- 1回合只有1次，可以把对方场上表侧攻击表示存在的1只怪兽变成表侧守备表示。
function c60410769.initial_effect(c)
	-- 1回合只有1次，可以把对方场上表侧攻击表示存在的1只怪兽变成表侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60410769,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c60410769.postg)
	e1:SetOperation(c60410769.posop)
	c:RegisterEffect(e1)
end
-- 过滤对方场上表侧攻击表示且可以改变表示形式的怪兽
function c60410769.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 效果发动的目标选择与判定函数
function c60410769.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c60410769.filter(chkc) end
	-- 判定是否能选择对方场上1只表侧攻击表示且可以改变表示形式的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c60410769.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧攻击表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 选择对方场上1只表侧攻击表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c60410769.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：改变1张卡片的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理函数：将选择的对象怪兽变成表侧守备表示
function c60410769.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsPosition(POS_FACEUP_ATTACK) then
		-- 将目标怪兽变成表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
