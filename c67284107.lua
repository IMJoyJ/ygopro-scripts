--スケープ・ゴースト
-- 效果：
-- ①：这张卡反转的场合才能发动。在自己场上把「黑羊衍生物」（不死族·暗·1星·攻/守0）任意数量特殊召唤。
function c67284107.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。在自己场上把「黑羊衍生物」（不死族·暗·1星·攻/守0）任意数量特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67284107,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c67284107.sptg)
	e1:SetOperation(c67284107.spop)
	c:RegisterEffect(e1)
end
-- 特殊召唤效果的发动准备与合法性检测
function c67284107.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否具有特殊召唤该衍生物怪兽的权限
		and Duel.IsPlayerCanSpecialSummonMonster(tp,67284108,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_ZOMBIE,ATTRIBUTE_DARK) end
	-- 设置操作信息，表明此效果包含产生衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表明此效果包含特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤效果的执行处理
function c67284107.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=5
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 计算可特殊召唤的衍生物最大数量（受场上空位及青眼精灵龙等效果限制）
	ft=math.min(ft,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	-- 若无法特殊召唤或没有可用空位，则直接结束效果处理
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,67284108,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_ZOMBIE,ATTRIBUTE_DARK) then return end
	repeat
		-- 在系统内创建「黑羊衍生物」的卡片数据
		local token=Duel.CreateToken(tp,67284108)
		-- 执行单步特殊召唤，将衍生物以表侧表示放入场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		ft=ft-1
	-- 循环进行特殊召唤，直到场上没有空位、达到特招上限或玩家选择停止
	until ft<=0 or not Duel.SelectYesNo(tp,aux.Stringid(67284107,1))  --"是否继续特殊召唤「黑羊衍生物」？"
	-- 结束单步特殊召唤流程，使所有特殊召唤的怪兽同时登场
	Duel.SpecialSummonComplete()
end
