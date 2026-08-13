--サイバース・ホワイトハット
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有相同种族的怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡作为连接素材送去墓地的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
function c46104361.initial_effect(c)
	-- ①：自己场上有相同种族的怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。（这个卡名的①的方法的特殊召唤1回合只能有1次。）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46104361,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,46104361+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c46104361.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡作为连接素材送去墓地的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46104361,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c46104361.atkcon)
	e2:SetTarget(c46104361.atktg)
	e2:SetOperation(c46104361.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数：以指定种族为基准，检查场上是否存在表侧表示且种族相同的怪兽；若未指定种族，则以当前怪兽的种族为基准继续搜索其他同种族的表侧表示怪兽，用于判断场上是否满足“相同种族的怪兽2只以上”。
function c46104361.filter(c,tp,race)
	if c:IsFacedown() then return false end
	if not race then
		-- 检索自己场上是否存在1只以上除当前参照卡外、表侧表示且种族与参照卡相同的怪兽，以确认场上已经有2只以上同种族的表侧表示怪兽。
		return Duel.IsExistingMatchingCard(c46104361.filter,tp,LOCATION_MZONE,0,1,c,tp,c:GetRace())
	else
		return c:IsRace(race)
	end
end
-- 特殊召唤规则效果的条件：若c为空则视为规则效果可显示；否则要求自己主要怪兽区有空位，且自己场上有2只以上相同种族的表侧表示怪兽，满足条件时这张卡可以从手卡特殊召唤。
function c46104361.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上主要怪兽区是否存在可用空格，确保这张卡能够从手卡特殊召唤到场上。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示怪兽，并且能找到另一只与它相同种族的表侧表示怪兽，从而满足“自己场上有相同种族的怪兽2只以上存在”的条件。
		and Duel.IsExistingMatchingCard(c46104361.filter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetControler())
end
-- ②效果的发动条件：这张卡作为连接素材被送去墓地，即当前这张卡在墓地，且导致其离开场地的原因是为连接召唤提供素材（REASON_LINK）。
function c46104361.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
-- ②效果的发动目标检查：在满足条件的情况下，需要对方场上有至少1只表侧表示怪兽才能发动，实际处理时对对方场上全部表侧表示怪兽生效。
function c46104361.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）确认对方场上是否存在至少1只表侧表示怪兽，若有才能发动该效果。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果处理：取得对方场上全部表侧表示怪兽，对其中每只怪兽赋予攻击力下降1000的效果，该效果持续到回合结束。
function c46104361.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上全部表侧表示怪兽的集合，作为后续攻击力下降效果的对象。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部怪兽的攻击力直到回合结束时下降1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
