--ジオ・ジェネクス
-- 效果：
-- 「次世代控制员」＋调整以外的地属性怪兽1只以上
-- ①：1回合1次，自己场上有4星以下的「次世代」怪兽存在的场合才能发动。这张卡的原本攻击力和原本守备力直到回合结束时交换。这个效果直到变成自己场上没有4星以下的「次世代」怪兽存在为止适用。
function c33972299.initial_effect(c)
	-- 为该怪兽添加融合召唤所需的素材代码列表，允许使用代码为68505803的卡作为素材
	aux.AddMaterialCodeList(c,68505803)
	-- 设置该怪兽的同调召唤手续，要求1只调整（满足Card.IsCode过滤条件）和1只地属性怪兽（满足Card.IsAttribute过滤条件）
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,68505803),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_EARTH),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己场上有4星以下的「次世代」怪兽存在的场合才能发动。这张卡的原本攻击力和原本守备力直到回合结束时交换。这个效果直到变成自己场上没有4星以下的「次世代」怪兽存在为止适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33972299,0))  --"攻守交换"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c33972299.condition)
	e1:SetOperation(c33972299.operation)
	c:RegisterEffect(e1)
	-- 这个效果直到变成自己场上没有4星以下的「次世代」怪兽存在为止适用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SWAP_BASE_AD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c33972299.valcon)
	c:RegisterEffect(e2)
end
-- 判断是否满足效果适用条件，即该怪兽是否已注册flag效果且自己场上存在满足条件的怪兽
function c33972299.valcon(e)
	return e:GetHandler():GetFlagEffect(33972299)~=0
		-- 检查自己场上是否存在满足条件的怪兽，即4星以下的「次世代」怪兽
		and Duel.IsExistingMatchingCard(c33972299.cfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 定义用于筛选满足条件的怪兽的过滤函数，即等级为4星以下、表侧表示、属于「次世代」卡组的怪兽
function c33972299.cfilter(c)
	return c:IsLevelBelow(4) and c:IsFaceup() and c:IsSetCard(0x2)
end
-- 判断是否满足效果发动条件，即自己场上是否存在满足条件的怪兽
function c33972299.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足条件的怪兽，即4星以下的「次世代」怪兽
	return Duel.IsExistingMatchingCard(c33972299.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动效果时注册flag效果，用于标记该效果已发动并在回合结束时重置
function c33972299.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		c:RegisterFlagEffect(33972299,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
