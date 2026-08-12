--星蝕－レベル・クライム－
-- 效果：
-- 同调怪兽特殊召唤时，选择那1只怪兽发动。在自己场上把1只「星食衍生物」（魔法师族·暗·1星·攻/守0）特殊召唤。这衍生物的等级变成和选择的怪兽相同的等级，选择的怪兽的等级变成1星。
function c70391588.initial_effect(c)
	-- 同调怪兽特殊召唤时，选择那1只怪兽发动。在自己场上把1只「星食衍生物」（魔法师族·暗·1星·攻/守0）特殊召唤。这衍生物的等级变成和选择的怪兽相同的等级，选择的怪兽的等级变成1星。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c70391588.target)
	e1:SetOperation(c70391588.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足以下条件的卡片：表侧表示、是同调怪兽、可以作为效果对象，且玩家可以特殊召唤对应等级的「星食衍生物」
function c70391588.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsCanBeEffectTarget(e)
		-- 检查玩家是否可以特殊召唤与该同调怪兽等级相同的「星食衍生物」（魔法师族·暗·攻/守0）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,70391589,0,TYPES_TOKEN_MONSTER,0,0,c:GetLevel(),RACE_SPELLCASTER,ATTRIBUTE_DARK)
end
-- 效果的发动准备与对象选择：确认是否有怪兽特殊召唤，检查怪兽区域空位，选择1只特殊召唤的同调怪兽作为对象，并设置特殊召唤和衍生物产生的操作信息
function c70391588.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c70391588.filter(chkc,e,tp) end
	-- 在发动时，检查自己场上是否有怪兽区域空位，以及当前特殊召唤的怪兽中是否存在满足条件的同调怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and eg:IsExists(c70391588.filter,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	local g=eg:FilterSelect(tp,c70391588.filter,1,1,nil,e,tp)
	-- 将选择的同调怪兽设置为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置操作信息，表示该效果包含产生1只衍生物的处理
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示该效果包含特殊召唤1只怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：将选择的同调怪兽等级变成1星，并在自己场上特殊召唤1只「星食衍生物」，其等级变成和选择的怪兽原本等级相同
function c70391588.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动的对象怪兽（即选择的那1只同调怪兽）
	local tc=Duel.GetFirstTarget()
	local lv=1
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		lv=tc:GetLevel()
		-- 选择的怪兽的等级变成1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 检查玩家当前是否仍能特殊召唤该衍生物，若不能则不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,70391589,0,TYPES_TOKEN_MONSTER,0,0,lv,RACE_SPELLCASTER,ATTRIBUTE_DARK) then return end
	-- 在内存中创建「星食衍生物」的卡片数据
	local token=Duel.CreateToken(tp,70391589)
	-- 开始执行特殊召唤步骤，将衍生物以表侧表示特殊召唤到自己场上
	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	-- 这衍生物的等级变成和选择的怪兽相同的等级
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetValue(lv)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e2)
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
