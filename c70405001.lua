--光と闇の戦士カオス・ソルジャー
-- 效果：
-- 「光与暗的仪式」降临
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以对方场上1张卡为对象才能发动。那张卡除外。
-- ②：这张卡只要在怪兽区域存在，不会被战斗破坏，不受除以这张卡为对象的效果以外的对方发动的效果影响。
-- ③：这张卡战斗破坏对方怪兽时才能发动。这张卡的攻击力上升1500，只再1次可以继续攻击。
local s,id,o=GetID()
-- 初始化函数，注册仪式召唤手续、特殊召唤除外效果、战斗破坏抗性、不受除以自身为对象效果以外的效果影响的抗性以及战斗破坏对方怪兽时的攻击力上升与追加攻击效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 将仪式魔法「光与暗的仪式」记录为此卡的关联卡片
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
	-- ②：不受除以这张卡为对象的效果以外的对方发动的效果影响。
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
	-- 触发条件为：此卡在战斗中破坏了对方怪兽
	e4:SetCondition(aux.bdocon)
	e4:SetOperation(s.atkop)
	e4:SetCountLimit(1,id+o)
	c:RegisterEffect(e4)
end
-- 效果①的发动准备与目标选择检测函数
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方场上是否存在可以被除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示请选择要除外的卡的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上的1张卡作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前处理的操作信息为：除外选择的卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的效果处理执行函数
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择的除外目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 将选择的卡正面表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 抗性效果的过滤函数，用于判断是否过滤满足不受以自身为对象以外效果影响的条件
function s.efilter(e,te)
	if te:GetOwnerPlayer()==e:GetHandlerPlayer() or not te:IsActivated() then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	-- 获取当前连锁中所有的效果对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(e:GetHandler())
end
-- 效果③的效果处理执行函数
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
	-- 只再1次可以继续攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
end
