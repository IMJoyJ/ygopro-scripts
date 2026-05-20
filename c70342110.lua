--次元幽閉
-- 效果：
-- 对方怪兽的攻击宣言时，选择1只攻击怪兽才能发动。选择的攻击怪兽从游戏中除外。
function c70342110.initial_effect(c)
	-- 对方怪兽的攻击宣言时，选择1只攻击怪兽才能发动。选择的攻击怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c70342110.condition)
	e1:SetTarget(c70342110.target)
	e1:SetOperation(c70342110.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件函数
function c70342110.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方（即自身不是回合玩家）
	return tp~=Duel.GetTurnPlayer()
end
-- 定义效果的发动目标选择与检测函数
function c70342110.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击宣言的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsAbleToRemove() and tg:IsCanBeEffectTarget(e) end
	-- 将该攻击怪兽设为效果的对象
	Duel.SetTargetCard(tg)
	-- 设置操作信息，表明此效果包含将1张目标卡除外的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,1,0,0)
end
-- 定义效果处理的执行函数
function c70342110.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
		-- 将目标怪兽以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
