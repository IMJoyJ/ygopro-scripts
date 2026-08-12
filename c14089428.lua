--ブルーサンダーT45
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，在自己场上把1只「雷电子机衍生物」（机械族·光·4星·攻/守1500）特殊召唤。这衍生物不能为上级召唤而解放。
function c14089428.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，在自己场上把1只「雷电子机衍生物」（机械族·光·4星·攻/守1500）特殊召唤。这衍生物不能为上级召唤而解放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14089428,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测是否为与对方怪兽战斗破坏的场合
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(c14089428.target)
	e1:SetOperation(c14089428.operation)
	c:RegisterEffect(e1)
end
-- 效果处理时的处理目标函数
function c14089428.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：特殊召唤1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置连锁操作信息：召唤1只衍生物token
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- 效果处理时的处理函数
function c14089428.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有足够怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 判断是否可以特殊召唤该衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,14089429,0,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_MACHINE,ATTRIBUTE_LIGHT) then return end
	-- 创建编号为14089429的衍生物token
	local token=Duel.CreateToken(tp,14089429)
	-- 将创建的衍生物特殊召唤到场上
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
