--カラクリ蝦蟇 四六弐四
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡可以攻击的场合必须作出攻击。
-- ②：这张卡被选择作为攻击对象的场合发动。这张卡的表示形式变更。
-- ③：把墓地的这张卡除外，以自己场上1只「机巧」怪兽为对象才能发动。那只怪兽的表示形式变更。这个效果在对方回合也能发动。
function c75690317.initial_effect(c)
	-- ①：这张卡可以攻击的场合必须作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e1)
	-- ②：这张卡被选择作为攻击对象的场合发动。这张卡的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75690317,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetOperation(c75690317.posop1)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：把墓地的这张卡除外，以自己场上1只「机巧」怪兽为对象才能发动。那只怪兽的表示形式变更。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75690317,1))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,75690317)
	-- 设置效果③的发动代价：将墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c75690317.postg1)
	e3:SetOperation(c75690317.posop2)
	c:RegisterEffect(e3)
end
-- 效果②（被选择作为攻击对象时变更表示形式）的效果处理函数
function c75690317.posop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将这张卡自身的表示形式变更（表侧攻击表示与表侧守备表示互相转换）
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
-- 过滤条件：自己场上表侧表示、属于「机巧」系列且可以变更表示形式的怪兽
function c75690317.posfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x11) and c:IsCanChangePosition()
end
-- 效果③（墓地除外变更场上「机巧」怪兽表示形式）的选择对象与发动准备函数
function c75690317.postg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c75690317.posfilter(chkc) end
	-- 在发动阶段（chk==0）检测自己场上是否存在满足条件的「机巧」怪兽
	if chk==0 then return Duel.IsExistingTarget(c75690317.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，提示选择要变更表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只满足条件的「机巧」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c75690317.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁的操作信息，表示该效果的处理包含变更1张卡（即选择的对象）的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果③（墓地除外变更场上「机巧」怪兽表示形式）的效果处理函数
function c75690317.posop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽的表示形式变更（表侧攻击表示与表侧守备表示互相转换）
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
