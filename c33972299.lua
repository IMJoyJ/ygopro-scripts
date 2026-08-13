--ジオ・ジェネクス
-- 效果：
-- 「次世代控制员」＋调整以外的地属性怪兽1只以上
-- ①：1回合1次，自己场上有4星以下的「次世代」怪兽存在的场合才能发动。这张卡的原本攻击力和原本守备力直到回合结束时交换。这个效果直到变成自己场上没有4星以下的「次世代」怪兽存在为止适用。
function c33972299.initial_effect(c)
	-- 为这张卡声明其同调素材卡「次世代控制员」的卡号68505803，将其加入素材卡名列表，用于辅助召唤手续及相关的检索判定。
	aux.AddMaterialCodeList(c,68505803)
	-- 添加同调召唤手续：调整必须是「次世代控制员」，调整以外必须是地属性怪兽，且至少1只，满足「次世代控制员」＋调整以外的地属性怪兽1只以上的召唤条件。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,68505803),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_EARTH),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己场上有4星以下的「次世代」怪兽存在的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33972299,0))  --"攻守交换"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c33972299.condition)
	e1:SetOperation(c33972299.operation)
	c:RegisterEffect(e1)
	-- 这张卡的原本攻击力和原本守备力直到回合结束时交换。这个效果直到变成自己场上没有4星以下的「次世代」怪兽存在为止适用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SWAP_BASE_AD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c33972299.valcon)
	c:RegisterEffect(e2)
end
-- 作为攻守交换效果的持续条件：仅当此卡在本回合发动过①效果（持有标识33972299）且自己场上存在4星以下的表侧「次世代」怪兽时，原本攻守交换才适用。
function c33972299.valcon(e)
	return e:GetHandler():GetFlagEffect(33972299)~=0
		-- 检查自己场上是否存在至少1只表侧表示、等级4以下、属于「次世代」系列的怪兽，以满足“场上存在4星以下的「次世代」怪兽”的持续适用条件。
		and Duel.IsExistingMatchingCard(c33972299.cfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 定义过滤条件：等级4以下、表侧表示、且属于「次世代」系列的怪兽（即4星以下的「次世代」怪兽）。
function c33972299.cfilter(c)
	return c:IsLevelBelow(4) and c:IsFaceup() and c:IsSetCard(0x2)
end
-- ①效果的发动条件：自己场上存在至少1只满足过滤条件的4星以下表侧「次世代」怪兽。
function c33972299.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己场上是否存在至少1只满足条件的怪兽；存在则效果可以发动。
	return Duel.IsExistingMatchingCard(c33972299.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动①效果处理时，给这张卡注册标识33972299，该标识在结束阶段或离场等标准重置时清除；用于标记本回合已发动过攻守交换，使e2的原本攻守交换在满足条件下生效。
function c33972299.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		c:RegisterFlagEffect(33972299,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
