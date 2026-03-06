--クラスター・ペンデュラム
-- 效果：
-- ①：这张卡召唤成功时才能发动。把最多有对方场上的怪兽数量的「钟摆衍生物」（机械族·地·1星·攻/守0）在自己场上特殊召唤。
function c27450400.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤成功时才能发动。把最多有对方场上的怪兽数量的「钟摆衍生物」（机械族·地·1星·攻/守0）在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27450400,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c27450400.sptg)
	e1:SetOperation(c27450400.spop)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否可以发动此效果，条件为己方场上存在空位、对方场上存在怪兽且己方可以特殊召唤衍生物。
function c27450400.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断己方场上是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 效果作用：判断己方是否可以特殊召唤指定的衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,27450401,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果作用：处理特殊召唤衍生物的逻辑，包括计算可召唤数量、处理青眼精灵龙限制、循环召唤并询问是否继续。
function c27450400.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取己方场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 效果作用：获取对方场上的怪兽数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if ft>ct then ft=ct end
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 效果作用：判断己方是否可以特殊召唤指定的衍生物。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,27450401,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	local ctn=true
	while ft>0 and ctn do
		-- 效果作用：创建一个指定编号的衍生物。
		local token=Duel.CreateToken(tp,27450401)
		-- 效果作用：将创建的衍生物特殊召唤到己方场上。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		ft=ft-1
		-- 效果作用：判断是否继续召唤衍生物，若无空位或玩家选择否则停止召唤。
		if ft<=0 or not Duel.SelectYesNo(tp,aux.Stringid(27450400,1)) then ctn=false end  --"是否继续特殊召唤「钟摆衍生物」？"
	end
	-- 效果作用：完成所有特殊召唤操作。
	Duel.SpecialSummonComplete()
end
