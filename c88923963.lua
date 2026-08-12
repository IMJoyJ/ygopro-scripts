--聖騎士イヴァン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：让这张卡把「圣剑」装备魔法卡装备的场合才能发动。在自己场上把1只「圣骑士衍生物」（战士族·光·4星·攻/守1000）特殊召唤。这个效果的发动后，直到回合结束时自己不是「圣骑士」怪兽不能特殊召唤。
-- ②：只要这张卡有「圣剑」装备魔法卡装备，这张卡以外的自己场上的「圣骑士」怪兽的攻击力上升500。
function c88923963.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：让这张卡把「圣剑」装备魔法卡装备的场合才能发动。在自己场上把1只「圣骑士衍生物」（战士族·光·4星·攻/守1000）特殊召唤。这个效果的发动后，直到回合结束时自己不是「圣骑士」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88923963,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_EQUIP)
	e1:SetCountLimit(1,88923963)
	e1:SetCondition(c88923963.tkcon)
	e1:SetTarget(c88923963.tktg)
	e1:SetOperation(c88923963.tkop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡有「圣剑」装备魔法卡装备，这张卡以外的自己场上的「圣骑士」怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c88923963.atkcon)
	e2:SetTarget(c88923963.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
end
-- 检查装备给这张卡的卡片中是否存在「圣剑」卡，以此作为效果①的发动条件。
function c88923963.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 效果①的发动准备与目标确认，检查怪兽区域空位数以及是否能特殊召唤衍生物。
function c88923963.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能特殊召唤特定属性、种族、攻守和等级的「圣骑士衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,88923964,0x107a,TYPES_TOKEN_MONSTER,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	-- 设置连锁处理中的操作信息，表示将产生1个衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁处理中的操作信息，表示将进行1次特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果①的效果处理，在场上特殊召唤「圣骑士衍生物」，并适用直到回合结束时自己只能特殊召唤「圣骑士」怪兽的限制。
function c88923963.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查怪兽区域空位以及是否能特殊召唤该衍生物。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,88923964,0x107a,TYPES_TOKEN_MONSTER,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_LIGHT) then
		-- 创建「圣骑士衍生物」的卡片数据。
		local token=Duel.CreateToken(tp,88923964)
		-- 将创建的衍生物以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「圣骑士」怪兽不能特殊召唤。②：只要这张卡有「圣剑」装备魔法卡装备，这张卡以外的自己场上的「圣骑士」怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c88923963.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤非「圣骑士」怪兽的限制效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能特殊召唤「圣骑士」怪兽（过滤非「圣骑士」怪兽）。
function c88923963.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x107a)
end
-- 检查这张卡是否装备有「圣剑」装备魔法卡，以此作为攻击力上升效果的适用条件。
function c88923963.atkcon(e)
	local c=e:GetHandler()
	local eg=c:GetEquipGroup()
	return #eg>0 and eg:IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 过滤出这张卡以外的自己场上的「圣骑士」怪兽，作为攻击力上升效果的影响对象。
function c88923963.atktg(e,c)
	return c:IsSetCard(0x107a) and c~=e:GetHandler()
end
