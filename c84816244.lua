--ドングルドングリ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。在自己场上把1只「软件狗衍生物」（电子界族·暗·1星·攻/守0）特殊召唤。
function c84816244.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡特殊召唤成功的场合才能发动。在自己场上把1只「软件狗衍生物」（电子界族·暗·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84816244,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,84816244)
	e1:SetTarget(c84816244.tktg)
	e1:SetOperation(c84816244.tkop)
	c:RegisterEffect(e1)
end
-- 效果①的发动准备（检查怪兽区域空位以及是否可以特殊召唤衍生物）
function c84816244.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的衍生物怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,84816245,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) end
	-- 设置连锁处理中的操作信息：产生1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁处理中的操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果①的效果处理（在自己场上特殊召唤1只「软件狗衍生物」）
function c84816244.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否可以特殊召唤指定的衍生物怪兽
	if Duel.IsPlayerCanSpecialSummonMonster(tp,84816245,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) then
		-- 创建「软件狗衍生物」卡片数据
		local token=Duel.CreateToken(tp,84816245)
		-- 将创建的衍生物以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
