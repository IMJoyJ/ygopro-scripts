--ラッキーパンチ
-- 效果：
-- 1回合1次，对方怪兽的攻击宣言时才能发动。进行3次投掷硬币，3次都是表的场合，自己从卡组抽3张卡。3次都是里的场合，这张卡破坏。此外，场上表侧表示存在的这张卡被破坏的场合，自己失去6000基本分。
function c36378044.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，对方怪兽的攻击宣言时才能发动。进行3次投掷硬币，3次都是表的场合，自己从卡组抽3张卡。3次都是里的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36378044,0))  --"投掷骰子"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY+CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c36378044.atkcon)
	e2:SetTarget(c36378044.atktg)
	e2:SetOperation(c36378044.atkop)
	c:RegisterEffect(e2)
	-- 此外，场上表侧表示存在的这张卡被破坏的场合，自己失去6000基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c36378044.descon)
	e3:SetOperation(c36378044.desop)
	c:RegisterEffect(e3)
end
-- 该函数是效果e2的发动条件：只有在自己不是回合玩家（即对方回合）时，才满足“对方怪兽的攻击宣言时”的发动时机。
function c36378044.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合：若当前回合玩家不是效果控制者tp，则返回真，表示攻击宣言的怪兽是对方怪兽。
	return tp~=Duel.GetTurnPlayer()
end
-- 该函数是效果e2的发动目标/合法性判定：发动时无需取对象；在检查发动合法性时返回true表示允许发动，同时向系统声明本次操作包含抛硬币分类，以便与相关卡互动。
function c36378044.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：声明本连锁包含CATEGORY_COIN（硬币）类别，不指定对象，预计进行3次硬币投掷，投掷玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
-- 该函数是效果e2的效果处理：实际进行3次投硬币，当3次全为表时，从卡组抽3张卡；当3次全为里时，将这张卡自身破坏。
function c36378044.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 进行3次硬币投掷，r1、r2、r3分别为每次结果，1表示表（正面），0表示里（反面）。
	local r1,r2,r3=Duel.TossCoin(tp,3)
	if r1+r2+r3==3 then
		-- 因效果抽卡：控制者从卡组抽3张卡（仅在3次硬币全为表时执行）。
		Duel.Draw(tp,3,REASON_EFFECT)
	elseif r1+r2+r3==0 then
		-- 因效果破坏：将这张卡（效果持有者）破坏（仅在3次硬币全为里时执行）。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 该函数是效果e3的触发条件：本卡被破坏后，检查其破坏前是否位于场上且为表侧表示，以满足“场上表侧表示存在的这张卡被破坏的场合”。
function c36378044.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 该函数是效果e3的效果处理：本卡因满足条件被破坏后，其控制者受到6000基本分伤害，即LP减少6000。
function c36378044.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前效果控制者tp的剩余基本分（LP）数值。
	local lp=Duel.GetLP(tp)
	-- 将控制者tp的基本分设置为原LP减去6000，即失去6000基本分。
	Duel.SetLP(tp,lp-6000)
end
