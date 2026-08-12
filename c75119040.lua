--ティンダングル・アキュート・ケルベロス
-- 效果：
-- 「廷达魔三角」怪兽3只
-- ①：自己墓地有包含「廷达魔三角之底边守卫者」的「廷达魔三角」怪兽3种类以上存在的场合，这张卡的攻击力上升3000。
-- ②：这张卡的攻击力上升这张卡所连接区的「廷达魔三角」怪兽数量×500。
-- ③：这张卡攻击宣言的战斗阶段结束时才能发动。在自己场上把1只「廷达魔三角衍生物」（恶魔族·暗·1星·攻/守0）特殊召唤。
function c75119040.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续，需要3只「廷达魔三角」怪兽作为素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x10b),3,3)
	-- ①：自己墓地有包含「廷达魔三角之底边守卫者」的「廷达魔三角」怪兽3种类以上存在的场合，这张卡的攻击力上升3000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c75119040.atkcon)
	e1:SetValue(3000)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升这张卡所连接区的「廷达魔三角」怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c75119040.atkval)
	c:RegisterEffect(e2)
	-- ③：这张卡攻击宣言的战斗阶段结束时才能发动。在自己场上把1只「廷达魔三角衍生物」（恶魔族·暗·1星·攻/守0）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75119040,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c75119040.spcon)
	e3:SetTarget(c75119040.sptg)
	e3:SetOperation(c75119040.spop)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中「廷达魔三角」怪兽卡的条件。
function c75119040.cfilter(c)
	return c:IsSetCard(0x10b) and c:IsType(TYPE_MONSTER)
end
-- 检查自己墓地是否存在包含「廷达魔三角之底边守卫者」在内的3种以上「廷达魔三角」怪兽。
function c75119040.atkcon(e)
	-- 获取自己墓地中所有的「廷达魔三角」怪兽。
	local g=Duel.GetMatchingGroup(c75119040.cfilter,e:GetHandler():GetControler(),LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)>=3 and g:IsExists(Card.IsCode,1,nil,94365540)
end
-- 过滤场上表侧表示的「廷达魔三角」怪兽。
function c75119040.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10b)
end
-- 计算并返回这张卡所连接区的「廷达魔三角」怪兽数量乘以500的攻击力上升值。
function c75119040.atkval(e,c)
	return c:GetLinkedGroup():FilterCount(c75119040.atkfilter,nil)*500
end
-- 检查这张卡在当前回合是否进行过攻击宣言。
function c75119040.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackAnnouncedCount()>0
end
-- 效果③特殊召唤衍生物的发动准备与合法性检测。
function c75119040.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空余怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能够特殊召唤指定的「廷达魔三角衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,75119041,0x10b,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置连锁处理的操作信息，表示该效果包含产生1只衍生物的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁处理的操作信息，表示该效果包含特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果③特殊召唤衍生物的具体效果处理。
function c75119040.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有空余的怪兽区域则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时，若玩家无法特殊召唤该衍生物则不处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,75119041,0x10b,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 在后台创建「廷达魔三角衍生物」的卡片数据。
	local token=Duel.CreateToken(tp,75119041)
	-- 将创建的衍生物以表侧表示特殊召唤到发动效果的玩家场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
