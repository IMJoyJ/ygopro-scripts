--VWXYZ－ドラゴン・カタパルトキャノン
-- 效果：
-- 「VW-强击虎」＋「XYZ-神龙炮」
-- 把自己场上的上记卡除外的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：1回合1次，以对方场上1张卡为对象才能发动。那张对方的卡除外。
-- ②：这张卡向对方怪兽攻击宣言时，以那1只攻击对象怪兽为对象才能发动。那只攻击对象怪兽的表示形式变更。这个时候，反转怪兽的效果不发动。
function c84243274.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「VW-强击虎」与「XYZ-神龙炮」
	aux.AddFusionProcCode2(c,58859575,91998119,true,true)
	-- 添加接触融合召唤手续，将自己场上的素材表侧表示除外作为特殊召唤的代价
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 把自己场上的上记卡除外的场合才能从额外卡组特殊召唤（不需要「融合」）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c84243274.splimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以对方场上1张卡为对象才能发动。那张对方的卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84243274,0))  --"除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c84243274.rmtg)
	e3:SetOperation(c84243274.rmop)
	c:RegisterEffect(e3)
	-- ②：这张卡向对方怪兽攻击宣言时，以那1只攻击对象怪兽为对象才能发动。那只攻击对象怪兽的表示形式变更。这个时候，反转怪兽的效果不发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(84243274,1))  --"改变表示形式"
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetTarget(c84243274.postg)
	e4:SetOperation(c84243274.posop)
	c:RegisterEffect(e4)
end
-- 限制该卡只能从额外卡组特殊召唤
function c84243274.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 效果①（除外效果）的靶向目标选择与发动条件判定
function c84243274.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方场上是否存在可以被除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张可以被除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，表明该连锁包含除外操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果①（除外效果）的效果处理
function c84243274.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选定的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 将选定的对象卡片表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果②（改变表示形式）的靶向目标选择与发动条件判定
function c84243274.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取攻击宣言时的攻击对象怪兽
	local bc=Duel.GetAttackTarget()
	if chk==0 then return bc and bc:IsCanChangePosition() and bc:IsCanBeEffectTarget(e) end
	-- 将攻击对象怪兽设定为效果的对象
	Duel.SetTargetCard(bc)
	-- 设置效果处理信息，表明该连锁包含改变表示形式操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,bc,1,0,0)
end
-- 效果②（改变表示形式）的效果处理
function c84243274.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选定的攻击对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 改变目标怪兽的表示形式，且不触发反转怪兽的效果
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,true)
	end
end
