--ブルーサンダーT45
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，在自己场上把1只「雷电子机衍生物」（机械族·光·4星·攻/守1500）特殊召唤。这衍生物不能为上级召唤而解放。
function c14089428.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，在自己场上把1只「雷电子机衍生物」（机械族·光·4星·攻/守1500）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14089428,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果的发动条件：本卡与对方怪兽进行战斗并将其战斗破坏。
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(c14089428.target)
	e1:SetOperation(c14089428.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的判定：本效果不取对象，且满足条件即可发动；同时向系统登记本次处理会进行特殊召唤并生成衍生物。
function c14089428.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次效果将特殊召唤1只怪兽（具体怪兽在处理时确定，不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 登记操作信息：本次效果将生成1只衍生物，用于配合衍生物相关判定。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- 效果处理流程：先确认我方主要怪兽区有空位、且玩家可以特殊召唤符合参数的衍生物；满足条件则生成衍生物并特殊召唤，再为衍动物附加不能为上级召唤解放的效果。
function c14089428.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方主要怪兽区域是否存在至少1个可用空格，无空格则不能特殊召唤衍生物。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 若玩家因任何限制无法特殊召唤该衍生物（机械族·光·4星·攻/守1500），则效果处理失败并结束。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,14089429,0,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_MACHINE,ATTRIBUTE_LIGHT) then return end
	-- 生成1只「雷电子机衍生物」（卡号14089429），由当前玩家tp持有。
	local token=Duel.CreateToken(tp,14089429)
	-- 将该衍生物以表侧表示特殊召唤到玩家tp的怪兽区域。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	-- 这衍生物不能为上级召唤而解放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e1)
end
