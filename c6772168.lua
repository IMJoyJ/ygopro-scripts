--召喚獣オーケアノス
-- 效果：
-- 「阿莱斯特」怪兽＋暗·水属性怪兽
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要这张卡在主要怪兽区域存在，对方怪兽不能选择其他怪兽作为攻击对象。
-- ②：只要这张卡在额外怪兽区域存在，被送去对方墓地的怪兽不去墓地而除外。
-- ③：把墓地的这张卡除外，以自己场上1只融合怪兽为对象才能发动。这个回合，那只怪兽可以直接攻击。
local s,id,o=GetID()
-- 注册「召唤兽 俄刻阿诺斯」效果的 initial_effect 函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续（「阿莱斯特」怪兽＋暗·水属性怪兽）
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1e1),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_WATER+ATTRIBUTE_DARK),true)
	-- ①：只要这张卡在主要怪兽区域存在，对方怪兽不能选择其他怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetCondition(s.atcon)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在额外怪兽区域存在，被送去对方墓地的怪兽不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetTargetRange(0,LOCATION_DECK)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外，以自己场上1只融合怪兽为对象才能发动。这个回合，那只怪兽可以直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"直接攻击"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	-- 检查当前阶段是否可以进行战斗相关操作的发动条件
	e3:SetCondition(aux.bpcon)
	-- 将墓地的这张卡除外作为发动的cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.attg)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)
end
-- 效果①攻击限制的发动条件（必须存在于主要怪兽区域）
function s.atcon(e)
	return e:GetHandler():GetSequence()<5
end
-- 效果①攻击限制的对象限制（除这张卡以外的自己场上的怪兽）
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 效果②除外重定向的发动条件（必须存在于额外怪兽区域）
function s.rmcon(e)
	return e:GetHandler():GetSequence()>4
end
-- 效果②除外重定向的过滤条件（原本是怪兽卡且属于对方玩家的卡片）
function s.rmtg(e,c)
	-- 检查该卡片持有者是否为对方玩家，且原本是否为怪兽卡
	return c:GetOwner()~=e:GetHandlerPlayer() and aux.DimensionalFissureTarget(e,c)
end
-- 过滤自己场上表侧表示的融合怪兽且当前尚未获得直接攻击效果的卡片条件
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
		and not c:IsHasEffect(EFFECT_DIRECT_ATTACK) and not c:IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK)
end
-- 效果③（赋予直接攻击抗性）的发动准备与检测函数
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 发动时，检查自己场上是否存在可成为本效果对象的表侧表示融合怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示融合怪兽作为本效果的对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果③（赋予直接攻击抗性）的处理函数
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果所指定的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() then
		-- 这个回合，那只怪兽可以直接攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
