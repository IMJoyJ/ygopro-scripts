--戦華の徳－劉玄
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己场上有其他的「战华」怪兽存在，对方不能选择这张卡作为攻击对象。
-- ②：对方场上的怪兽数量比自己场上的怪兽多的场合，从自己的手卡·场上把1张卡送去墓地才能发动。从卡组把「战华之德-刘玄」以外的1只「战华」怪兽特殊召唤。
-- ③：这张卡以外的自己的「战华」怪兽进行战斗的攻击宣言时才能发动。自己从卡组抽1张。
function c40428851.initial_effect(c)
	-- ①：只要自己场上有其他的「战华」怪兽存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c40428851.atcon)
	-- 效果作用：使该卡不能成为攻击对象
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- ②：对方场上的怪兽数量比自己场上的怪兽多的场合，从自己的手卡·场上把1张卡送去墓地才能发动。从卡组把「战华之德-刘玄」以外的1只「战华」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40428851,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,40428851)
	e2:SetCondition(c40428851.spcon)
	e2:SetCost(c40428851.spcost)
	e2:SetTarget(c40428851.sptg)
	e2:SetOperation(c40428851.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡以外的自己的「战华」怪兽进行战斗的攻击宣言时才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40428851,1))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,40428852)
	e3:SetCondition(c40428851.drcon)
	e3:SetTarget(c40428851.drtg)
	e3:SetOperation(c40428851.drop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断场上是否存在其他「战华」怪兽
function c40428851.atfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- 条件函数：判断自己场上有其他「战华」怪兽
function c40428851.atcon(e)
	-- 检查自己场上是否存在其他「战华」怪兽
	return Duel.IsExistingMatchingCard(c40428851.atfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤函数：判断卡是否为「战华」怪兽且不是刘玄本身
function c40428851.spfilter(c,e,tp)
	return c:IsSetCard(0x137) and c:IsType(TYPE_MONSTER) and not c:IsCode(40428851) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 条件函数：判断对方场上的怪兽数量比自己多
function c40428851.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较双方场上怪兽数量
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
end
-- 过滤函数：判断卡是否能作为cost送去墓地且有可用怪兽区
function c40428851.costfilter(c,tp)
	-- 判断卡是否能作为cost送去墓地且有可用怪兽区
	return Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGraveAsCost()
end
-- 效果处理：选择并送入墓地一张卡作为cost
function c40428851.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的卡可作为cost
	if chk==0 then return Duel.IsExistingMatchingCard(c40428851.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡作为cost
	local g=Duel.SelectMatchingCard(tp,c40428851.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果处理：检索满足条件的「战华」怪兽
function c40428851.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「战华」怪兽可特殊召唤
	if chk==0 then return Duel.IsExistingMatchingCard(c40428851.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：特殊召唤满足条件的「战华」怪兽
function c40428851.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c40428851.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 条件函数：判断攻击的怪兽是否为自己的「战华」怪兽
function c40428851.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击怪兽
	local ac=Duel.GetAttacker()
	-- 获取攻击目标
	local tc=Duel.GetAttackTarget()
	if not ac:IsControler(tp) then ac,tc=tc,ac end
	return ac and ac:IsControler(tp) and ac:IsFaceup() and ac:IsSetCard(0x137) and ac~=c
end
-- 效果处理：准备抽卡
function c40428851.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量
	Duel.SetTargetParam(1)
	-- 设置抽卡的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：执行抽卡
function c40428851.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
