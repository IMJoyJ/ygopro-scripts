--魔剣達士－タルワール・デーモン
-- 效果：
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：场上的这张卡1回合只有1次不会被对方的效果破坏。
-- ③：只要这张卡在怪兽区域存在，双方不能把其他怪兽作为装备魔法卡的效果的对象。
local s,id,o=GetID()
-- 初始化并注册卡的三个效果：①自己场上无怪兽时这张卡可从手卡规则特殊召唤；②场上的这张卡1回合1次不会被对方效果破坏；③此卡在怪兽区存在时，双方不能把其他怪兽作为装备魔法卡效果的对象。
function s.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.hspcon)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡1回合只有1次不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.indct)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，双方不能把其他怪兽作为装备魔法卡的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0x34,0x34)
	e3:SetTarget(s.tglimit)
	e3:SetValue(s.tgoval)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则效果的条件判断：若传入卡为空，则视为规则询问返回真；否则要求此卡控制者场上没有怪兽且主怪兽区域有空位，才允许从手卡特殊召唤。
function s.hspcon(e,c)
	if c==nil then return true end
	-- 检查此卡控制者场上的怪兽数量是否为0，即满足‘自己场上没有怪兽’的条件。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查此卡控制者场上是否存在可用的主怪兽区域空格，确保特殊召唤有位置。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判定破坏耐性是否适用：若使这张卡破坏的原因是效果，且该效果来自对方玩家，则返回1赋予本回合1次不会被对方效果破坏；否则返回0不赋予。
function s.indct(e,re,r,rp)
	if r&REASON_EFFECT>0 and e:GetOwnerPlayer()~=rp then
		return 1
	else return 0 end
end
-- 限制不能成为对象的目标：目标不能是这张卡自身，且必须是怪兽，从而保护‘其他怪兽’。
function s.tglimit(e,c)
	return c~=e:GetHandler() and c:IsType(TYPE_MONSTER)
end
-- 判定对象限制的适用条件：当准备选择对象的效果是装备魔法卡的效果（效果类型为魔法且来源卡为装备类型）时返回真，使该效果不能以其他怪兽为对象。
function s.tgoval(e,re,rp)
	return re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsType(TYPE_EQUIP)
end
