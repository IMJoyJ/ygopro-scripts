--チュウボーン
-- 效果：
-- ①：这张卡反转的场合发动。在对方场上把3只「小鼠骨衍生物」（不死族·地·1星·攻100/守300）守备表示特殊召唤。
function c7392745.initial_effect(c)
	-- ①：这张卡反转的场合发动。在对方场上把3只「小鼠骨衍生物」（不死族·地·1星·攻100/守300）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7392745,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c7392745.target)
	e1:SetOperation(c7392745.operation)
	c:RegisterEffect(e1)
end
-- 效果的发动准备与操作信息设置
function c7392745.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示此效果包含衍生物产生
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	-- 设置操作信息，表示此效果包含特殊召唤3只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
-- 效果处理的执行，在对方场上特殊召唤3只衍生物
function c7392745.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查对方场上的怪兽区域空位数是否小于3，若不足3个空位则不处理
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<3 then return end
	-- 检查玩家是否能将特定属性、数值的衍生物特殊召唤到对方场上，若不能则不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,7392746,0,TYPES_TOKEN_MONSTER,100,300,1,RACE_ZOMBIE,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) then return end
	for i=1,3 do
		-- 创建「小鼠骨衍生物」卡片
		local token=Duel.CreateToken(tp,7392746)
		-- 将衍生物以表侧守备表示特殊召唤到对方场上（单步处理）
		Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
