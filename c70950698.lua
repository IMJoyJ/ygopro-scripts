--ブート・スタッガード
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有电子界族怪兽召唤时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡给与对方战斗伤害时才能发动。在自己场上把1只「引导鹿衍生物」（电子界族·地·1星·攻/守0）特殊召唤。
function c70950698.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上有电子界族怪兽召唤时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70950698,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,70950698)
	e1:SetCondition(c70950698.spcon)
	e1:SetTarget(c70950698.sptg)
	e1:SetOperation(c70950698.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡给与对方战斗伤害时才能发动。在自己场上把1只「引导鹿衍生物」（电子界族·地·1星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70950698,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c70950698.tkcon)
	e2:SetTarget(c70950698.tktg)
	e2:SetOperation(c70950698.tkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查召唤的怪兽是否由自己控制且是电子界族怪兽
function c70950698.spcfilter(c,tp)
	return c:IsControler(tp) and c:IsRace(RACE_CYBERSE)
end
-- 效果①的发动条件：自己场上有电子界族怪兽召唤成功
function c70950698.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c70950698.spcfilter,1,nil,tp)
end
-- 效果①的发动准备：检查怪兽区域空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c70950698.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将手牌中的这张卡特殊召唤
function c70950698.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：这张卡给与对方战斗伤害
function c70950698.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果②的发动准备：检查怪兽区域空位以及是否能特殊召唤衍生物，并设置相关操作信息
function c70950698.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能特殊召唤「引导鹿衍生物」（电子界族·地·1星·攻/守0）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,70950699,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_EARTH) end
	-- 设置生成衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果②的效果处理：在自己场上把1只「引导鹿衍生物」特殊召唤
function c70950698.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查是否仍能特殊召唤该衍生物
	if Duel.IsPlayerCanSpecialSummonMonster(tp,70950699,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_EARTH) then
		-- 创建「引导鹿衍生物」的卡片数据
		local token=Duel.CreateToken(tp,70950699)
		-- 将衍生物以表侧表示特殊召唤
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
