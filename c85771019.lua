--堕天使アスモディウス
-- 效果：
-- 这张卡不能作从卡组·墓地的特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。从卡组把1只天使族怪兽送去墓地。
-- ②：自己场上的这张卡被破坏送去墓地的场合发动。在自己场上把1只「阿斯蒙衍生物」（天使族·暗·5星·攻1800/守1300）和1只「蒂斯衍生物」（天使族·暗·3星·攻/守1200）特殊召唤。「阿斯蒙衍生物」不会被效果破坏。「蒂斯衍生物」不会被战斗破坏。
function c85771019.initial_effect(c)
	-- 这张卡不能作从卡组·墓地的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_DECK+LOCATION_GRAVE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤的条件为始终返回假值（即不能特殊召唤）
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。从卡组把1只天使族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85771019,0))  --"把1只天使族怪兽送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c85771019.tgtg)
	e2:SetOperation(c85771019.tgop)
	c:RegisterEffect(e2)
	-- ②：自己场上的这张卡被破坏送去墓地的场合发动。在自己场上把1只「阿斯蒙衍生物」（天使族·暗·5星·攻1800/守1300）和1只「蒂斯衍生物」（天使族·暗·3星·攻/守1200）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85771019,1))  --"特殊召唤衍生物"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c85771019.spcon)
	e3:SetTarget(c85771019.sptg)
	e3:SetOperation(c85771019.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组中可以送去墓地的天使族怪兽
function c85771019.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FAIRY) and c:IsAbleToGrave()
end
-- 效果①的发动准备与检测（检查卡组是否存在天使族怪兽，并设置送去墓地的操作信息）
function c85771019.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只满足过滤条件的天使族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85771019.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息：从自己卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：从卡组选择1只天使族怪兽送去墓地
function c85771019.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1只满足过滤条件的天使族怪兽
	local g=Duel.SelectMatchingCard(tp,c85771019.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果②的发动条件：此卡在场上被破坏并送去墓地
function c85771019.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)~=0 and e:GetHandler():IsPreviousControler(tp)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果②的发动准备（设置特殊召唤和衍生物的操作信息）
function c85771019.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息：产生2个衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置连锁的操作信息：特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果②的处理：在自己场上特殊召唤「阿斯蒙衍生物」和「蒂斯衍生物」，并赋予它们抗性
function c85771019.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上的怪兽区域空位数是否小于2，若小于2则无法处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 检查玩家是否可以特殊召唤「阿斯蒙衍生物」（天使族·暗·5星·攻1800/守1300）
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,85771020,0,TYPES_TOKEN_MONSTER,1800,1300,5,RACE_FAIRY,ATTRIBUTE_DARK)
		-- 检查玩家是否可以特殊召唤「蒂斯衍生物」（天使族·暗·3星·攻/守1200），若不能则返回
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,85771021,0,TYPES_TOKEN_MONSTER,1200,1200,3,RACE_FAIRY,ATTRIBUTE_DARK) then return end
	-- 在卡片数据库中创建「阿斯蒙衍生物」的卡片数据
	local token=Duel.CreateToken(tp,85771020)
	-- 尝试将「阿斯蒙衍生物」以表侧表示特殊召唤到自己场上（分步处理）
	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	-- 「阿斯蒙衍生物」不会被效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e1)
	-- 在卡片数据库中创建「蒂斯衍生物」的卡片数据
	local token2=Duel.CreateToken(tp,85771021)
	-- 尝试将「蒂斯衍生物」以表侧表示特殊召唤到自己场上（分步处理）
	Duel.SpecialSummonStep(token2,0,tp,tp,false,false,POS_FACEUP)
	-- 「蒂斯衍生物」不会被战斗破坏。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	token2:RegisterEffect(e2)
	-- 完成特殊召唤的最终处理（使分步特殊召唤的怪兽正式登场）
	Duel.SpecialSummonComplete()
end
