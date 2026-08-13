--No.48 シャドー・リッチ
-- 效果：
-- 3星怪兽×2
-- ①：对方回合1次，把这张卡1个超量素材取除才能发动。在自己场上把1只「幻影衍生物」（恶魔族·暗·1星·攻/守500）特殊召唤。
-- ②：这张卡的攻击力上升自己场上的「幻影衍生物」数量×500。
-- ③：只要自己场上有「幻影衍生物」存在，对方不能选择这张卡作为攻击对象。
function c1426714.initial_effect(c)
	-- 为「No.48 暗影巫妖」添加XYZ召唤手续：将任意3星怪兽2只叠放来进行超量召唤。
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
	-- 设置该效果的判定值为aux.imval1（即对方怪兽若不免疫此效果，则不能选择这张卡作为攻击对象），从而使③效果实际生效。
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
-- 登记这张卡的No.编号为48，用于处理No.相关效果或显示信息。
aux.xyz_number[1426714]=48
-- 效果①的发动条件函数：当前回合玩家不是这张卡的控制者，即只能在对方回合发动。
function c1426714.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回“当前回合玩家≠这张卡的控制者”，以此判断是否处于对方回合。
	return Duel.GetTurnPlayer()~=tp
end
-- 效果①的代价函数：发动时检查并取除这张卡的1个超量素材作为代价。
function c1426714.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的发动目标函数：检查自己场上怪兽区域有空位，且能够特殊召唤「幻影衍生物」。
function c1426714.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判断自己场上是否有空闲的怪兽区域（用于特殊召唤衍生物）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时判断自己能否特殊召唤出「幻影衍生物」（卡号1426715，恶魔族·暗·1星·攻/守500）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,1426715,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置操作信息：本次效果将特殊召唤1只衍生物（CATEGORY_TOKEN）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次效果包含1次特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果①的特殊召唤处理：若处理时仍能满足条件，则在自己场上特殊召唤「幻影衍生物」。
function c1426714.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时先确认自己场上仍有空余怪兽区，否则无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 若此时已不能特殊召唤衍生物，则直接终止处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,1426715,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 创建1只「幻影衍生物」（token）。
	local token=Duel.CreateToken(tp,1426715)
	-- 将衍生物以表侧表示特殊召唤到这张卡的控制者（自己）场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果③的适用条件函数：只要自己场上有「幻影衍生物」存在，则条件成立。
function c1426714.atkcon(e)
	-- 检查自己场上是否存在「幻影衍生物」。
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,1426715)
end
-- 效果②的攻击力上升值函数：根据自己场上「幻影衍生物」数量计算上升数值。
function c1426714.atkval(e,c)
	-- 返回自己场上「幻影衍生物」数量×500，作为这张卡的攻击力上升值。
	return Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_ONFIELD,0,nil,1426715)*500
end
