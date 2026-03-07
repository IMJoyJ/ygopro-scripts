--地縛神 Cusillu
-- 效果：
-- 名字带有「地缚神」的怪兽在场上只能有1只表侧表示存在。场上没有表侧表示场地魔法卡存在的场合这张卡破坏。对方不能选择这张卡作为攻击对象。这张卡可以直接攻击对方玩家。自己场上表侧表示存在的这张卡被战斗破坏的场合，可以作为代替把自己场上存在的1只怪兽解放，对方基本分变成一半数值。
function c33537328.initial_effect(c)
	-- 设置场上只能存在1只名字带有「地缚神」的怪兽
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x1021),LOCATION_MZONE)
	-- 场上没有表侧表示场地魔法卡存在的场合这张卡破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(c33537328.sdcon)
	c:RegisterEffect(e4)
	-- 对方不能选择这张卡作为攻击对象
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	-- 不能成为攻击对象的过滤函数
	e5:SetValue(aux.imval1)
	c:RegisterEffect(e5)
	-- 这张卡可以直接攻击对方玩家
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e6)
	-- 自己场上表侧表示存在的这张卡被战斗破坏的场合，可以作为代替把自己场上存在的1只怪兽解放，对方基本分变成一半数值
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_DESTROY_REPLACE)
	e7:SetTarget(c33537328.desreptg)
	c:RegisterEffect(e7)
end
-- 检查场上是否没有表侧表示的场地魔法卡
function c33537328.sdcon(e)
	-- 场上没有表侧表示场地魔法卡时触发效果
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 判断是否满足代替破坏的条件
function c33537328.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE) and c:GetBattlePosition()~=POS_FACEUP_DEFENSE
		-- 检查是否满足解放怪兽的条件
		and Duel.CheckReleaseGroupEx(tp,nil,1,REASON_EFFECT,false,c) end
	-- 询问玩家是否发动效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 选择1只可解放的怪兽
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_EFFECT,false,c)
		-- 解放选中的怪兽
		Duel.Release(g,REASON_EFFECT)
		-- 将对方基本分设为一半
		Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
		return true
	else return false end
end
