--H－C クレイヴソリッシュ
-- 效果：
-- 战士族4星怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方不能选择其他怪兽作为攻击对象。
-- ②：把基本分支付到变成500基本分才能发动。这个回合的战斗阶段开始时，选自己场上1只怪兽把攻击力变成2倍。
-- ③：对方怪兽进行战斗的攻击宣言时，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升那只怪兽的攻击力数值。
local s,id,o=GetID()
-- 初始化卡片效果，注册XYZ召唤手续、①的攻击限制效果、②的支付生命值翻倍攻击力效果、③的取除素材加攻效果。
function c97453744.initial_effect(c)
	-- 设置XYZ召唤手续：战士族4星怪兽×2。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),4,2)
	c:EnableReviveLimit()
	-- ①：对方不能选择其他怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c97453744.atklimit)
	c:RegisterEffect(e1)
	-- ②：把基本分支付到变成500基本分才能发动。这个回合的战斗阶段开始时，选自己场上1只怪兽把攻击力变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97453744,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,97453744)
	e2:SetCondition(c97453744.dbcon)
	e2:SetCost(c97453744.dbcost)
	e2:SetOperation(c97453744.dbop)
	c:RegisterEffect(e2)
	-- ③：对方怪兽进行战斗的攻击宣言时，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升那只怪兽的攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(97453744,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,97453744+o)
	e3:SetCondition(c97453744.upcon)
	e3:SetCost(c97453744.upcost)
	e3:SetTarget(c97453744.uptg)
	e3:SetOperation(c97453744.upop)
	c:RegisterEffect(e3)
end
-- 攻击限制的目标过滤函数，使对方不能选择除这张卡以外的怪兽作为攻击对象。
function c97453744.atklimit(e,c)
	return c~=e:GetHandler()
end
-- 效果②的发动条件：当前回合玩家能够进入战斗阶段。
function c97453744.dbcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能够进入战斗阶段。
	return Duel.IsAbleToEnterBP()
end
-- 效果②的支付代价：将基本分支付到变成500。
function c97453744.dbcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家当前的生命值。
	local lp=Duel.GetLP(tp)
	-- 检查玩家是否能够支付“当前生命值减去500”的生命值代价。
	if chk==0 then return Duel.CheckLPCost(tp,lp-500) end
	-- 扣除玩家“当前生命值减去500”的生命值，使其生命值变为500。
	Duel.PayLPCost(tp,lp-500)
end
-- 效果②的效果处理：注册一个在回合结束前、于战斗阶段开始时触发的延迟效果。
function c97453744.dbop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的战斗阶段开始时，选自己场上1只怪兽把攻击力变成2倍。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetCountLimit(1)
	e1:SetOperation(c97453744.sop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该延迟触发效果注册给发动效果的玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 战斗阶段开始时的具体处理：选择自己场上1只表侧表示怪兽，使其攻击力变成2倍。
function c97453744.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要将攻击力变成2倍的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(97453744,2))  --"请选择要把攻击力变成2倍的怪兽"
		local sg=g:Select(tp,1,1,nil)
		-- 闪烁显示被选择的怪兽。
		Duel.HintSelection(sg)
		local tc=sg:GetFirst()
		-- 把攻击力变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 效果③的发动条件：对方怪兽进行战斗的攻击宣言时。
function c97453744.upcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方进行战斗的怪兽。
	local tc=Duel.GetBattleMonster(1-tp)
	return tc and tc:IsRelateToBattle()
end
-- 效果③的代价处理：取除这张卡的1个超量素材。
function c97453744.upcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果③的对象选择：以对方场上1只表侧表示且攻击力不为0的怪兽为对象。
function c97453744.uptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查是否为合法的效果对象（对方场上表侧表示且攻击力不为0的怪兽）。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and aux.nzatk(chkc) end
	-- 检查对方场上是否存在至少1只表侧表示且攻击力不为0的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择作为效果对象的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只表侧表示且攻击力不为0的怪兽作为效果对象。
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果③的效果处理：使这张卡的攻击力直到回合结束时上升作为对象的怪兽的攻击力数值。
function c97453744.upop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel:GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这张卡的攻击力直到回合结束时上升那只怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
