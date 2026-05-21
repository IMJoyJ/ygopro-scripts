--地雷蜘蛛
-- 效果：
-- 这张卡攻击宣言时，猜硬币的正反。猜中的话就继续攻击。猜不中的话自己的基本分减半再攻击。
function c94773007.initial_effect(c)
	-- 这张卡攻击宣言时，猜硬币的正反。猜中的话就继续攻击。猜不中的话自己的基本分减半再攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94773007,0))  --"投掷硬币"
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(c94773007.attg)
	e1:SetOperation(c94773007.atop)
	c:RegisterEffect(e1)
end
-- 定义攻击宣言时触发效果的Target（发动准备）函数
function c94773007.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理中包含投掷1次硬币的操作信息
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 定义攻击宣言时触发效果的Operation（效果处理）函数
function c94773007.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 在系统提示栏显示请选择硬币正反面的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让发动效果的玩家宣言硬币的正反面
	local opt=Duel.AnnounceCoin(tp)
	-- 由发动效果的玩家投掷1次硬币
	local coin=Duel.TossCoin(tp,1)
	if opt==coin then
		-- 将发动效果的玩家的当前基本分减半（向上取整）
		Duel.SetLP(tp,math.ceil(Duel.GetLP(tp)/2))
	end
end
