--No.48 シャドー・リッチ
-- 效果：
-- 3星怪兽×2
-- ①：对方回合1次，把这张卡1个超量素材取除才能发动。在自己场上把1只「幻影衍生物」（恶魔族·暗·1星·攻/守500）特殊召唤。
-- ②：这张卡的攻击力上升自己场上的「幻影衍生物」数量×500。
-- ③：只要自己场上有「幻影衍生物」存在，对方不能选择这张卡作为攻击对象。
function c1426714.initial_effect(c)
	-- 为卡片添加等级为3、需要2只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：对方回合1次，把这张卡1个超量素材取除才能发动。在自己场上把1只「幻影衍生物」（恶魔族·暗·1星·攻/守500）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1426714,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_BATTLE_START+TIMING_END_PHASE)
	e1:SetCondition(c1426714.spcon)
	e1:SetCost(c1426714.spcost)
	e1:SetTarget(c1426714.sptg)
	e1:SetOperation(c1426714.spop)
	c:RegisterEffect(e1)
	-- ③：只要自己场上有「幻影衍生物」存在，对方不能选择这张卡作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetCondition(c1426714.atkcon)
	-- 设置效果值为过滤函数aux.imval1，用于判断是否不能成为攻击对象
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	-- ②：这张卡的攻击力上升自己场上的「幻影衍生物」数量×500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c1426714.atkval)
	c:RegisterEffect(e3)
end
-- 设置该卡的XYZ编号为48
aux.xyz_number[1426714]=48
-- 效果发动的条件判断函数，判断是否为对方回合
function c1426714.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回值为true表示当前回合不是发动玩家的回合，即为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 效果发动的费用支付函数，检查并移除1个超量素材作为代价
function c1426714.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动的宣言函数，判断是否可以发动此效果
function c1426714.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查发动玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,1426715,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置连锁操作信息，表示将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁操作信息，表示将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果发动的处理函数，执行特殊召唤衍生物的操作
function c1426714.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动玩家场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查发动玩家是否可以特殊召唤指定的衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,1426715,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 创建一个编号为1426715的衍生物卡片
	local token=Duel.CreateToken(tp,1426715)
	-- 将创建好的衍生物特殊召唤到场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断是否场上有「幻影衍生物」存在的条件函数
function c1426714.atkcon(e)
	-- 检查发动玩家场上是否存在编号为1426715的衍生物
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,1426715)
end
-- 计算攻击力增加数值的函数
function c1426714.atkval(e,c)
	-- 计算场上「幻影衍生物」数量并乘以500作为攻击力增加量
	return Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_ONFIELD,0,nil,1426715)*500
end
