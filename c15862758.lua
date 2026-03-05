--CiNo.1000 夢幻虚光神ヌメロニアス・ヌメロニア
-- 效果：
-- 13星怪兽×5
-- ①：「混沌No.1000 梦幻虚神 原数天灵」的效果特殊召唤的这张卡攻击力·守备力只在对方回合内上升100000，从特殊召唤的下个回合起以下适用。
-- ●可以攻击的对方怪兽必须向这张卡作出攻击。
-- ●这张卡没有进行战斗的对方回合结束时，自己决斗胜利。
-- ②：对方怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。那次攻击无效，自己基本分回复那个攻击力的数值。
function c15862758.initial_effect(c)
	-- 添加XYZ召唤手续，使用13星怪兽叠放5个，满足条件的怪兽可作为叠放素材
	aux.AddXyzProcedure(c,nil,13,5)
	c:EnableReviveLimit()
	-- 「混沌No.1000 梦幻虚神 原数天灵」的效果特殊召唤的这张卡攻击力·守备力只在对方回合内上升100000，从特殊召唤的下个回合起以下适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c15862758.condition)
	e1:SetOperation(c15862758.operation)
	c:RegisterEffect(e1)
	-- 对方怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。那次攻击无效，自己基本分回复那个攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15862758,0))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c15862758.nacon)
	e2:SetCost(c15862758.nacost)
	e2:SetTarget(c15862758.natg)
	e2:SetOperation(c15862758.naop)
	c:RegisterEffect(e2)
end
-- 设置该卡为1000系列XYZ怪兽
aux.xyz_number[15862758]=1000
-- 判断是否由「混沌No.1000 梦幻虚神 原数天灵」的效果特殊召唤
function c15862758.condition(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsCode(89477759)
end
-- 特殊召唤成功后，为该卡添加攻击力和守备力提升效果，并设置必须攻击效果和胜利条件
function c15862758.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local turn=c:GetTurnID()
	-- 为该卡添加攻击力提升效果，仅在对方回合生效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c15862758.atkcon)
	e1:SetValue(100000)
	e1:SetReset(RESET_EVENT+RESETS_WITHOUT_TEMP_REMOVE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- 设置必须攻击效果，使对方怪兽必须攻击该卡
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c15862758.effcon)
	e2:SetLabel(turn)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(c15862758.atklimit)
	c:RegisterEffect(e3)
	-- 回合结束时，若该卡未进行战斗则自己决斗胜利
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_TURN_END)
	e4:SetCondition(c15862758.wincon)
	e4:SetOperation(c15862758.winop)
	e4:SetLabel(turn)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e4)
end
-- 判断是否为对方回合
function c15862758.atkcon(e)
	-- 当前回合玩家为对方时返回true
	return Duel.GetTurnPlayer()==1-e:GetHandlerPlayer()
end
-- 判断是否为特殊召唤后的下一个回合
function c15862758.effcon(e)
	-- 当前回合数大于等于特殊召唤回合数+1时返回true
	return Duel.GetTurnCount()>=e:GetLabel()+1
end
-- 设置必须攻击的怪兽为该卡本身
function c15862758.atklimit(e,c)
	return c==e:GetHandler()
end
-- 判断是否为对方回合且该卡未参与战斗
function c15862758.wincon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为对方且该卡未参与战斗时返回true
	return Duel.GetTurnPlayer()==1-tp and e:GetHandler():GetBattledGroupCount()==0 and c15862758.effcon(e)
end
-- 令当前玩家以指定理由决斗胜利
function c15862758.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_NUMERONIUS_NUMERONIA=0x21
	-- 令当前玩家以指定理由决斗胜利
	Duel.Win(tp,WIN_REASON_NUMERONIUS_NUMERONIA)
end
-- 判断攻击方是否为对方
function c15862758.nacon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击方控制者为对方时返回true
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 支付1个超量素材作为代价
function c15862758.nacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果处理时的回复信息
function c15862758.natg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击的怪兽
	local b=Duel.GetAttacker()
	if chk==0 then return b and b:IsRelateToBattle() and b:IsFaceup() end
	-- 设置操作信息，表示将回复对方攻击力数值的LP
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,b:GetAttack())
end
-- 处理攻击无效并回复LP
function c15862758.naop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的怪兽
	local b=Duel.GetAttacker()
	-- 若攻击被无效且攻击怪兽有效则继续处理
	if Duel.NegateAttack() and b and b:IsRelateToBattle() and b:IsFaceup() then
		-- 令当前玩家回复攻击怪兽攻击力数值的LP
		Duel.Recover(tp,b:GetAttack(),REASON_EFFECT)
	end
end
