--光と闇の戦士カオス・ソルジャー
-- 效果：
-- 「光与暗的仪式」降临
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以对方场上1张卡为对象才能发动。那张卡除外。
-- ②：这张卡只要在怪兽区域存在，不会被战斗破坏，不受除以这张卡为对象的效果以外的对方发动的效果影响。
-- ③：这张卡战斗破坏对方怪兽时才能发动。这张卡的攻击力上升1500，只再1次可以继续攻击。
local s,id,o=GetID()
-- 初始化效果注册
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 将「光与暗的仪式」加入该卡的关联卡片列表
	aux.AddCodeList(c,33599853)
	-- ①：这张卡特殊召唤的场合，以对方场上1张卡为对象才能发动。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外效果"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡只要在怪兽区域存在，不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 不受除以这张卡为对象的效果以外的对方发动的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	-- ③：这张卡战斗破坏对方怪兽时才能发动。这张卡的攻击力上升1500，只再1次可以继续攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"上升攻击力"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果发动的条件为自身在战斗中破坏了对方怪兽
	e4:SetCondition(aux.bdocon)
	e4:SetOperation(s.atkop)
	e4:SetCountLimit(1,id+o)
	c:RegisterEffect(e4)
end
-- ①号效果的目标选择与发动检测
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 在效果发动时，检测对方场上是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向发动效果的玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张可以除外的卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，声明该效果包含除外1张目标卡的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①号效果的效果处理函数（除外目标卡片）
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 将目标卡片表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤函数，用于判定自身是否不受对方发动的非取对象效果的影响
function s.efilter(e,te)
	if te:GetOwnerPlayer()==e:GetHandlerPlayer() or not te:IsActivated() then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	-- 获取当前连锁中所有被选为效果对象卡片的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(e:GetHandler())
end
-- ③号效果的效果处理函数（攻击力上升1500，并获得连击机会）
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or not c:IsFaceup() then return end
	-- 这张卡的攻击力上升1500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	-- 使自身可以再进行1次攻击
	Duel.ChainAttack()
end
