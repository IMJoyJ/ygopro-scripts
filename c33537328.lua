--地縛神 Cusillu
-- 效果：
-- 名字带有「地缚神」的怪兽在场上只能有1只表侧表示存在。场上没有表侧表示场地魔法卡存在的场合这张卡破坏。对方不能选择这张卡作为攻击对象。这张卡可以直接攻击对方玩家。自己场上表侧表示存在的这张卡被战斗破坏的场合，可以作为代替把自己场上存在的1只怪兽解放，对方基本分变成一半数值。
function c33537328.initial_effect(c)
	-- 将这张卡设置为场上只能有1只表侧表示的名字带有「地缚神」的怪兽（同时检查双方怪兽区域）。
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x1021),LOCATION_MZONE)
	-- 场上没有表侧表示场地魔法卡存在的场合这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(c33537328.sdcon)
	c:RegisterEffect(e4)
	-- 对方不能选择这张卡作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	-- 设置“不能成为攻击对象”的判定值：攻击怪兽若不免疫此效果，则不能选择这张卡作为攻击对象。
	e5:SetValue(aux.imval1)
	c:RegisterEffect(e5)
	-- 这张卡可以直接攻击对方玩家。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e6)
	-- 自己场上表侧表示存在的这张卡被战斗破坏的场合，可以作为代替把自己场上存在的1只怪兽解放，对方基本分变成一半数值。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_DESTROY_REPLACE)
	e7:SetTarget(c33537328.desreptg)
	c:RegisterEffect(e7)
end
-- 定义自我破坏效果的发动条件：当场上不存在表侧表示场地魔法卡时，条件成立，该卡会被自我破坏。
function c33537328.sdcon(e)
	-- 检查双方场地魔法区域，若不存在任何表侧表示的场地魔法卡则返回真，从而满足自我破坏条件。
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 定义代替破坏效果的判定目标：当这张卡被战斗破坏且战斗前表示形式不是表侧守备表示，并且自己场上有可解放的怪兽时，才可代替破坏。
function c33537328.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE) and c:GetBattlePosition()~=POS_FACEUP_DEFENSE
		-- 进一步确认自己场上存在至少1只可解放的怪兽（并且排除这张卡自身），若有则条件成立。
		and Duel.CheckReleaseGroupEx(tp,nil,1,REASON_EFFECT,false,c) end
	-- 询问当前玩家是否发动“代替破坏”效果，选择解放自己场上1只怪兽来保住这张卡。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 从自己场上·手卡选择1只可解放的怪兽作为代替解放的代价（不能选择这张卡自身）。
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_EFFECT,false,c)
		-- 解放所选的那只怪兽。
		Duel.Release(g,REASON_EFFECT)
		-- 将对方基本分变更为当前基本分的一半（向上取整）。
		Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
		return true
	else return false end
end
