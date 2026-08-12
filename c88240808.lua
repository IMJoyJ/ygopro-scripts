--霊滅術師 カイクウ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，对方不能把双方墓地的卡除外。
-- ②：这张卡给与对方战斗伤害时，以对方墓地最多2只怪兽为对象才能发动。那些怪兽除外。
function c88240808.initial_effect(c)
	-- ②：这张卡给与对方战斗伤害时，以对方墓地最多2只怪兽为对象才能发动。那些怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88240808,0))  --"选对方墓地2只怪兽除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c88240808.rmcon)
	e1:SetTarget(c88240808.rmtg)
	e1:SetOperation(c88240808.rmop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方不能把双方墓地的卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetTarget(c88240808.rmlimit)
	c:RegisterEffect(e2)
end
-- 限制不能除外的卡片范围为墓地的卡
function c88240808.rmlimit(e,c,p)
	return c:IsLocation(LOCATION_GRAVE)
end
-- 判定受到战斗伤害的玩家为对方玩家
function c88240808.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤对方墓地中可以被除外的怪兽卡
function c88240808.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果②的发动准备与目标选择，确认对方墓地有可除外怪兽并选择1到2只作为对象
function c88240808.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c88240808.filter(chkc) end
	-- 在发动检测阶段，检查对方墓地是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c88240808.filter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家发送选择要除外的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1到2只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c88240808.filter,tp,0,LOCATION_GRAVE,1,2,nil)
	-- 设置效果处理信息，表明此效果将除外对方墓地的指定数量的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果②的效果处理，获取选中的对象并将其除外
function c88240808.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍与效果相关的目标怪兽以表侧表示因效果除外
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
